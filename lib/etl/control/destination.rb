module ETL #:nodoc:
  module Control #:nodoc:
    # Base class for destinations.
    class Destination
      # Read-only accessor for the ETL::Control::Control instance
      attr_reader :control
      
      # Read-only accessor for the configuration Hash
      attr_reader :configuration
      
      # Read-only accessor for the destination mapping Hash
      attr_reader :mapping
      
      # Accessor to the buffer size
      attr_accessor :buffer_size
      
      # Unique flag.
      attr_accessor :unique
      
      # A condition for writing
      attr_accessor :condition
      
      # An array of rows to append to the destination
      attr_accessor :append_rows
      
      class << self
        # Get the destination class for the specified name.
        # 
        # For example if name is :database or 'database' then the 
        # DatabaseDestination class is returned
        def class_for_name(name)
          ETL::Control.const_get("#{name.to_s.camelize}Destination")
        end
      end
      
      # Initialize the destination
      #
      # Arguments:
      # * <tt>control</tt>: The ETL::Control::Control instance
      # * <tt>configuration</tt>: The configuration Hash
      # * <tt>mapping</tt>: The mapping Hash
      #
      # Options:
      # * <tt>:buffer_size</tt>: The output buffer size (default 1000 records)
      # * <tt>:condition</tt>: A conditional proc that must return true for the 
      #   row to be written
      # * <tt>:append_rows</tt>: An array of rows to append
      def initialize(control, configuration, mapping)
        @control = control
        @configuration = configuration
        @mapping = mapping
        @buffer_size = configuration[:buffer_size] ||= 100
        @condition = configuration[:condition]
        @append_rows = configuration[:append_rows]
      end
      
      # Get the current row number
      def current_row
        @current_row ||= 1
      end
      
      # Write the given row
      def write(row)
        if @condition.nil? || @condition.call(row)
          process_change(row)
        end
        flush if buffer.length >= buffer_size
      end
      
      # Abstract method
      def flush
        raise NotImplementedError, "flush method must be implemented by subclasses"
      end
      
      # Abstract method
      def close
        raise NotImplementedError, "close method must be implemented by subclasses"
      end
      
      def errors
        @errors ||= []
      end
      
      protected
      # Access the buffer
      def buffer
        @buffer ||= []
      end
      
      # Access the generators map
      def generators
        @generators ||= {}
      end
      
      # Get the order of elements from the source order
      def order_from_source
        control.sources.first.order
      end
      
      # Return true if the row is allowed. The row will not be allowed if the
      # :unique option is specified in the configuration and the compound key 
      # already exists
      def row_allowed?(row)
        if unique
          key = (unique.collect { |k| row[k] }).join('|')
          return false if compound_key_constraints[key]
          compound_key_constraints[key] = 1
        end
        return true
      end
      
      # Get a hash of compound key contraints. This is used to determine if a
      # row can be written when the unique option is specified
      def compound_key_constraints
        @compound_key_constraints ||= {}
      end
      
      # Return fields which are Slowly Changing Dimension fields. 
      # Uses the scd_fields specified in the configuration.  If that's
      # missing, uses all of the row's fields.
      def scd_fields(row)
        @scd_fields ||= configuration[:scd_fields] || row.keys
        ETL::Engine.logger.debug "@scd_fields is: #{@scd_fields.inspect}"
        @scd_fields
      end

      # returns the fields that are required to identify an SCD
      def scd_required_fields
        if scd? and scd_type == 2
         [scd_effective_date_field, scd_end_date_field, scd_latest_version_field]
        else
         []
        end
      end
      
      def non_scd_fields(row)
        @non_scd_fields ||= row.keys - natural_key - scd_fields(row) - [primary_key] - scd_required_fields
        ETL::Engine.logger.debug "@non_scd_fields is: #{@non_scd_fields.inspect}"
        @non_scd_fields
      end
      
      def non_evolving_fields
        (Array(configuration[:scd][:non_evolving_fields]) << primary_key).uniq
      end
      
      def scd?
        !configuration[:scd].nil?
      end
      
      def scd_type
        scd? ? configuration[:scd][:type] : nil
      end
      
      # Get the Slowly Changing Dimension effective date field. Defaults to
      # 'effective_date'.
      def scd_effective_date_field
        configuration[:scd][:effective_date_field] || :effective_date if scd?
      end
      
      # Get the Slowly Changing Dimension end date field. Defaults to 
      # 'end_date'.
      def scd_end_date_field
        configuration[:scd][:end_date_field] || :end_date if scd?
      end
      
      # Get the Slowly Changing Dimension latest version field. Defaults to
      # 'latest_version'.
      def scd_latest_version_field
        configuration[:scd][:latest_version_field] || :latest_version if scd?
      end
      
      # Return the natural key field names, defaults to []
      def natural_key
        @natural_key ||= determine_natural_key
      end
      
      # Get the dimension table if specified
      def dimension_table
        @dimension_table ||= if scd?
          ETL::Engine.table(configuration[:scd][:dimension_table], dimension_target) or raise ConfigurationError, "dimension_table setting required" 
        end
      end
      
      # Get the dimension target if specified
      def dimension_target
        @dimension_target ||= if scd?
          configuration[:scd][:dimension_target] or raise ConfigurationError, "dimension_target setting required"
        end
      end
      
      # Process a row to determine the change type
      def process_change(row)
        ETL::Engine.logger.debug "Processing row: #{row.inspect}"
        return unless row
        
        # Change processing can only occur if the natural key exists in the row 
        ETL::Engine.logger.debug "Checking for natural key existence"
        unless has_natural_key?(row)
          buffer << row
          return
        end
        
        @timestamp = Time.now

        # See if the scd_fields of the current record have changed
        # from the last time this record was loaded into the data
        # warehouse. If they match then throw away this row (no need
        # to process). If they do not match then the record is an
        # 'update'. If the record doesn't exist then it is an 'insert'
        ETL::Engine.logger.debug "Checking record for SCD change"
        if @existing_row = preexisting_row(row)
          if has_scd_field_changes?(row)
            process_scd_change(row)
          else
            process_scd_match(row)
          end
        else
          schedule_new_record(row)
        end
      end
      
      # Add any virtual fields to the row. Virtual rows will get their value 
      # from one of the following:
      # * If the mapping is a Class, then an object which implements the next 
      #   method
      # * If the mapping is a Symbol, then the XGenerator where X is the 
      #   classified symbol
      # * If the mapping is a Proc, then it will be called with the row
      # * Otherwise the value itself will be assigned to the field
      def add_virtuals!(row)
        if mapping[:virtual]
          mapping[:virtual].each do |key,value|
            # If the row already has the virtual set, assume that's correct
            next if row[key]
            # Engine.logger.debug "Mapping virtual #{key}/#{value} for row #{row}"
            case value
            when Class
              generator = generators[key] ||= value.new
              row[key] = generator.next
            when Symbol
              generator = generators[key] ||= ETL::Generator::Generator.class_for_name(value).new(options)
              row[key] = generator.next
            when Proc, Method
              row[key] = value.call(row)
            else
              if value.is_a?(ETL::Generator::Generator)
                row[key] = value.next
              else
                row[key] = value
              end
            end
          end
        end
      end
      
      private
      
      # Determine the natural key. This method will always return an array
      # of symbols. The default value is [].
      def determine_natural_key
        Array(configuration[:natural_key]).collect(&:to_sym)
      end
      
      # Check whether a natural key has been defined, and if so, whether
      # this row has enough information to do searches based on that natural
      # key.
      # 
      # TODO: This should be factored out into
      # ETL::Row#has_all_fields?(field_array) But that's not possible
      # until *all* sources cast to ETL::Row, instead of sometimes
      # using Hash
      def has_natural_key?(row)
        natural_key.any? && natural_key.all? { |key| row.has_key?(key) }
      end
      
      # Helper for generating the SQL where clause that allows searching
      # by a natural key
      def natural_key_equality_for_row(row)
        statement = []
        values = []
        natural_key.each do |nk|
          statement << "#{nk} = #{ActiveRecord::Base.send(:quote_bound_value, row[nk], connection)}"
        end
        statement = statement.join(" AND ")
        return statement
      end
      
      # Do all the steps required when a SCD *has* changed.  Exact steps
      # depend on what type of SCD we're handling.
      def process_scd_change(row)
        ETL::Engine.logger.debug "SCD fields do not match"
        
        if scd_type == 2
          # SCD Type 2: new row should be added and old row should be updated
          ETL::Engine.logger.debug "type 2 SCD"
          
          # To update the old row, we delete the version in the database
          # and insert a new expired version
          
          # If there is no truncate then the row will exist twice in the database
          delete_outdated_record
          
          ETL::Engine.logger.debug "expiring original record"
          @existing_row[scd_end_date_field] = @timestamp
          @existing_row[scd_latest_version_field] = false
          
          buffer << @existing_row

        elsif scd_type == 1
          # SCD Type 1: only the new row should be added
          ETL::Engine.logger.debug "type 1 SCD"

          # Copy primary key, and other non-evolving fields over from
          # original version of record
          non_evolving_fields.each do |non_evolving_field|            
            row[non_evolving_field] = @existing_row[non_evolving_field]
          end
          
          # If there is no truncate then the row will exist twice in the database
          delete_outdated_record
        else
          # SCD Type 3: not supported
          ETL::Engine.logger.debug "SCD type #{scd_type} not supported"
        end
        
        # In all cases, the latest, greatest version of the record
        # should go into the load
        schedule_new_record(row)
      end
      
      # Do all the steps required when a SCD has *not* changed.  Exact
      # steps depend on what type of SCD we're handling.
      def process_scd_match(row)
        ETL::Engine.logger.debug "SCD fields match"
        
        if scd_type == 2 && has_non_scd_field_changes?(row)
          ETL::Engine.logger.debug "Non-SCD field changes"
          # Copy important data over from original version of record
          row[primary_key]              = @existing_row[primary_key]
          row[scd_end_date_field]       = @existing_row[scd_end_date_field]
          row[scd_effective_date_field] = @existing_row[scd_effective_date_field]
          row[scd_latest_version_field] = @existing_row[scd_latest_version_field]

          # If there is no truncate then the row will exist twice in the database
          delete_outdated_record
          
          buffer << row
        else
          # The record is totally the same, so skip it
        end
      end
      
      # Find the version of this row that already exists in the datawarehouse.
      def preexisting_row(row)
        q = "SELECT * FROM #{dimension_table} WHERE #{natural_key_equality_for_row(row)}"
        q << " AND #{scd_latest_version_field}" if scd_type == 2
        
        ETL::Engine.logger.debug "looking for original record"
        result = connection.select_one(q)
        
        ETL::Engine.logger.debug "Result: #{result.inspect}"
        
        result ? ETL::Row[result.symbolize_keys!] : nil
      end
      
      # Check whether non-scd fields have changed since the last
      # load of this record.
      def has_scd_field_changes?(row)
        scd_fields(row).any? { |csd_field| 
          ETL::Engine.logger.debug "Row: #{row.inspect}"
          ETL::Engine.logger.debug "Existing Row: #{@existing_row.inspect}"
          ETL::Engine.logger.debug "comparing: #{row[csd_field].to_s} != #{@existing_row[csd_field].to_s}"
          x=row[csd_field].to_s != @existing_row[csd_field].to_s 
          ETL::Engine.logger.debug x
          x
        }
      end
      
      # Check whether non-scd fields have changed since the last
      # load of this record.
      def has_non_scd_field_changes?(row)
        non_scd_fields(row).any? { |non_csd_field| row[non_csd_field].to_s != @existing_row[non_csd_field].to_s }
      end
      
      # Grab, or re-use, a database connection for running queries directly
      # during the destination processing.
      def connection
        @conn ||= ETL::Engine.connection(dimension_target)
      end
      
      # Utility for removing a row that has outdated information.  Note
      # that this deletes directly from the database, even if this is a file
      # destination.  It needs to do this because you can't do deletes in a 
      # bulk load.
      def delete_outdated_record
        ETL::Engine.logger.debug "deleting old row"
        
        q = "DELETE FROM #{dimension_table} WHERE #{primary_key} = #{@existing_row[primary_key]}"
        connection.delete(q)
      end
      
      # Schedule the latest, greatest version of the row for insertion
      # into the database
      def schedule_new_record(row)
        ETL::Engine.logger.debug "writing new record"
        if scd_type == 2
          row[scd_effective_date_field] = @timestamp
          row[scd_end_date_field] = '9999-12-31 00:00:00'
          row[scd_latest_version_field] = true
        end
        buffer << row
      end
      
      # Get the name of the primary key for this table.  Asks the dimension
      # model class for this information, but if that class hasn't been 
      # defined, just defaults to :id.
      def primary_key
        return @primary_key if @primary_key
        @primary_key = dimension_table.to_s.camelize.constantize.primary_key.to_sym
      rescue NameError => e
        ETL::Engine.logger.debug "couldn't get primary_key from dimension model class, using default :id"
        @primary_key = :id
      end

    end
  end
end

Dir[File.dirname(__FILE__) + "/destination/*.rb"].each { |file| require(file) }

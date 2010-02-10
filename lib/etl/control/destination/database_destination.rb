module ETL #:nodoc:
  module Control #:nodoc:
    # Destination which writes directly to a database. This is useful when you are dealing with
    # a small amount of data. For larger amounts of data you should probably use the bulk
    # loader if it is supported with your target database as it will use a much faster load
    # method.
    class DatabaseDestination < Destination
      # The target connection
      attr_reader :target
      
      # The table
      attr_reader :table
      
      # Specify the order from the source
      attr_reader :order
      
      # Set to true to truncate the destination table first
      attr_reader :truncate
      
      # Initialize the database destination
      # 
      # * <tt>control</tt>: The ETL::Control::Control instance
      # * <tt>configuration</tt>: The configuration Hash
      # * <tt>mapping</tt>: The mapping
      #
      # Configuration options:
      # * <tt>:database</tt>: The database name (REQUIRED)
      # * <tt>:target</tt>: The target connection (REQUIRED)
      # * <tt>:table</tt>: The table to write to (REQUIRED)
      # * <tt>:truncate</tt>: Set to true to truncate before writing (defaults to false)
      # * <tt>:unique</tt>: Set to true to only insert unique records (defaults to false)
      # * <tt>:append_rows</tt>: Array of rows to append
      #
      # Mapping options:
      # * <tt>:order</tt>: The order of fields to write (REQUIRED)
      def initialize(control, configuration, mapping={})
        super
        @target = configuration[:target]
        @table = configuration[:table]
        @truncate = configuration[:truncate] ||= false
        @unique = configuration[:unique] ? configuration[:unique] + [scd_effective_date_field] : configuration[:unique]
        @unique.uniq! unless @unique.nil?
        @order = mapping[:order] ? mapping[:order] + scd_required_fields : order_from_source
        @order.uniq! unless @order.nil?
        raise ControlError, "Order required in mapping" unless @order
        raise ControlError, "Table required" unless @table
        raise ControlError, "Target required" unless @target
      end
      
      # Flush the currently buffered data
      def flush
        conn.transaction do
          buffer.flatten.each do |row|
            # check to see if this row's compound key constraint already exists
            # note that the compound key constraint may not utilize virtual fields
            next unless row_allowed?(row)

            # add any virtual fields
            add_virtuals!(row)
            
            names = []
            values = []
            order.each do |name|
              names << conn.quote_column_name(name)
              values << conn.quote(row[name])
            end
            q = "INSERT INTO #{conn.quote_table_name(table_name)} (#{names.join(',')}) VALUES (#{values.join(',')})"
            ETL::Engine.logger.debug("Executing insert: #{q}")
            conn.insert(q, "Insert row #{current_row}")
            @current_row += 1
          end
          buffer.clear
        end
      end
      
      # Close the connection
      def close
        buffer << append_rows if append_rows
        flush
      end
      
      private
      def conn
        @conn ||= begin
          conn = ETL::Engine.connection(target)
          conn.truncate(table_name) if truncate
          conn
        end
      end
      
      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
      
    end
  end
end

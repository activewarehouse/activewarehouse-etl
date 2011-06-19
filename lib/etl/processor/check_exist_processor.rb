module ETL #:nodoc:
  module Processor #:nodoc:
    # A row-level processor that checks if the row already exists in the 
    # target table
    class CheckExistProcessor < ETL::Processor::RowProcessor
      # A symbol or array of symbols representing keys that should be skipped
      attr_accessor :skip
      
      # The target database
      attr_accessor :target
      
      # The name of the table to check against
      attr_accessor :table
      
      # An array of columns representing the natural key
      attr_accessor :columns
      
      # Is set to true if the processor should execute the check. If there are
      # no rows in the target table then this should return false.
      attr_accessor :should_check
      
      # Initialize the processor
      # Configuration options:
      # * <tt>:columns</tt>: An array of symbols for columns that should be included in the query conditions. If this option is not specified then all of the columns in the row will be included in the conditions (unless :skip is specified).
      # * <tt>:skip</tt>: A symbol or array of symbols that should not be included in the existence check. If this option is not specified then all of the columns will be included in the existence check (unless :columns is specified).
      # * <tt>:target</tt>: The target connection
      # * <tt>:table</tt>: The table name
      def initialize(control, configuration)
        super
        @skip = configuration[:skip] || []
        @target = configuration[:target] || raise(ETL::ControlError, "target must be specified")
        @table = configuration[:table] || raise(ETL::ControlError, "table must be specified")
        @columns = configuration[:columns]
        
        q = "SELECT COUNT(*) FROM #{table_name}"
        @should_check = ETL::Engine.connection(target).select_value(q).to_i > 0 
      end
      
      # Return true if the given key should be skipped
      def skip?(key)
        case skip
        when Array
          skip.include?(key)
        else
          skip.to_sym == key.to_sym
        end
      end
      
      # Return true if the row should be checked
      def should_check?
        @should_check ? true : false
      end
      
      # Process the row
      def process(row)
        return row unless should_check?
        conn = ETL::Engine.connection(target)
        q = "SELECT * FROM #{table_name} WHERE "
        conditions = []
        ensure_columns_available_in_row!(row, columns, 'for existence check')
        row.each do |k,v| 
          if columns.nil? || columns.include?(k.to_sym)
            conditions << "#{k} = #{conn.quote(v)}" unless skip?(k.to_sym)
          end
        end
        q << conditions.join(" AND ")
        q << " LIMIT 1"
      
        result = conn.select_one(q)
        return row if result.nil?
      end
      
private

      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
    end
  end
end
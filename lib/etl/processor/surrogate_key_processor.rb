module ETL #:nodoc:
  module Processor #:nodoc:
    # A row level processor that provides surrogate keys
    class SurrogateKeyProcessor < ETL::Processor::RowProcessor
      attr_accessor :destination
      attr_accessor :table
      attr_accessor :column
      attr_accessor :target
      
      # Initialize the surrogate key generator
      #
      # Configuration options
      # * <tt>:query</tt>: If specified it contains a query to be used to 
      #   locate the last surrogate key. If this is specified then :target
      #   must also be specified.
      # * <tt>:target</tt>: The target connection
      # * <tt>:destination</tt>: The destination column name (defaults to :id)
      def initialize(control, configuration)
        super
        @table = configuration[:table]
        @column = configuration[:column] || 'id'
        @target = configuration[:target]
        if configuration[:query]
          raise ControlError, "Query option is no longer value, use :column and :table instead"
        end
        if table
          @surrogate_key = ETL::Engine.connection(target).select_value("SELECT max(#{column}) FROM #{table_name}")
        end
        #puts "initial surrogate key: #{@surrogate_key}"
        @surrogate_key = 0 if @surrogate_key.blank?
        @surrogate_key = @surrogate_key.to_i
        #puts "surrogate key: #{@surrogate_key}"
        @destination = configuration[:destination] || :id
      end
      
      # Add a surrogate key to the row
      def process(row)
        if row
          #puts "processing row #{row.inspect}"
          @surrogate_key += 1
          #puts "adding surrogate key to row: #{@surrogate_key}"
          row[destination] = @surrogate_key
          row
        end
      end
      
      private
      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
    end
  end
end
module ETL #:nodoc:
  module Processor #:nodoc:
    # A processor which will truncate a table. Use as a pre-processor for cleaning out a table
    # prior to loading
    class TruncateProcessor < ETL::Processor::Processor
      # Defines the table to truncate
      attr_reader :table
      
      # Defines the database connection to use
      attr_reader :target
      
      # Initialize the processor
      #
      # Options:
      # * <tt>:target</tt>: The target connection
      # * <tt>:table</tt>: The table name
      # * <tt>:options</tt>: Optional truncate options
      def initialize(control, configuration)
        super
        #@file = File.join(File.dirname(control.file), configuration[:file])
        @target = configuration[:target] || {}
        @table = configuration[:table]
        @options = configuration[:options] 
      end
      
      def process
        conn = ETL::Engine.connection(target)
        if conn.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          @options ||= 'RESTART IDENTITY'
        end
        conn.truncate(table_name, @options)
      end
      
      private
      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
    end
  end
end
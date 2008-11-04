# This source file contains code for a basic sequential surrogate key generator

module ETL #:nodoc:
  module Generator #:nodoc:
    # Surrogate key generator.
    class SurrogateKeyGenerator < Generator
      attr_reader :table
      attr_reader :target
      attr_reader :column
      attr_reader :query
      
      # Initialize the generator
      def initialize(options={})
        @table = options[:table]
        @target = options[:target]
        @column = options[:column] || 'id'
        @query = options[:query]
        
        if table
          @surrogate_key = ETL::Engine.connection(target).select_value("SELECT max(#{column}) FROM #{table_name}")
        elsif query
          @surrogate_key = ETL::Engine.connection(target).select_value(query)
        end
        @surrogate_key = 0 if @surrogate_key.blank?
        @surrogate_key = @surrogate_key.to_i
      end

      # Get the next surrogate key
      def next
        @surrogate_key ||= 0
        @surrogate_key += 1
      end
      
      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
    end
  end
end
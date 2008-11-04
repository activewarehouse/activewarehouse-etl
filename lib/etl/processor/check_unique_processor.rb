module ETL #:nodoc:
  module Processor #:nodoc:
    # Row processor that checks whether or not the row has already passed 
    # through the ETL processor, using the key fields provided as the keys
    # to check.
    class CheckUniqueProcessor < ETL::Processor::RowProcessor

      # The keys to check
      attr_accessor :keys
      
      # Initialize the processor
      # Configuration options:
      # * <tt>:keys</tt>: An array of keys to check against
      def initialize(control, configuration)
        super
        @keys = configuration[:keys]
      end

      # A Hash of keys that have already been processed.
      def compound_key_constraints
        @compound_key_constraints ||= {}
      end
      
      # Process the row. This implementation will only return a row if it
      # it's key combination has not already been seen.
      def process(row)
        key = (keys.collect { |k| row[k] }).join('|')
        unless compound_key_constraints[key]
          compound_key_constraints[key] = 1
          return row
        end
      end
    end
  end
end
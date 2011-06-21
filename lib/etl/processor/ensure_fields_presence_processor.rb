module ETL
  module Processor
    # Ensure that each specified field is available
    class EnsureFieldsPresenceProcessor < ETL::Processor::RowProcessor
      
      # Initialize the processor.
      #
      # Configuration options:
      # * <tt>:fields</tt>: An array of keys whose presence should be verified in each row
      def initialize(control, configuration)
        super
        @fields = configuration[:fields]
        raise ControlError, ":fields must be specified" unless @fields
      end
      
      def process(row)
        missing_fields = configuration[:fields] - row.keys
        raise(ETL::ControlError, 
          "Row missing required field(s) #{missing_fields.join(',')} in row. Available fields are : #{row.keys.join(',')}") unless missing_fields.empty?
        row
      end
    end
  end
end

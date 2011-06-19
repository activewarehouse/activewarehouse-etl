module ETL #:nodoc:
  module Processor #:nodoc:
    # Processor which processes a specific row. Unlike a transformer, which deals with a specific
    # value in the row, row processors can process an entire row at once, which can be used to 
    # explode a single row into multiple rows (for example)
    class RowProcessor < Processor
      # Initialize the processor
      def initialize(control, configuration)
        super
      end
      # Process the specified row. This method must return the row.
      def process(row)
        raise "process_row is an abstract method"
      end

      # Ensure a given row keys include all the provided columns
      # and raise an error using the provided message if it doesn't
      def ensure_columns_available_in_row!(row, columns, message)
        unless columns.nil?
          columns.each do |k|
            raise(ETL::ControlError, "Row missing required field #{k.inspect} #{message}") unless row.keys.include?(k)
          end
        end
      end
    end
  end
end
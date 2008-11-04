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
    end
  end
end
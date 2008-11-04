module ETL #:nodoc:
  module Processor #:nodoc:
    # Debugging processor for printing the current row
    class PrintRowProcessor < ETL::Processor::RowProcessor
      # Process the row
      def process(row)
        puts row.inspect
        row
      end
    end
  end
end
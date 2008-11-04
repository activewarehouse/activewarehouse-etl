module ETL #:nodoc:
  module Processor #:nodoc:
    # Row processor that will copy one field to another
    #
    # Configuration options:
    # * <tt>:destination</tt>: The destination field
    # * <tt>:dest</tt>: Alias for :destination
    # * <tt>:source</tt>: The source field
    class CopyFieldProcessor < ETL::Processor::RowProcessor
      # Process the given row
      def process(row)
        destination = (configuration[:destination] || configuration[:dest])
        source_value = row[configuration[:source]]
        case source_value
        when Numeric
          row[destination] = source_value
        when nil
          row[destination] = nil
        else
          row[destination] = source_value.dup
        end
        row
      end
    end
  end
end
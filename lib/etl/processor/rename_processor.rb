module ETL #:nodoc:
  module Processor #:nodoc:
    # Row level processor to rename a field in the row.
    #
    # Configuration options:
    # * <tt>:source</tt>: the source field name
    # * <tt>:dest</tt>: The destination field name
    class RenameProcessor < ETL::Processor::RowProcessor
      def process(row)
        source_value = row[configuration[:source]]
        case source_value
        when Numeric
          row[configuration[:dest]] = source_value
        when nil
          row[configuration[:dest]] = nil
        else
          row[configuration[:dest]] = source_value.dup
        end
        row.delete(configuration[:source])
        row
      end
    end
  end
end
module ETL #:nodoc:
  module Processor #:nodoc:
    # Row level processor to generate a sequence.
    #
    # Configuration options:
    # * <tt>:context</tt>: A context name, if none is specified then the context will be
    #   the current ETL run
    # * <tt>:dest</tt>: The destination field name
    class SequenceProcessor < ETL::Processor::RowProcessor
      def process(row)
        sequences[configuration[:context]] ||= 0
        row[configuration[:dest]] = sequences[configuration[:context]] += 1
        row
      end
      
      protected
      # Get a Hash of sequences
      def sequences
        @sequences ||= {}
      end
    end
  end
end
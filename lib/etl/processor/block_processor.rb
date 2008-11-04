module ETL
  module Processor
    # This processor is both a valid RowProcessor (called on each row with after_read) or a Processor (called once on pre_process or post_process)
    class BlockProcessor < ETL::Processor::RowProcessor
      def initialize(control, configuration)
        super
        @block = configuration[:block]
      end
      def process(row=nil)
        @block.call(row)
      end
    end
  end
end

module ETL
  module Processor
    class FilterRowProcessor < ETL::Processor::RowProcessor
      attr_reader :condition
      attr_reader :outtrue
      attr_reader :outfalse

      def initialize(control, configuration)
        @condition = configuration[:condition]
        @outtrue = configuration[:outtrue]
        @outfalse = configuration[:outfalse]
        super
      end
      
      def process(row)
        return nil if row.nil?

        if eval_condition(row, @condition)
          return [] if @outtrue.nil?

          eval(@outtrue)
        else
          eval(@outfalse) unless @outfalse.nil?
        end

        return row
      end

      private
      def eval_condition(row, cond)

        first = cond[1]
        if (cond[1].class == Array)
          first = eval_condition(row, cond[1])
        end

        second = cond[2]
        if (cond[2].class == Array)
          second = eval_condition(row, cond[2])
        end

        return eval("#{cond[0]}#{first}#{second}") if cond[0] == "!"

        eval("#{first}#{cond[0]}#{second}")
      rescue => e
        return false
      end

    end
  end
end

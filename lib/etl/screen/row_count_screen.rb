module ETL
  module Screen
    # This screen validates the number of rows which will be bulk loaded
    # against the results from some sort of a row count query. If there 
    # is a difference then the screen will not pass
    class RowCountScreen
      attr_accessor :control, :configuration
      def initialize(control, configuration={})
        @control = control
        @configuration = configuration
        execute
      end
      def execute
        unless Engine.rows_written == configuration[:rows]
          raise "Rows written (#{Engine.rows_written}) does not match expected rows (#{configuration[:rows]})"
        end
      end
    end
  end
end
module ETL
  module Processor
    # Custom processor to upload files via S3
    class RedshiftBulkLoadProcessor < ETL::Processor::Processor
      attr_reader :connection
      attr_reader :s3object
      attr_reader :table_name
      

      def initialize(control, configuration)
        @connection = configuration[:connection]
        @s3object = configuration[:s3object]
        @table_name = configuration[:table_name]
        @columns = configuration[:columns]
      end
      
      def process
        @connection.execute("COPY #{@table_name} FROM #{@s3object}")
      end

    end
  end
end

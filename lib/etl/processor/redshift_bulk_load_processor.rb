module ETL
  module Processor
    # Custom processor to upload files via S3
    class RedshiftBulkLoadProcessor < ETL::Processor::Processor
      attr_reader :target
      attr_reader :s3object
      attr_reader :table_name
      attr_reader :aws_credentials
      
      def initialize(control, configuration)
        @target = configuration[:target]
        @s3object = configuration[:s3object]
        @table_name = configuration[:table_name]
        @columns = configuration[:columns]
        @aws_credentials = configuration[:aws_credentials]
      end
      
      def process
        conn = ETL::Engine.connection(target)
        conn.execute("COPY #{@table_name} [(#{@columns.join(',')})] FROM '#{@s3object}' CREDENTIALS '#{aws_credentials}' DELIMITER AS ',';")
      end
    end
  end
end

require 'right_aws'

module ETL
  module Processor
    # Custom processor to upload files via S3
    class S3UploaderProcessor < ETL::Processor::Processor
      attr_reader :aws_access_key_id
      attr_reader :aws_secret_access_key
      attr_reader :bucket_name
      attr_reader :remote_key
      attr_reader :data_stream
      attr_reader :options
      

      def initialize(control, configuration)
        @aws_access_key_id = configuration[:aws_access_key_id]
        @aws_secret_access_key = configuration[:aws_secret_access_key]
        @bucket_name = configuration[:bucket_name]
        @remote_key = configuration[:remote_key]
        @data_stream = configuration[:data_stream]
        @options = configuration[:options]
      end
      
      def process
      	s3 = RightAws::S3Interface.new(@aws_access_key_id, @aws_secret_access_key, @options) 
  		s3.put(@bucket_name,@remote_key,@data)
  		s3.head_link("shopify-reports-cache",@remote_key)
      end

    end
  end
end

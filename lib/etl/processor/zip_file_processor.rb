require 'zip/zip'

module ETL
  module Processor
    # Custom processor to zip files
    class ZipFileProcessor < ETL::Processor::Processor
      attr_reader :infile
      attr_reader :destination
      
      # configuration options include:
      # * infile - File to zip (required)
      # * destination - Zip file name (default: #{infile}.zip)
      def initialize(control, configuration)
        path = Pathname.new(configuration[:infile])
        @infile = path.absolute? ? path : Pathname.new(File.dirname(File.expand_path(configuration[:infile]))) + path
        @destination = configuration[:destination] || "#{infile}.zip"
      end
      
      def process
        Zip::ZipFile.open(@destination, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.add(@infile.basename, @infile)
        end
      end
      
    end
  end
end

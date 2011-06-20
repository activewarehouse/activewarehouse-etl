optional_require 'nokogiri'
require 'open-uri'
optional_require 'zlib'

module ETL
  module Parser
    class NokogiriXmlParser < ETL::Parser::Parser
      # Initialize the parser
      # * <tt>source</tt>: The Source object
      # * <tt>options</tt>: Parser options Hash
      def initialize(source, options={})
        super
        configure
      end
      
      # Returns each row
      def each
        Dir.glob(file).each do |source|

          doc = nil

          gzip = false
          magic = "1F8B".to_i(base=16)  # Check for gzip archives
          if File.exist?(source)
            gzip = true if magic == (
              File.open(source).read(2).unpack("H2H2").to_s.to_i(base=16))
          end

          if gzip
            doc = Nokogiri::XML(Zlib::GzipReader.open(source))
          else
            doc = Nokogiri::XML(open(source))
          end
          
          doc.xpath(@collection_xpath).each do |nodeset|
            row = {}

            fields.each do |f|
              value = nodeset.xpath(f.xpath).text
              row[f.name] = value
            end
            yield row
          end

        end
      end
      
      # Get an array of defined fields
      def fields
        @fields ||= []
      end
      
      private
      def configure
        @collection_xpath = source.definition[:collection]
        if @collection_xpath.nil?
          raise ":collection => 'XPath' argument required"
        end
        source.definition[:fields].each do |options|
          case options
          when Symbol
            fields << Field.new(options, options.to_s)
          when Hash
            options[:xpath] ||= options[:name]
            fields << Field.new(options[:name], options[:xpath].to_s)
          else
            raise DefinitionError, 
              "Each field definition must either be an symbol " +
              "or a hash of options for the field"
          end
        end
      end
      
      class Field
        attr_reader :name, :xpath
        def initialize(name, xpath)
          @name = name
          @xpath = xpath
        end
      end
    end
  end
end

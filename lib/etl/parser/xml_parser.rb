require 'rexml/document'

module ETL
  module Parser
    class XmlParser < ETL::Parser::Parser
      # Initialize the parser
      # * <tt>source</tt>: The Source object
      # * <tt>options</tt>: Parser options Hash
      def initialize(source, options={})
        super
        configure
      end
      
      # Returns each row
      def each
        Dir.glob(file).each do |file|
          doc = nil
          t = Benchmark.realtime do
            doc = REXML::Document.new(File.new(file))
          end
          Engine.logger.info "XML #{file} parsed in #{t}s"
          doc.elements.each(@collection_xpath) do |element|
            row = {}
            fields.each do |f|
              value = element.text(f.xpath)
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
        raise "Collection XPath is required" if @collection_xpath.nil?
        
        source.definition[:fields].each do |options|
          case options
          when Symbol
            fields << Field.new(options, options.to_s)
          when Hash
            options[:xpath] ||= options[:name]
            fields << Field.new(options[:name], options[:xpath].to_s)
          else
            raise DefinitionError, "Each field definition must either be an symbol or a hash of options for the field"
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
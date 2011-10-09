# This source file contains the ETL::Parser module and requires all of the files
# in the parser directory ending with .rb

module ETL #:nodoc:
  # The ETL::Parser module provides various text parsers.
  class Parser
    include Enumerable

    autoload :ApacheCombinedLogParser,  'etl/parser/apache_combined_log_parser'
    autoload :CsvParser,                'etl/parser/csv_parser'
    autoload :ExcelParser,              'etl/parser/excel_parser'
    autoload :FixedWidthParser,         'etl/parser/fixed_width_parser'
    autoload :NokogiriXmlParser,        'etl/parser/nokogiri_xml_parser'
    autoload :SaxParser,                'etl/parser/sax_parser'
    autoload :XmlParser,                'etl/parser/xml_parser'

    # The Source object for the data
    attr_reader :source

    # Options Hash for the parser
    attr_reader :options

    class << self
      # Convert the name (string or symbol) to a parser class.
      #
      # Example:
      #   <tt>class_for_name(:fixed_width)</tt> returns a FixedWidthParser class
      def class_for_name(name)
        ETL::Parser.const_get("#{name.to_s.camelize}Parser")
      end
    end

    def initialize(source, options={})
      @source = source
      @options = options || {}
    end

    protected
    def file
      path = Pathname.new(source.configuration[:file])
      path = path.absolute? ? path : Pathname.new(File.dirname(source.control.file)) + path
      path
    end

    def raise_with_info(error, message, file, line)
      raise error, "#{message} (line #{line} in #{file})"
    end

  end
end

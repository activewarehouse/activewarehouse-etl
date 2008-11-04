module ETL #:nodoc:
  module Parser #:nodoc:
    # Base parser class. Implementation classes must extend this class and implement
    # the each method. The each method should return each row of the source data as 
    # a Hash.
    class Parser
      include Enumerable
      class << self
        # Convert the name (string or symbol) to a parser class.
        #
        # Example:
        #   <tt>class_for_name(:fixed_width)</tt> returns a FixedWidthParser class
        def class_for_name(name)
          ETL::Parser.const_get("#{name.to_s.camelize}Parser")
        end
      end
      
      # The Source object for the data
      attr_reader :source
      
      # Options Hash for the parser
      attr_reader :options
      
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
end
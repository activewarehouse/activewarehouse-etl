require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

module ETL #:nodoc:
  module Parser #:nodoc:
    # ETL parser implementation which uses SAX to parse XML files.
    class SaxParser < ETL::Parser::Parser
      
      # The write trigger causes whatever values are currently specified for the row to be returned.
      # After returning the values will not be cleared, thus allowing for values which are assigned
      # higher in the XML tree to remain in memory.
      attr_accessor :write_trigger
      
      # Initialize the parser
      # * <tt>source</tt>: The Source object
      # * <tt>options</tt>: Parser options Hash
      def initialize(source, options={})
        super
        configure
      end
      
      # Returns each row
      def each(&block)
        Dir.glob(file).each do |file|
          parser = REXML::Parsers::SAX2Parser.new(File.new(file))
          listener = Listener.new(self, &block)
          parser.listen(listener)
          parser.parse
        end
      end
      
      # Get an array of Field objects
      def fields
        @fields ||= []
      end
      
      private
      def configure
        #puts "write trigger in source.definition: #{source.definition[:write_trigger]}"
        self.write_trigger = source.definition[:write_trigger]
        # map paths to field names
        source.definition[:fields].each do |name, path|
          #puts "defined field #{name}, path: #{path}"
          fields << Field.new(name, XPath::Path.parse(path))
        end
      end
      
      # Class representing a field to be loaded from the source
      class Field
        # The name of the field
        attr_reader :name
        # The XPath-like path to the field in the XML document
        attr_reader :path
        
        def initialize(name, path) #:nodoc
          @name = name
          @path = path
        end
      end
    end
    
    class Listener #:nodoc:
      include REXML::SAX2Listener
      def initialize(parser, &block)
        @parser = parser
        @row = {}
        @value = nil
        @proc = Proc.new(&block)
      end
      def cdata(text)    
        @value << text
      end
      def characters(text)
        text = text.strip
        if (!text.nil? && text != '')
          @value ||= ''
          @value << text
        end
      end
      def start_document
        @path = XPath::Path.new
      end
      def end_document
        
      end
      def start_element(uri, localname, qname, attributes)
        element = XPath::Element.new(localname, attributes)
        @path.elements << element
        
        @parser.fields.each do |field|
          #puts "#{@path} match? #{field.path}"
          if @path.match?(field.path)
            #puts "field.path: #{field.path}"
            if field.path.is_attribute?
              #puts "setting @row[#{field.name}] to #{element.attributes[field.path.attribute]}"
              @row[field.name] = element.attributes[field.path.attribute]
            end
          end
        end
      end
      def end_element(uri, localname, qname)
        element = @path.elements.last
        
        @parser.fields.each do |field|
          #puts "#{@path} match? #{field.path}"
          if @path.match?(field.path)
            #puts "field.path: #{field.path}"
            if !field.path.is_attribute?
              @row[field.name] = @value
            end
          end
        end
        
        #puts @path.to_s
        if @path.match?(@parser.write_trigger)
          #puts "matched: #{@path} =~ #{@parser.write_trigger}"
          #puts "calling proc with #{@row.inspect}"
          @proc.call(@row.clone)
        end
        
        @value = nil
        @path.elements.pop
      end
      def progress(position)
        @position = position
      end
    end

    # Module which contains classes that are used for XPath-like filtering
    # on the SAX parser
    module XPath #:nodoc:
      class Path #:nodoc:
        # Get the elements in the path
        attr_accessor :elements
        
        # Initialize
        def initialize
          @elements = []
        end
        
        # Convert to a string representation
        def to_s
          @elements.map{ |e| e.to_s }.join("/")
        end
        
        # Returns true if the last part of the path refers to an attribute
        def is_attribute?
          elements.last.attributes.length > 0
        end
        
        # Return the name of the attribute referenced by the last element in this path. Returns nil if the last element
        # does not reference an attribute.
        #
        # Warning: the path must only reference a single attribute, otherwise the result of this method will be random, 
        # since attributes are stored in a Hash.
        def attribute
          return nil unless is_attribute?
          elements.last.attributes.keys.first
        end
        
        # Return true if this XPath::Path matches the given path string. This is a fail-fast match, so the first mismatch
        # will cause the method to return false.
        def match?(s)
          path = Path.parse(s)
          return false unless path.elements.length == elements.length
          elements.each_with_index do |element, index|
            path_element = path.elements[index]
            return false if path_element.nil?
            return false if element.name != path_element.name
            path_element.attributes.each do |key, value|
              return false unless element.attributes[key] =~ value
            end
          end
          return true
        end
        
        # Parse the string into an XPath::Path object
        def self.parse(s)
          return s if s.is_a?(Path)
          path = Path.new
          parts = s.split('/')
          parts.each_with_index do |part, i|
            attributes = {}
            part.gsub!(/(.*)\[(.*)\]/, '\1')
            if !$2.nil?
              $2.split(",").each do |pair|
                key, value = pair.split("=")
                value = ".*" if value.nil?
                attributes[key] = Regexp.new(value)
              end
            end
            path.elements << Element.new(part, attributes)
          end
          path
        end
      end
      class Element #:nodoc
        attr_reader :name
        attr_reader :attributes
        def initialize(name, attributes={})
          @name = name
          @attributes = attributes
        end
        def to_s
          s = "#{name}"
          if !@attributes.empty?
            attr_str = @attributes.collect do |key,value|
              value = value.source if value.is_a?(Regexp)
              "#{key}=#{value}" 
            end.join(",")
            s << "[" + attr_str + "]"
          end
          s
        end
      end
    end
  end
end
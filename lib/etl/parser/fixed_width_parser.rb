module ETL #:nodoc:
  module Parser #:nodoc:
    # Parser for fixed with files
    class FixedWidthParser < ETL::Parser::Parser
      # Initialize the parser
      # * <tt>source</tt>: The source object
      # * <tt>options</tt>: Parser options Hash
      def initialize(source, options={})
        super
        configure
      end
      
      # Return each row
      def each
        Dir.glob(file).each do |file|
          open(file).each do |line|
            row = {}
            lines_skipped = 0
            fields.each do |name, f|
              if lines_skipped < source.skip_lines
                lines_skipped += 1
                next
              end
              # TODO make strip optional?
              row[name] = line[f.field_start, f.field_length].strip
            end
            yield row
          end
        end
      end
      
      # Return a map of defined fields
      def fields
        @fields ||= {}
      end
      
      private
      def configure
        source.definition.each do |field, options|
          fields[field] = FixedWidthField.new(
            options[:name], options[:start], options[:end], options[:length]
          )
        end
      end
    end
    
    class FixedWidthField #:nodoc:
      attr_reader :name, :field_start, :field_end, :field_length
      # Initialize the field.
      def initialize(name, field_start, field_end=nil, field_length=nil)
        @name = name
        @field_start = field_start - 1
        if field_end
          @field_end = field_end
          @field_length = @field_end - @field_start
        elsif field_length
          @field_length = field_length
          @field_end = @field_start + @field_length
        else
          raise DefinitionError, "Either field_end or field_length required"
        end
      end
    end
  end
end
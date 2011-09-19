module ETL #:nodoc:
  module Parser #:nodoc:
    # Parses CSV files
    class CsvParser < ETL::Parser::Parser
      # Initialize the parser
      # * <tt>source</tt>: The Source object
      # * <tt>options</tt>: Hash of options for the parser, defaults to an empty hash
      def initialize(source, options={})
        super
        configure
      end
      
      def get_fields_names(file)
        File.open(file) do |input|
          fields = CSV.parse(input.readline, options).first
          new_fields = []
          fields.each_with_index do |field,index|
            # compute the index of occurrence of this specific occurrence of the field (usually, will be 1)
            occurrence_index = fields[0..index].find_all { |e| e == field }.size
            number_of_occurrences = fields.find_all { |e| e == field }.size
            new_field = field + (number_of_occurrences > 1 ? "_#{occurrence_index}" : "")
            new_fields << Field.new(new_field.to_sym)
          end
          return new_fields
        end
      end

      # Returns each row.
      def each
        Dir.glob(file).each do |file|
          ETL::Engine.logger.debug "parsing #{file}"
          if fields.length == 0
            ETL::Engine.logger.debug "no columns specified so reading names from first line of #{file}"
            @fields = get_fields_names(file)
          end
          line = 0
          lines_skipped = 0
          CSV.foreach(file, options) do |raw_row|
            if lines_skipped < source.skip_lines
              ETL::Engine.logger.debug "skipping line"
              lines_skipped += 1
              next
            end
            line += 1
            row = {}
            validate_row(raw_row, line, file)
            raw_row.each_with_index do |value, index|
              f = fields[index]
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
      def validate_row(row, line, file)
        ETL::Engine.logger.debug "validating line #{line} in file #{file}"
        if row.length != fields.length
          raise_with_info( MismatchError, 
            "The number of columns from the source (#{row.length}) does not match the number of columns in the definition (#{fields.length})", 
            line, file
          )
        end
      end
      
      def configure
        source.definition.each do |options|
          case options
          when Symbol
            fields << Field.new(options)
          when Hash
            fields << Field.new(options[:name])
          else
            raise DefinitionError, "Each field definition must either be a symbol or a hash"
          end
        end
      end
      
      class Field #:nodoc:
        attr_reader :name
        def initialize(name)
          @name = name
        end
      end
    end
  end
end
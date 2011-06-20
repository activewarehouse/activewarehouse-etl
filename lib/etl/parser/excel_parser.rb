optional_require 'spreadsheet'

module ETL
  module Parser
    class ExcelParser < ETL::Parser::Parser

      attr_accessor :ignore_blank_line

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
          ETL::Engine.logger.debug "parsing #{file}"
          line = 0
          lines_skipped = 0
          book = Spreadsheet.open file
          loopworksheets = []

          if worksheets.empty?
            loopworksheets = book.worksheets
          else
            worksheets.each do |index|
              loopworksheets << book.worksheet(index)
            end
          end

          loopworksheets.each do |sheet|
            sheet.each do |raw_row|
              if lines_skipped < source.skip_lines
                ETL::Engine.logger.debug "skipping line"
                lines_skipped += 1
                next
              end
              line += 1
              row = {}
              if self.ignore_blank_line and raw_row.empty?
                lines_skipped += 1
                next
              end
              validate_row(raw_row, line, file)
              raw_row.each_with_index do |value, index|
                f = fields[index]
                row[f.name] = value
              end
              yield row
            end
          end
        end
      end

      # Get an array of defined worksheets
      def worksheets
        @worksheets ||= []
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
      
      private
      def configure
        source.definition[:worksheets].each do |worksheet|
          if Integer(worksheet)
            worksheets << worksheet.to_i
          else
            raise DefinitionError, "Each worksheet definition must be an integer"
          end
        end unless source.definition[:worksheets].nil?

        self.ignore_blank_line = source.definition[:ignore_blank_line]

        source.definition[:fields].each do |options|
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

module ETL #:nodoc:
  module Control #:nodoc:
    # A File source.
    class FileSource < Source
      # The number of lines to skip, default is 0
      attr_accessor :skip_lines
      
      # Accessor for the underlying parser
      attr_accessor :parser
      
      # The source file
      attr_accessor :file
      
      # Initialize the source
      #
      # Configuration options:
      # * <tt>:file</tt>: The source file
      # * <tt>:parser</tt>: One of the following: a parser name as a String or
      #   symbol, a class which extends from Parser, a Hash with :name and 
      #   optionally an :options key. Whether or not the parser uses the 
      #   options is dependent on which parser is used. See the documentation 
      #   for each parser for information on what options it accepts.
      # * <tt>:skip_lines</tt>: The number of lines to skip (defaults to 0)
      # * <tt>:store_locally</tt>: Set to false to not store a copy of the 
      #   source data locally for archival
      def initialize(control, configuration, definition)
        super
        configure
      end
      
      # Get a String identifier for the source
      def to_s
        file
      end
      
      # Get the local storage directory
      def local_directory
        File.join(local_base, File.basename(file, File.extname(file)))
      end
      
      # Returns each row from the source
      def each
        count = 0
        copy_sources if store_locally
        @parser.each do |row|
          if ETL::Engine.offset && count < ETL::Engine.offset
            count += 1
          else
            row = ETL::Row[row]
            row.source = self
            yield row
          end
        end
      end
      
      private
      # Copy source data to a local directory structure
      def copy_sources
        sequence = 0
        path = Pathname.new(file)
        path = path.absolute? ? path : Pathname.new(File.dirname(control.file)) + path
        Pathname.glob(path).each do |f|
          next if f.directory?
          lf = local_file(sequence)
          FileUtils.cp(f, lf)
          File.open(local_file_trigger(lf), 'w') {|f| }
          sequence += 1
        end
      end
      
      # Configure the source
      def configure
        @file = configuration[:file]
        case configuration[:parser]
        when Class
          @parser = configuration[:parser].new(self)
        when String, Symbol
          @parser = ETL::Parser::Parser.class_for_name(configuration[:parser]).new(self)
        when Hash
          name = configuration[:parser][:name]
          options = configuration[:parser][:options]
          @parser = ETL::Parser::Parser.class_for_name(name).new(self, options)
        else
          raise ControlError, "Configuration option :parser must be a Class, String or Symbol"
        end
        @skip_lines = configuration[:skip_lines] ||= 0
      end
    end
  end
end
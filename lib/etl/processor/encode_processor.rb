require 'iconv'

module ETL #:nodoc:
  module Processor #:nodoc:
    # The encode processor uses Iconv to convert a file from one encoding (eg: utf-8) to another (eg: latin1), line by line.
    class EncodeProcessor < ETL::Processor::Processor

      # The file to load from
      attr_reader :source_file
      # The file to write to
      attr_reader :target_file
      # The source file encoding
      attr_reader :source_encoding
      # The target file encoding
      attr_reader :target_encoding

      # Initialize the processor.
      #
      # Configuration options:
      # * <tt>:source_file</tt>: The file to load data from
      # * <tt>:source_encoding</tt>: The source file encoding (eg: 'latin1','utf-8'), as supported by Iconv
      # * <tt>:target_file</tt>: The file to write data to
      # * <tt>:target_encoding</tt>: The target file encoding
      def initialize(control, configuration)
        super
        raise ControlError, "Source file must be specified" if configuration[:source_file].nil?
        raise ControlError, "Target file must be specified" if configuration[:target_file].nil?

        self.source_file = configuration[:source_file]
        self.target_file = configuration[:target_file]

        @source_encoding = configuration[:source_encoding]
        @target_encoding = configuration[:target_encoding]
        raise ControlError, "Source and target file cannot currently point to the same file" if source_file == target_file
        begin
          @iconv = Iconv.new(target_encoding,source_encoding)
        rescue Iconv::InvalidEncoding
          raise ControlError, "Either the source encoding '#{source_encoding}' or the target encoding '#{target_encoding}' is not supported"
        end
      end

      def source_file=(file)
        @source_file = begin
          source_file = file.to_s

          if source_file.starts_with? '/'
            source_file
          else
            File.join(File.dirname(control.file), source_file)
          end
        end
      end

      def target_file=(file)
        @target_file = begin
          target_file = file.to_s

          if target_file.starts_with? '/'
            target_file
          else
            File.join(File.dirname(control.file), target_file)
          end
        end
      end

      # Execute the processor
      def process
        # operate line by line to handle large files without loading them in-memory
        # could be replaced by a system iconv call when available, for greater performance
        File.open(source_file) do |source|
          #puts "Opening #{target_file}"
          File.open(target_file,'w') do |target|
            source.each_line do |line|
              target << @iconv.iconv(line)
            end
          end
        end
      end
    end
  end
end

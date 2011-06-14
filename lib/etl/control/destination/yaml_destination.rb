require 'yaml'

module ETL #:nodoc:
  module Control #:nodoc:
    class YamlDestination < Destination
      attr_reader :file, :append, :only, :except
      # Initialize the object.
      # * <tt>control</tt>: The Control object
      # * <tt>configuration</tt>: The configuration map
      # * <tt>mapping</tt>: The output mapping
      #
      # Configuration options:
      # * <tt>:file<tt>: The file to write to (REQUIRED)
      # * <tt>:append</tt>: Set to true to append to the file (default is to overwrite)
      # * <tt>:only</tt>
      # * <tt>:except</tt>
      def initialize(control, configuration, mapping={})
        super
        @file = File.join(File.dirname(control.file), configuration[:file])
        @append = configuration[:append] ||= false
        @only = configuration[:only]
        @except = configuration[:except]
        raise ControlError, "the :only and :except options must be used seperately, do not specify both" if @only && @except
      end

      # Close the destination. This will flush the buffer and close the underlying stream or connection.
      def close
        flush
        f.close
      end

      # Flush the destination buffer
      def flush
        #puts "Flushing buffer (#{file}) with #{buffer.length} rows"
        buffer.flatten.each do |row|
          # check to see if this row's compound key constraint already exists
          # note that the compound key constraint may not utilize virtual fields
          next unless row_allowed?(row)
          # add any virtual fields
          add_virtuals!(row)

          yaml = {}
          row.each do |key, value|
            next if only && !only.include?(key)
            next if except && except.include?(key)

            case value
            when Date, Time, DateTime
              value = value.to_s(:db)
            end

            yaml[key] = value
          end
         
          # write the values
          YAML.dump(yaml, f)
        end
        f.flush
        buffer.clear
      end

      private
      # Get the open file stream
      def f
        @f ||= File.open(file, mode)
      end

      # Get the appropriate mode to open the file stream
      def mode
        append ? 'a' : 'w'
      end
    end
  end
end

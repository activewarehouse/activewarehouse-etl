module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform which decodes coded values
    class DecodeTransform < ETL::Transform::Transform
      attr_accessor :decode_table_path
      
      attr_accessor :decode_table_delimiter
      
      attr_accessor :default_value
      
      # Initialize the transformer
      #
      # Configuration options:
      # * <tt>:decode_table_path</tt>: The path to the decode table (defaults to 'decode.txt')
      # * <tt>:decode_table_delimiter</tt>: The decode table delimiter (defaults to ':')
      # * <tt>:default_value</tt>: The default value to use (defaults to 'No Value')
      def initialize(control, name, configuration={})
        super
        
        if configuration[:decode_table_path]
          configuration[:decode_table_path] = File.join(File.dirname(control.file), configuration[:decode_table_path])
        end
        
        @decode_table_path = (configuration[:decode_table_path] || 'decode.txt')
        @decode_table_delimiter = (configuration[:decode_table_delimiter] || ':')
        @default_value = (configuration[:default_value] || 'No Value')
      end
      
      # Transform the value
      def transform(name, value, row)
        decode_table[value] || default_value
      end
      
      # Get the decode table
      def decode_table
        unless @decode_table
          @decode_table = {}
          open(decode_table_path).each do |line|
            code, value = line.strip.split(decode_table_delimiter)
            if code && code.length > 0
              @decode_table[code] = value
            else
              @default_value = value
            end
          end
        end
        @decode_table
      end
    end
  end
end
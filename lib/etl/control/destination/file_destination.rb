# This source file contains the ETL::Control::FileDestination

module ETL #:nodoc:
  module Control #:nodoc:
    # File as the final destination.
    class FileDestination < Destination
      # The File to write to
      attr_reader :file
      
      # The output order
      attr_reader :order
      
      # Flag which indicates to append (default is to overwrite)
      attr_accessor :append
      
      # The separator
      attr_accessor :separator
      
      # The end of line marker
      attr_accessor :eol
      
      # The enclosure character
      attr_accessor :enclose
      
      # Initialize the object.
      # * <tt>control</tt>: The Control object
      # * <tt>configuration</tt>: The configuration map
      # * <tt>mapping</tt>: The output mapping
      # 
      # Configuration options:
      # * <tt>:file<tt>: The file to write to (REQUIRED)
      # * <tt>:append</tt>: Set to true to append to the file (default is to overwrite)
      # * <tt>:separator</tt>: Record separator (default is a comma)
      # * <tt>:eol</tt>: End of line marker (default is \n)
      # * <tt>:enclose</tt>: Enclosure character (default is none)
      # * <tt>:unique</tt>: Set to true to only write unique records
      # * <tt>:append_rows</tt>: Array of rows to append
      # 
      # Mapping options:
      # * <tt>:order</tt>: The order array
      def initialize(control, configuration, mapping={})
        super
        @file = File.join(File.dirname(control.file), configuration[:file])
        @append = configuration[:append] ||= false
        @separator = configuration[:separator] ||= ','
        @eol = configuration[:eol] ||= "\n"
        @enclose = configuration[:enclose]
        @unique = configuration[:unique]
        
        @order = mapping[:order] || order_from_source
        raise ControlError, "Order required in mapping" unless @order
      end
      
      # Close the destination. This will flush the buffer and close the underlying stream or connection.
      def close
        buffer << append_rows if append_rows
        flush
        f.close
      end
      
      # Flush the destination buffer
      def flush
        #puts "Flushing buffer (#{file}) with #{buffer.length} rows"
        buffer.flatten.each do |row|
          #puts "row change type: #{row.change_type}"
          # check to see if this row's compound key constraint already exists
          # note that the compound key constraint may not utilize virtual fields
          next unless row_allowed?(row)
          
          # add any virtual fields
          add_virtuals!(row)
          
          # collect all of the values using the order designated in the configuration
          values = order.collect do |name|
            value = row[name]
            case value
            when Date, Time, DateTime
              value.to_s(:db)
            else
              value.to_s
            end
          end
          
          values.collect! { |v| v.gsub(/\\/, '\\\\\\\\')}
          values.collect! { |v| v.gsub(separator, "\\#{separator}")}
          values.collect! { |v| v.gsub(/\n|\r/, '')}
          
          # enclose the value if required
          if !enclose.nil?
            values.collect! { |v| enclose + v.gsub(/(#{enclose})/, '\\\\\1') + enclose }
          end
          
          # write the values joined by the separator defined in the configuration
          f.write(values.join(separator))
          
          # write the end-of-line
          f.write(eol)
        end
        f.flush
        buffer.clear
        #puts "After flush there are #{buffer.length} rows"
      end
      
      private
      # Get the open file stream
      def f
        @f ||= open(file, mode)
      end
      
      def options
        @options ||= {
          :col_sep => separator,
          :row_sep => eol,
          :force_quotes => !enclose.nil?
        }
      end
      
      # Get the appropriate mode to open the file stream
      def mode
        append ? 'a' : 'w'
      end
    end
  end
end
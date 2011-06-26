# This source file contains the ETL::Control::CsvDestination

module ETL #:nodoc:
  module Control #:nodoc:
    # CSV File as the final destination.
    class CsvDestination < Destination
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
      # * <tt>:enclose</tt>: Set to true of false
      # * <tt>:unique</tt>: Set to true to only write unique records
      # * <tt>:append_rows</tt>: Array of rows to append
      # 
      # Mapping options:
      # * <tt>:order</tt>: The order array
      def initialize(control, configuration, mapping={})
        super
        path = Pathname.new(configuration[:file])
        @file = path.absolute? ? path : Pathname.new(File.dirname(File.expand_path(control.file))) + path
        @append = configuration[:append] ||= false
        @separator = configuration[:separator] ||= ','
        @eol = configuration[:eol] ||= "\n"
        @enclose = true & configuration[:enclose]
        @unique = configuration[:unique] ? configuration[:unique] + scd_required_fields : configuration[:unique]
        @unique.uniq! unless @unique.nil?
        @order = mapping[:order] ? mapping[:order] + scd_required_fields : order_from_source
        @order.uniq! unless @order.nil?
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
          
          f << values
        end
        f.flush
        buffer.clear
        #puts "After flush there are #{buffer.length} rows"
      end
      
      private
      # Get the open file stream
      def f
        @f ||= FasterCSV.open(file, mode, options)
      end
      
      def options
        @options ||= {
          :col_sep => separator,
          :row_sep => eol,
          :force_quotes => enclose
        }
      end
      
      # Get the appropriate mode to open the file stream
      def mode
        append ? 'a' : 'w'
      end
    end
  end
end

optional_require 'spreadsheet'

module ETL
  module Control
    # Excel as the final destination.
    class ExcelDestination < Destination
      # The File to write to
      attr_reader :file
      
      # The output order
      attr_reader :order
      
      # Flag which indicates to append (default is to overwrite)
      attr_accessor :append
      
      # Initialize the object.
      # * <tt>control</tt>: The Control object
      # * <tt>configuration</tt>: The configuration map
      # * <tt>mapping</tt>: The output mapping
      # 
      # Configuration options:
      # * <tt>:file<tt>: The file to write to (REQUIRED)
      # * <tt>:append</tt>: Set to true to append to the file (default is to overwrite)
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
        book.write(file)
      end

   # Flush the destination buffer
      def flush
        #puts "Flushing buffer (#{file}) with #{buffer.length} rows"
        buffer.flatten.each_with_index do |row, index|
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
          
          # write the values
          sheet.insert_row(index, values)
        end
        buffer.clear
        #puts "After flush there are #{buffer.length} rows"
      end
      
      private
      # Get the open file excel
      def book
        @book ||= ( append ? Spreadsheet.open(file) : Spreadsheet::Workbook.new(file) )
      end

      private
      # Get the open sheet
      def sheet
        @sheet ||= ( append ? book.worksheet(0) : book.create_worksheet() )
      end
    end
  end
end

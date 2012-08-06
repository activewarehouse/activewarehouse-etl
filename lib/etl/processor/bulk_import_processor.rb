module ETL #:nodoc:
  module Processor #:nodoc:
    # Processor which is used to bulk import data into a target database. The
    # underlying database driver from ActiveRecord must support the methods
    # +bulk_load+ method.
    class BulkImportProcessor < ETL::Processor::Processor
      
      # The file to load from
      attr_reader :file
      # The target database
      attr_reader :target
      # The table name
      attr_reader :table
      # Set to true to truncate
      attr_reader :truncate
      # Array of symbols representing the column load order
      attr_reader :columns
      # The field separator (defaults to a comma)
      attr_accessor :field_separator
      # The field enclosure (defaults to nil)
      attr_accessor :field_enclosure
      # The line separator (defaults to a newline)
      attr_accessor :line_separator
      # The string that indicates a NULL (defaults to an empty string)
      attr_accessor :null_string
      # boolean that indicates disable keys before, then enable after load (MySql only optimization)
      attr_accessor :disable_keys
      # replace existing records, not just insert
      attr_accessor :replace
       
      # Initialize the processor.
      #
      # Configuration options:
      # * <tt>:file</tt>: The file to load data from
      # * <tt>:target</tt>: The target database
      # * <tt>:table</tt>: The table name
      # * <tt>:truncate</tt>: Set to true to truncate before loading
      # * <tt>:columns</tt>: The columns to load in the order they appear in
      #   the bulk data file
      # * <tt>:field_separator</tt>: The field separator. Defaults to a comma
      # * <tt>:line_separator</tt>: The line separator. Defaults to a newline
      # * <tt>:field_enclosure</tt>: The field enclosure charcaters
      # * <tt>:disable_keys</tt>: Set to true to disable keys before, then enable after load (MySql only optimization)
      def initialize(control, configuration)
        super
        @target = configuration[:target]
        path = Pathname.new(configuration[:file])
        @file = path.absolute? ? path : Pathname.new(File.dirname(File.expand_path(control.file))) + path

        @table = configuration[:table]
        @truncate = configuration[:truncate] ||= false
        @columns = configuration[:columns]
        @field_separator = (configuration[:field_separator] || ',')
        @line_separator = (configuration[:line_separator] || "\n")
        @null_string = (configuration[:null_string] || "")
        @field_enclosure = configuration[:field_enclosure]
        @disable_keys = configuration[:disable_keys] || false
        @replace = configuration[:replace] || false
        
        raise ControlError, "Target must be specified" unless @target
        raise ControlError, "Table must be specified" unless @table
      end
      
      # Execute the processor
      def process
        return if ETL::Engine.skip_bulk_import
        return if File.size(file) == 0
        
        conn = ETL::Engine.connection(target)
        conn.transaction do
          conn.truncate(table_name) if truncate
          options = {}
          options[:columns] = columns
          
          options[:disable_keys] = true if disable_keys
          options[:replace] = true if replace
          
          if field_separator || field_enclosure || line_separator || null_string
            options[:fields] = {}
            options[:fields][:null_string] = null_string if null_string
            options[:fields][:delimited_by] = field_separator if field_separator
            options[:fields][:enclosed_by] = field_enclosure if field_enclosure
            options[:fields][:terminated_by] = line_separator if line_separator
          end
          options[:local_infile] = true
          conn.bulk_load(file, table_name, options)
        end
      end
      
      def table_name
        ETL::Engine.table(table, ETL::Engine.connection(target))
      end
    end
  end
end

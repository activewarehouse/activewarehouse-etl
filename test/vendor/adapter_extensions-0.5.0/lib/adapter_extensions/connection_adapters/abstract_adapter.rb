# This source file contains extensions to the abstract adapter.
module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    # Extensions to the AbstractAdapter. In some cases a default implementation
    # is provided, in others it is adapter-dependent and the method will
    # raise a NotImplementedError if the adapter does not implement that method
    class AbstractAdapter
      # Truncate the specified table
      def truncate(table_name)
        execute("TRUNCATE TABLE #{table_name}")
      end
      
      # Bulk loading interface. Load the data from the specified file into the
      # given table. Note that options will be adapter-dependent.
      def bulk_load(file, table_name, options={})
        raise ArgumentError, "#{file} does not exist" unless File.exist?(file)
        raise ArgumentError, "#{table_name} does not exist" unless tables.include?(table_name)
        do_bulk_load(file, table_name, options)
      end
      
      # SQL select into statement constructs a new table from the results
      # of a select. It is used to select data from a table and create a new
      # table with its result set at the same time.  Note that this method
      # name does not necessarily match the implementation.  E.g. MySQL's
      # version of this is 'CREATE TABLE ... AS SELECT ...'
      def support_select_into_table?
        false
      end
      
      # Add a chunk of SQL to the given query that will create a new table and
      # execute the select into that table.
      def add_select_into_table(new_table_name, sql_query)
        raise NotImplementedError, "add_select_into_table is an abstract method"
      end
      
      protected
      
      # for subclasses to implement
      def do_bulk_load(file, table_name, options={})
        raise NotImplementedError, "do_bulk_load is an abstract method"
      end
    end
  end
end
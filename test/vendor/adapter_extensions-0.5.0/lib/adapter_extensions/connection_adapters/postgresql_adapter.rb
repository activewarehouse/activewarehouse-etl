# Source code for the PostgreSQLAdapter extensions.
module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    # Adds new functionality to ActiveRecord PostgreSQLAdapter.
    class PostgreSQLAdapter < AbstractAdapter
      def support_select_into_table?
        true
      end
      
      # Inserts an INTO table_name clause to the sql_query.
      def add_select_into_table(new_table_name, sql_query)
        sql_query.sub(/FROM/i, "INTO #{new_table_name} FROM")
      end
      
      # Copy the specified table.
      def copy_table(old_table_name, new_table_name)
        execute add_select_into_table(new_table_name, "SELECT * FROM #{old_table_name}")
      end
    
      protected
      # Call +bulk_load+, as that method wraps this method.
      # 
      # Bulk load the data in the specified file.
      #
      # Options:
      # * <tt>:ignore</tt> -- Ignore the specified number of lines from the source file. In the case of PostgreSQL
      #   only the first line will be ignored from the source file regardless of the number of lines specified.
      # * <tt>:columns</tt> -- Array of column names defining the source file column order
      # * <tt>:fields</tt> -- Hash of options for fields:
      # * <tt>:delimited_by</tt> -- The field delimiter
      # * <tt>:null_string</tt> -- The string that should be interpreted as NULL (in addition to \N)
      # * <tt>:enclosed_by</tt> -- The field enclosure
      def do_bulk_load(file, table_name, options={})
        q = "COPY #{table_name} "
        q << "(#{options[:columns].join(',')}) " if options[:columns]
        q << "FROM '#{File.expand_path(file)}' "
        if options[:fields]
          q << "WITH "
          q << "DELIMITER '#{options[:fields][:delimited_by]}' " if options[:fields][:delimited_by]
          q << "NULL '#{options[:fields][:null_string]}'" if options[:fields][:null_string]
          if options[:fields][:enclosed_by] || options[:ignore] && options[:ignore] > 0
            q << "CSV "
            q << "HEADER " if options[:ignore] && options[:ignore] > 0
            q << "QUOTE '#{options[:fields][:enclosed_by]}' " if options[:fields][:enclosed_by]
          end
        end
        
        execute(q)
      end
    end
  end
end
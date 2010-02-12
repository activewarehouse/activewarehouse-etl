# Source code for the SQLServerAdapter extensions.
module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    # Adds new functionality to ActiveRecord SQLServerAdapter.
    class SQLServerAdapter < AbstractAdapter
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
      # Bulk load the data in the specified file. This implementation relies
      # on bcp being in your PATH.
      #
      # Options:
      # * <tt>:ignore</tt> -- Ignore the specified number of lines from the source file
      # * <tt>:columns</tt> -- Array of column names defining the source file column order
      # * <tt>:fields</tt> -- Hash of options for fields:
      # * <tt>:delimited_by</tt> -- The field delimiter
      # * <tt>:enclosed_by</tt> -- The field enclosure
      def do_bulk_load(file, table_name, options={})
        env_name = options[:env] || RAILS_ENV
        config = ActiveRecord::Base.configurations[env_name]
          puts "Loading table \"#{table_name}\" from file \"#{filename}\""
          cmd = "bcp \"#{config['database']}.dbo.#{table_name}\" in " +
                "\"#{filename}\" -S \"#{config['host']}\" -c " +
                "-t \"#{options[:delimited_by]}\" -b10000 -a8192 -q -E -U \"#{config['username']}\" " +
                "-P \"#{config['password']}\" -e \"#{filename}.in.errors\""
          `#{cmd}`
      end
    end
  end
end
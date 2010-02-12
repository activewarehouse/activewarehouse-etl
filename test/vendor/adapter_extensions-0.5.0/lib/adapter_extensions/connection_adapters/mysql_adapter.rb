# Source code for the MysqlAdapter extensions.
module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    # Adds new functionality to ActiveRecord MysqlAdapter.
    class MysqlAdapter < AbstractAdapter
    
      def support_select_into_table?
        true
      end
      
      # Inserts an INTO table_name clause to the sql_query.
      def add_select_into_table(new_table_name, sql_query)
        "CREATE TABLE #{new_table_name} " + sql_query
      end
      
      # Copy the specified table.
      def copy_table(old_table_name, new_table_name)
        transaction do
          execute "CREATE TABLE #{new_table_name} LIKE #{old_table_name}"
          execute "INSERT INTO #{new_table_name} SELECT * FROM #{old_table_name}"
        end
      end
    
      protected
      # Call +bulk_load+, as that method wraps this method.
      # 
      # Bulk load the data in the specified file. This implementation always uses the LOCAL keyword
      # so the file must be found locally, not on the remote server, to be loaded.
      #
      # Options:
      # * <tt>:ignore</tt> -- Ignore the specified number of lines from the source file
      # * <tt>:columns</tt> -- Array of column names defining the source file column order
      # * <tt>:fields</tt> -- Hash of options for fields:
      # * <tt>:delimited_by</tt> -- The field delimiter
      # * <tt>:enclosed_by</tt> -- The field enclosure
      def do_bulk_load(file, table_name, options={})
        return if File.size(file) == 0

        # an unfortunate hack - setting the bulk load option after the connection has been 
        # established does not seem to have any effect, and since the connection is made when 
        # active-record is loaded, there's no chance for us to sneak it in earlier. So we 
        # disconnect, set the option, then reconnect - fortunately, this only needs to happen once.
        unless @bulk_load_enabled
          disconnect!
          @connection.options(Mysql::OPT_LOCAL_INFILE, true)
          connect
          @bulk_load_enabled = true
        end

        q = "LOAD DATA LOCAL INFILE '#{file}' INTO TABLE #{table_name}"
        if options[:fields]
          q << " FIELDS"
          q << " TERMINATED BY '#{options[:fields][:delimited_by]}'" if options[:fields][:delimited_by]
          q << " ENCLOSED BY '#{options[:fields][:enclosed_by]}'" if options[:fields][:enclosed_by]
        end
        q << " IGNORE #{options[:ignore]} LINES" if options[:ignore]
        q << " (#{options[:columns].join(',')})" if options[:columns]
        execute(q)
      end
      
    end
  end
end
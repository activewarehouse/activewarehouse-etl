module ETL #:nodoc:
  
  class Base < ActiveRecord::Base
  end
  
  # The main ETL engine clas
  class Engine
    include ETL::Util
    
    class << self
      # Initialization that is run when a job is executed.
      # 
      # Options:
      # * <tt>:limit</tt>: Limit the number of records returned from sources
      # * <tt>:offset</tt>: Specify the records for data from sources
      # * <tt>:log_write_mode</tt>: If true then the log will write, otherwise it will append
      # * <tt>:skip_bulk_import</tt>: Set to true to skip bulk import
      # * <tt>:read_locally</tt>: Set to true to read from the local cache
      # * <tt>:rails_root</tt>: Set to the rails root to boot rails
      def init(options={})
        unless @initialized
          puts "initializing ETL engine\n\n"
          @limit = options[:limit]
          @offset = options[:offset]
          @log_write_mode = 'w' if options[:newlog]
          @skip_bulk_import = options[:skip_bulk_import]
          @read_locally = options[:read_locally]
          @rails_root = options[:rails_root]
          
          require File.join(@rails_root, 'config/environment') if @rails_root
          options[:config] ||= 'database.yml'
          options[:config] = 'config/database.yml' unless File.exist?(options[:config])
          database_configuration = YAML::load(ERB.new(IO.read(options[:config])).result + "\n")
          ActiveRecord::Base.configurations.merge!(database_configuration)
          ETL::Base.configurations = HashWithIndifferentAccess.new(database_configuration)
          #puts "configurations in init: #{ActiveRecord::Base.configurations.inspect}"
          
          require 'etl/execution'
          ETL::Execution::Base.establish_connection :etl_execution
          ETL::Execution::Execution.migrate

          @initialized = true
        end
      end
      
      # Process the specified file. Acceptable values for file are:
      # * Path to a file
      # * File object
      # * ETL::Control::Control instance
      # * ETL::Batch::Batch instance
      #
      # The process command will accept either a .ctl or .ctl.rb for a Control file or a .ebf
      #  or .ebf.rb for an ETL Batch File.
      def process(file)
        new().process(file)
      end
      
      attr_accessor :timestamped_log
      
      # Accessor for the log write mode. Default is 'a' for append.
      attr_accessor :log_write_mode
      def log_write_mode
        @log_write_mode ||= 'a'
      end
      
      # A logger for the engine
      attr_accessor :logger
      
      def logger #:nodoc:
        unless @logger
          if timestamped_log
            @logger = Logger.new("etl_#{timestamp}.log")
          else
            @logger = Logger.new(File.open('etl.log', log_write_mode))
          end
          @logger.level = Logger::WARN
          @logger.formatter = Logger::Formatter.new
        end
        @logger
      end
      
      # Get a timestamp value as a string
      def timestamp
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      # exit code to be passed to the command line
      attr_accessor :exit_code

      # The current source
      attr_accessor :current_source

      # The current source row
      attr_accessor :current_source_row
      
      # The current destination
      attr_accessor :current_destination
      
      # Set to true to activate realtime activity. This will cause certain 
      # information messages to be printed to STDOUT
      attr_accessor :realtime_activity
      
      # Accessor for the total number of rows read from sources
      attr_accessor :rows_read
      def rows_read
        @rows_read ||= 0
      end
      
      # Accessor for the total number of rows processed
      attr_accessor :rows_written
      def rows_written
        @rows_written ||= 0
      end
      
      # Access the current ETL::Execution::Job instance
      attr_accessor :job
      
      # Access the current ETL::Execution::Batch instance
      attr_accessor :batch
      
      # The limit on rows to load from the source, useful for testing the ETL
      # process prior to executing the entire batch. Default value is nil and 
      # indicates that there is no limit
      attr_accessor :limit
      
      # The offset for the source to begin at, useful for testing the ETL
      # process prior to executing the entire batch. Default value is nil and
      # indicates that there is no offset
      attr_accessor :offset
      
      # Set to true to skip all bulk importing
      attr_accessor :skip_bulk_import
      
      # Set to true to read locally from the last source cache files
      attr_accessor :read_locally
      
      # Accessor for the average rows per second processed
      attr_accessor :average_rows_per_second
      
      # Get a named connection
      def connection(name)
        logger.debug "Retrieving connection #{name}"
        conn = connections[name] ||= establish_connection(name)
        #conn.verify!(ActiveRecord::Base.verification_timeout)
        conn.reconnect! unless conn.active?
        conn
      end
      
      # Set to true to use temp tables
      attr_accessor :use_temp_tables
      
      # Get a registry of temp tables
      def temp_tables
        @temp_tables ||= {}
      end
      
      # Called when a batch job finishes, allowing for cleanup to occur
      def finish
        temp_tables.each do |temp_table, mapping|
          actual_table = mapping[:table]
          #puts "move #{temp_table} to #{actual_table}"
          conn = mapping[:connection]
          conn.transaction do
            conn.rename_table(actual_table, "#{actual_table}_old")
            conn.rename_table(temp_table, actual_table)
            conn.drop_table("#{actual_table}_old")
          end
        end
      end
      
      # Return true if using temp tables
      def use_temp_tables?
        use_temp_tables ? true : false
      end
      
      # Modify the table name if necessary
      def table(table_name, connection)
        if use_temp_tables?
          temp_table_name = "tmp_#{table_name}"

          if temp_tables[temp_table_name].nil?
            # Create the temp table and add it to the mapping
            begin connection.drop_table(temp_table_name); rescue; end
            connection.copy_table(table_name, temp_table_name)
            temp_tables[temp_table_name] = {
              :table => table_name,
              :connection => connection
            }
          end

          temp_table_name
        else
          table_name
        end
      end
      
      protected
      # Hash of database connections that can be used throughout the ETL 
      # process
      def connections
        @connections ||= {}
      end
      
      # Establish the named connection and return the database specific connection
      def establish_connection(name)
        raise ETL::ETLError, "Connection with no name requested. Is there a missing :target parameter somewhere?" if name.blank?
        
        logger.debug "Establishing connection to #{name}"
        conn_config = ETL::Base.configurations[name.to_s]
        raise ETL::ETLError, "Cannot find connection named #{name.inspect}" unless conn_config
        connection_method = "#{conn_config['adapter']}_connection"
        ETL::Base.send(connection_method, conn_config)
      end
    end # class << self
    
    # Say the specified message, with a newline
    def say(message)
      say_without_newline(message + "\n")
    end
    
    # Say the specified message without a newline
    def say_without_newline(message)
      if ETL::Engine.realtime_activity
        $stdout.print message
        $stdout.flush
      end
    end
    
    # Say the message on its own line
    def say_on_own_line(message)
      say("\n" + message)
    end
    
    # Array of errors encountered during execution of the ETL process
    def errors
      @errors ||= []
    end

    # First attempt at centralizing error notifications
    def track_error(control, msg)
      errors << msg
      control.error_handlers.each do |handler|
        handler.call(msg)
      end
    end
    
    # Get a Hash of benchmark values where each value represents the total
    # amount of time in seconds spent processing in that portion of the ETL
    # pipeline. Keys include:
    # * <tt>:transforms</tt>
    # * <tt>:after_reads</tt>
    # * <tt>:before_writes</tt>
    # * <tt>:writes</tt>
    def benchmarks
      @benchmarks ||= {
        :transforms => 0,
        :after_reads => 0,
        :before_writes => 0,
        :writes => 0,
      }
    end
  
    # Process a file, control object or batch object. Acceptable values for 
    # file are:
    # * Path to a file
    # * File object
    # * ETL::Control::Control instance
    # * ETL::Batch::Batch instance
    def process(file)
      case file
        when String
          process(File.new(file))
        when File
          case file.path
            when /\.ctl(\.rb)?$/; process_control(file)
            when /\.ebf(\.rb)?$/; process_batch(file)
            else raise RuntimeError, "Unsupported file type - #{file.path}"
          end
        when ETL::Control::Control
          process_control(file)
        when ETL::Batch::Batch
          process_batch(file)
      else
        raise RuntimeError, "Process object must be a String, File, Control 
        instance or Batch instance"
      end
    end
    
    protected
    # Process the specified batch file
    def process_batch(batch)
      batch = ETL::Batch::Batch.resolve(batch, self)
      say "Processing batch #{batch.file}"
    
      ETL::Engine.batch = ETL::Execution::Batch.create!(
        :batch_file => batch.file,
        :status => 'executing'
      )
      
      batch.execute
      
      ETL::Engine.batch.completed_at = Time.now
      ETL::Engine.batch.status = (errors.length > 0 ? 'completed with errors' : 'completed')
      ETL::Engine.batch.save!
    end
    
    # Process the specified control file
    def process_control(control)
      control = ETL::Control::Control.resolve(control)
      say_on_own_line "Processing control #{control.file}"
      
      ETL::Engine.job = ETL::Execution::Job.new.tap do |job|
        job.control_file = control.file
        job.status = 'executing'
        job.batch_id = ETL::Engine.batch ? ETL::Engine.batch.id : nil
        job.save!
      end

      execute_dependencies(control)
      
      start_time = Time.now
      pre_process(control)
      sources = control.sources
      destinations = control.destinations
      
      say "Skipping bulk import" if Engine.skip_bulk_import
      
      sources.each do |source|
        Engine.current_source = source
        Engine.logger.debug "Processing source #{source.inspect}"
        say "Source: #{source}"
        say "Limiting enabled: #{Engine.limit}" if Engine.limit != nil
        say "Offset enabled: #{Engine.offset}" if Engine.offset != nil
        source.each_with_index do |row, index|
          # Break out of the row loop if the +Engine.limit+ is specified and 
          # the number of rows read exceeds that value.
          if Engine.limit != nil && Engine.rows_read >= Engine.limit
            puts "Reached limit of #{Engine.limit}"
            break
          end
          
          Engine.logger.debug "Row #{index}: #{row.inspect}"
          Engine.rows_read += 1
          Engine.current_source_row = index + 1
          say_without_newline "." if Engine.realtime_activity && index > 0 && index % 1000 == 0
          
          # At this point a single row may be turned into multiple rows via row 
          # processors all code after this line should work with the array of 
          # rows rather than the single row
          rows = [row]
          
          t = Benchmark.realtime do
            begin
              Engine.logger.debug "Processing after read"
              control.after_read_processors.each do |processor|
                processed_rows = []
                rows.each do |row|
                  processed_rows << processor.process(row) unless empty_row?(row)
                end
                rows = processed_rows.flatten.compact
              end
            rescue => e
              msg = "Error processing rows after read from #{Engine.current_source} on line #{Engine.current_source_row}: #{e}"
              # TODO - track more information: row if possible, full exception...
              track_error(control, msg)
              Engine.logger.error(msg)
              e.backtrace.each { |line| Engine.logger.error(line) }
              exceeded_error_threshold?(control) ? break : next
            end
          end
          benchmarks[:after_reads] += t unless t.nil?
          
          t = Benchmark.realtime do
            begin
              Engine.logger.debug "Executing transforms"
              rows.each do |row|
                # only do the transform if there is a row
                unless empty_row?(row)
                  control.transforms.each do |transform|
                    name = transform.name.to_sym
                    row[name] = transform.transform(name, row[name], row)
                  end
                end
              end
            rescue ResolverError => e
              Engine.logger.error(e.message)
              track_error(control, e.message)
            rescue => e
              msg = "Error transforming from #{Engine.current_source} on line #{Engine.current_source_row}: #{e}"
              track_error(control, msg)
              Engine.logger.error(msg)
              e.backtrace.each { |line| Engine.logger.error(line) }
            ensure
              begin
                exceeded_error_threshold?(control) ? break : next
              rescue => inner_error
                puts inner_error
              end
            end
          end
          benchmarks[:transforms] += t unless t.nil?
          
          t = Benchmark.realtime do
            begin
              # execute row-level "before write" processing
              Engine.logger.debug "Processing before write"
              control.before_write_processors.each do |processor|
                processed_rows = []
                rows.each do |row|
                  processed_rows << processor.process(row) unless empty_row?(row)
                end
                rows = processed_rows.flatten.compact
              end
            rescue => e
              msg = "Error processing rows before write from #{Engine.current_source} on line #{Engine.current_source_row}: #{e}"
              track_error(control, msg)
              Engine.logger.error(msg)
              e.backtrace.each { |line| Engine.logger.error(line) }
              exceeded_error_threshold?(control) ? break : next
            end
          end
          benchmarks[:before_writes] += t unless t.nil?
          
          t = Benchmark.realtime do
            begin
              # write the row to the destination
              destinations.each_with_index do |destination, index|
                Engine.current_destination = destination
                rows.each do |row|
                  destination.write(row)
                  Engine.rows_written += 1 if index == 0
                end
              end
            rescue => e
              msg = "Error writing to #{Engine.current_destination}: #{e}"
              track_error(control, msg)
              Engine.logger.error msg
              e.backtrace.each { |line| Engine.logger.error(line) }
              exceeded_error_threshold?(control) ? break : next
            end
          end
          benchmarks[:writes] += t unless t.nil?
        end
        
        if exceeded_error_threshold?(control)
          say_on_own_line "Exiting due to exceeding error threshold: #{control.error_threshold}"
          ETL::Engine.exit_code = 1
        end
        
      end
      
      destinations.each do |destination|
        destination.close
      end
      
      say_on_own_line "Executing before post-process screens"
      begin
        execute_screens(control)
      rescue FatalScreenError => e
        say "Fatal screen error during job execution: #{e.message}"
        ETL::Engine.exit_code = 2
      rescue ScreenError => e
        say "Screen error during job execution: #{e.message}"
        return
      else
        say "Screens passed"
      end
      
      post_process(control)
      
      if sources.length > 0
        say_on_own_line "Read #{Engine.rows_read} lines from sources"
      end
      if destinations.length > 0
        say "Wrote #{Engine.rows_written} lines to destinations"
      end

      say_on_own_line "Executing after post-process screens"
      begin
        execute_screens(control, :after_post_process)
      rescue FatalScreenError => e
        say "Fatal screen error during job execution: #{e.message}"
        ETL::Engine.exit_code = 3
      rescue ScreenError => e
        say "Screen error during job execution: #{e.message}"
        return
      else
        say "Screens passed"
      end

      say_on_own_line "Completed #{control.file} in #{distance_of_time_in_words(start_time)} with #{errors.length} errors."
      say "Processing average: #{Engine.average_rows_per_second} rows/sec)"
      
      say "Avg after_reads: #{Engine.rows_read/benchmarks[:after_reads]} rows/sec" if benchmarks[:after_reads] > 0
      say "Avg before_writes: #{Engine.rows_read/benchmarks[:before_writes]} rows/sec" if benchmarks[:before_writes] > 0
      say "Avg transforms: #{Engine.rows_read/benchmarks[:transforms]} rows/sec" if benchmarks[:transforms] > 0
      say "Avg writes: #{Engine.rows_read/benchmarks[:writes]} rows/sec" if benchmarks[:writes] > 0

      # say "Avg time writing execution records: #{ETL::Execution::Record.average_time_spent}"
      # 
      # ETL::Transform::Transform.benchmarks.each do |klass, t|
#         say "Avg #{klass}: #{Engine.rows_read/t} rows/sec"
#       end

      ETL::Engine.job.completed_at = Time.now
      ETL::Engine.job.status = (errors.length > 0 ? 'completed with errors' : 'completed')
      ETL::Engine.job.save!
    end
    
    def empty_row?(row)
      # unsure about why it should respond to :[] - keeping it just in case for the moment
      row.nil? || !row.respond_to?(:[])
    end
    
    private
    # Return true if the error threshold is exceeded
    def exceeded_error_threshold?(control)
      errors.length > control.error_threshold
    end
    
    # Execute all preprocessors
    def pre_process(control)
      Engine.logger.debug "Pre-processing #{control.file}"
      control.pre_processors.each do |processor|
        processor.process
      end
      Engine.logger.debug "Pre-processing complete"
    end
    
    # Execute all postprocessors
    def post_process(control)
      say_on_own_line "Executing post processes"
      Engine.logger.debug "Post-processing #{control.file}"
      control.post_processors.each do |processor|
        processor.process
      end
      Engine.logger.debug "Post-processing complete"
      say "Post-processing complete"
    end
    
    # Execute all dependencies
    def execute_dependencies(control)
      Engine.logger.debug "Executing dependencies"
      control.dependencies.flatten.each do |dependency|
        case dependency
        when Symbol
          f = dependency.to_s + '.ctl'
          Engine.logger.debug "Executing dependency: #{f}"
          say "Executing dependency: #{f}"
          process(f)
        when String
          Engine.logger.debug "Executing dependency: #{f}"
          say "Executing dependency: #{f}"
          process(dependency)
        else
          raise "Invalid dependency type: #{dependency.class}"
        end
      end
    end
    
    # Execute all screens
    def execute_screens(control, timing = :before_post_process)
      screens = case timing
        when :after_post_process
          control.after_post_process_screens
        else # default to before post-process screens
          control.screens
        end
      [:fatal,:error,:warn].each do |type|
        screens[type].each do |block|
          begin
            block.call
          rescue => e
            case type
            when :fatal
              raise FatalScreenError, e
            when :error
              raise ScreenError, e
            when :warn
              say "Screen warning: #{e}"
            end
          end
        end
      end
    end
  end
end

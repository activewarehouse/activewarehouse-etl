module ETL #:nodoc:
  module Control #:nodoc:
    # ETL source. Subclasses must implement the <tt>each</tt> method.
    class Source
      include Enumerable
      
      # The control object
      attr_accessor :control
      
      # The configuration Hash
      attr_accessor :configuration
      
      # The definition Hash
      attr_accessor :definition
      
      # Returns true if the source data should be stored locally for archival
      # Default behavior will return true.
      attr_accessor :store_locally
      
      class << self
        # Convert the name to a Source class.
        # 
        # For example if name is :database then this will return a 
        # DatabaseSource class
        def class_for_name(name)
          ETL::Control.const_get("#{name.to_s.camelize}Source")
        end
      end
      
      # Initialize the Source instance
      # * <tt>control</tt>: The control object
      # * <tt>configuration</tt>: The configuration hash
      # * <tt>definition</tt>: The source layout definition
      #
      # Configuration options:
      # * <tt>:store_locally</tt>: Set to false to not store source data
      #   locally (defaults to true)
      def initialize(control, configuration, definition)
        @control = control
        @configuration = configuration
        @definition = definition
        
        @store_locally = configuration[:store_locally] || true
      end
      
      # Get an array of errors that occur during reading from the source
      def errors
        @errors ||= []
      end
      
      # Get a timestamp value as a string
      def timestamp
        Engine.timestamp
      end
      
      # The base directory where local files are stored.
      attr_accessor :local_base
      
      # Get the local base, defaults to 'source_data'
      def local_base
        @local_base ||= 'source_data'
      end
      
      # The local directory for storing. This method must be overriden by 
      # subclasses
      def local_directory
        raise "local_directory method is abstract"
      end
      
      # Return the local file for storing the raw source data. Each call to 
      # this method will result in a timestamped file, so you cannot expect 
      # to call it multiple times and reference the same file
      # 
      # Optional sequence can be specified if there are multiple source files
      def local_file(sequence=nil)
        filename = timestamp.to_s
        filename += sequence.to_s if sequence
        
        local_dir = local_directory
        FileUtils.mkdir_p(local_dir)
        File.join(local_dir, "#{filename}.csv")
      end
      
      # Get the last fully written local file
      def last_local_file
        File.join(local_directory, File.basename(last_local_file_trigger, '.trig'))
      end
      
      # Get the last local file trigger
      def last_local_file_trigger
        Dir.glob(File.join(local_directory, '*.trig')).last
      end
      
      # Get the local trigger file that is used to indicate that the file has
      # been completely written
      def local_file_trigger(file)
        Pathname.new(file.to_s + '.trig')
      end
      
      # Return true if the source should read locally.
      def read_locally
        Engine.read_locally
      end
      
    end
  end
end

Dir[File.dirname(__FILE__) + "/source/*.rb"].each { |file| require(file) }
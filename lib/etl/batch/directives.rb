module ETL #:nodoc:
  module Batch #:nodoc:
    # Abstract base class for directives
    class Directive
      # Method to access the batch object
      attr_reader :batch
      
      # Initialize the directive with the given batch object
      def initialize(batch)
        @batch = batch
      end
      
      # Execute the directive
      def execute
        do_execute
      end
      
      protected
      # Implemented by subclasses
      def do_execute
        raise RuntimeError, "Directive must implement do_execute method"
      end
    end
    
    # Directive indicating that the specified ETL control file should be 
    # run
    class Run < Directive
      # The file to execute
      attr_reader :file
      
      # Initialize the directive with the given batch object and file
      def initialize(batch, file)
        super(batch)
        @file = file
      end
      
      protected
      # Execute the process
      def do_execute
        batch.engine.process(file)
      end
    end
    
    # Directive indicating temp tables should be used.
    class UseTempTables < Directive
      def initialize(batch)
        super(batch)
      end
      protected
      def do_execute
        ETL::Engine.use_temp_tables = true
      end
    end 
  end
end
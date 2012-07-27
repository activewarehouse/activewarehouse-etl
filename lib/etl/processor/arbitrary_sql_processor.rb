module ETL #:nodoc:
  module Processor #:nodoc:
    # Processor which is used to run arbitrary SQL, usually as a post process
    class ArbitrarySqlProcessor < ETL::Processor::Processor
      # The target database
      attr_reader :target
      # SQL to execute
      attr_reader :sql

      # Initialize the processor.
      #
      # Configuration options:
      # * <tt>:target</tt>: The target database
      # * <tt>:sql</tt>: SQL chunk to run
      def initialize(control, configuration)
        super
        @target = configuration[:target]
        @sql = configuration[:sql]
        
        raise ControlError, "Target must be specified" unless @target
        raise ControlError, "No SQL given" unless @sql
      end
      
      # Execute the processor
      def process
        conn = ETL::Engine.connection(target)
        conn.transaction do
          conn.execute(@sql)
        end
      end
    end
  end
end
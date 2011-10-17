module ETL #:nodoc:
  module Batch #:nodoc:

    # Directive indicating that the specified ETL control file should be run
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
        current_batch = ETL::Engine.batch
        batch.engine.process(file)

        job = ETL::Engine.batch
        if (job.kind_of? ETL::Execution::Batch and
            current_batch[:id] != job[:id])
          job[:batch_id] = current_batch[:id]
          job.save!
        end

        ETL::Engine.batch = current_batch
      end
    end

  end
end

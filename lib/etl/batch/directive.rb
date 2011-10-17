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

  end
end

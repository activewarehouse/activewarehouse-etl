module ETL #:nodoc:
  module Processor #:nodoc:
    # Base class for pre and post processors. Subclasses must implement the +process+ method.
    class Processor
      def initialize(control, configuration)
        @control = control
        @configuration = configuration
        after_initialize if respond_to?(:after_initialize)
      end
      protected
      # Get the control object
      def control
        @control
      end
      # Get the configuration Hash
      def configuration
        @configuration
      end
      # Get the engine logger
      def log
        Engine.logger
      end
    end
  end
end
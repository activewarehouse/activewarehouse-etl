module ETL #:nodoc:
  module Batch #:nodoc:

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

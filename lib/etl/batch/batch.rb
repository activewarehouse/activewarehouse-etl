module ETL #:nodoc:
  module Batch
    class Context
      attr_reader :batch
      
      class << self
        # Create a context that is used when evaluating the batch file
        def create(batch)
          Context.new(batch).get_binding
        end
      end
      
      def initialize(batch)
        @batch = batch
      end
      
      def file
        batch.file
      end
      
      def get_binding
        binding
      end
      
      def run(file)
        batch.run(File.dirname(self.file) + "/" + file)
      end
      
      def use_temp_tables(value=true)
        batch.use_temp_tables(value)
      end
      
    end
    class Batch
      attr_accessor :file
      attr_accessor :engine
      
      class << self
        # Resolve the given object to an ETL::Control::Control instance. Acceptable arguments
        # are:
        # * The path to a control file as a String
        # * A File object referencing the control file
        # * The ETL::Control::Control object (which will just be returned)
        #
        # Raises a ControlError if any other type is given
        def resolve(batch, engine)
          batch = do_resolve(batch)
          batch.engine = engine
          batch
        end
        
        protected
        def parse(batch_file)
          batch_file = batch_file.path if batch_file.instance_of?(File)
          batch = ETL::Batch::Batch.new(batch_file)
          eval(IO.readlines(batch_file).join("\n"), Context.create(batch), batch_file)
          batch
        end
        
        def do_resolve(batch)
          case batch
          when String
            ETL::Batch::Batch.parse(File.new(batch))
          when File
            ETL::Batch::Batch.parse(batch)
          when ETL::Batch::Batch
            batch
          else
            raise RuntimeError, "Batch must be a String, File or Batch object"
          end
        end
      end
      
      def initialize(file)
        @file = file
      end
      
      def run(file)
        directives << Run.new(self, file)
      end
      
      def use_temp_tables(value = true)
        directives << UseTempTables.new(self)
      end
      
      def execute
        engine.say "Executing batch"
        before_execute
        directives.each do |directive|
          directive.execute
        end
        engine.say "Finishing batch"
        after_execute
        engine.say "Batch complete"
      end
      
      def directives
        @directives ||= []
      end
      
      def before_execute
        
      end
      
      def after_execute
        ETL::Engine.finish # TODO: should be moved to the directive?
        ETL::Engine.use_temp_tables = false # reset the temp tables
      end
    end
  end
end
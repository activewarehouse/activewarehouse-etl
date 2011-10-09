module ETL #:nodoc:
  class Control #:nodoc:
    # The Context is passed to eval.
    class Context
      require 'test/unit/assertions'
      include Test::Unit::Assertions
      attr_reader :control

      class << self
        # Create a Context instance
        def create(control)
          Context.new(control).get_binding
        end
      end

      # Initialize the context
      def initialize(control)
        @control = control
      end

      # Get the control file
      def file
        control.file
      end

      # Set the allowed error threshold
      def set_error_threshold(error_threshold)
        control.error_threshold = error_threshold
      end

      # Define a list of control files that this file depends on. Those control
      # files will be executed prior to this control file. The list may
      # contain symbols that will be converted to file names by calling
      # to_s + '.ctl', or they may be strings in which case they will be used
      # as is
      def depends_on(*args)
        (dependencies << args).flatten!
      end

      # Get the defined dependencies
      def dependencies
        control.dependencies
      end

      # Define a source.
      def source(name, configuration={}, definition={})
        if configuration[:type]
          case configuration[:type]
          when Class
            source_class = configuration[:type]
            sources << source_class.new(self, configuration, definition)
          when String, Symbol
            source_class = ETL::Control::Source.class_for_name(configuration[:type])
            sources << source_class.new(self, configuration, definition)
          else
            if configuration[:type].is_a?(ETL::Control::Source)
              sources << configuration[:type]
            else
              raise ControlError, "Type must be a Class, String, Symbol or object extending ETL::Control::Source"
            end
          end
        else
          source_types.each do |source_type|
            if configuration[source_type]
              source_class = ETL::Control::Source.class_for_name(source_type)
              sources << source_class.new(self, configuration, definition)
              break
            end
          end
          raise ControlError, "A source was specified but no matching type was found" if sources.empty?
        end
      end

      # Get the defined source
      def sources
        control.sources
      end

      # Define a destination
      def destination(name, configuration={}, mapping={})
        if configuration[:type]
          case configuration[:type]
          when Class
            dest_class = configuration[:type]
            destinations << dest_class.new(self, configuration, mapping)
          when String, Symbol
            dest_class = ETL::Control::Destination.class_for_name(configuration[:type])
            destinations << dest_class.new(self, configuration, mapping)
          else
            if configuration[:type].is_a?(ETL::Control::Destination)
              destinations << configuration[:type]
            else
              raise ControlError, "Type must be a Class, String, Symbol or object extending ETL::Control::Destination"
            end
          end
        else
          destination_types.each do |dest_type|
            if configuration[dest_type]
              dest_class = ETL::Control::Destination.class_for_name(dest_type)
              destinations << dest_class.new(self, configuration, mapping)
              break
            end
          end
          raise ControlError, "A destination was specified but no matching destination type was found" if destinations.empty?
        end
      end

      # Get the defined destinations
      def destinations
        control.destinations
      end

      # Define a transform
      def transform(name, transformer=nil, configuration={}, &block)
        if transformer
          case transformer
          when String, Symbol
            class_name = "#{transformer.to_s.camelize}Transform"
            begin
              transform_class = ETL::Transform.const_get(class_name)
              transforms << transform_class.new(self, name, configuration)
            rescue NameError => e
              raise ControlError, "Unable to find transformer #{class_name}: #{e}"
            end
          when Class
            transforms << transformer.new(self, transformer.name, configuration)
          else
            #transformer.class.inspect
            if transformer.is_a?(ETL::Transform::Transform)
              Engine.logger.debug "Adding transformer #{transformer.inspect} for field #{name}"
              t = transformer.dup
              t.name = name
              transforms << t
            else
              raise ControlError, "Transformer must be a String, Symbol, Class or Transform instance"
            end
          end
        elsif block_given?
          transforms << ETL::Transform::BlockTransform.new(self, name, :block => block)
        else
          raise ControlError, "Either a transformer or a block must be specified"
        end
      end

      # Get the defined transforms
      def transforms
        control.transforms
      end

      # Define a before post-process screen block. The type argument must be
      # one of :fatal, :error or :warn
      def screen(type, &block)
        screens[type] << block
      end

      # Get the before post-process screen blocks
      def screens
        control.screens
      end

      # Define an after post-proces screen block. The type argument must be
      # one of :fatal, :error or :warn
      def after_post_process_screen(type, &block)
        after_post_process_screens[type] << block
      end

      # Get the after post-process screen blocks
      def after_post_process_screens
        control.after_post_process_screens
      end

      # Rename the source field to the destination field
      def rename(source, destination)
        after_read :rename, :source => source, :dest => destination
      end

      # Copy the source field to the destination field
      def copy(source, destination)
        after_read :copy_field, :source => source, :dest => destination
      end

      protected
      # This method is used to define a processor and insert into the specified processor
      # collection.
      def define_processor(name, processor_collection, configuration, proc)
        case name
        when String, Symbol, nil
          name ||= 'block'
          class_name = "#{name.to_s.camelize}Processor"
          begin
            processor_class = ETL::Processor.const_get(class_name)
            if name == 'block'
              raise ControlError, "A block must be passed for block processor" if proc.nil?
              configuration[:block] = proc
            end
            processor_collection << processor_class.new(self, configuration)
          rescue NameError => e
            raise ControlError, "Unable to find processor #{class_name}: #{e}"
          end
        when Class
          processor_collection << name.new(self, configuration)
        else
          raise ControlError, "The process declaration requires a String, Symbol, Class, or a Block to be passed"
        end
      end

      public
      # Define an "after read" processor. This must be a row-level processor.
      def after_read(name='block', configuration={}, &block)
        define_processor(name, after_read_processors, configuration, block)
      end

      # Get the defined "after read" processors
      def after_read_processors
        control.after_read_processors
      end

      # Define a "before write" processor. This must be a row-level processor.
      def before_write(name='block', configuration={}, &block)
        define_processor(name, before_write_processors, configuration, block)
      end

      # Get the defined "before write" processors
      def before_write_processors
        control.before_write_processors
      end

      # Define a pre-processor
      def pre_process(name='block', configuration={}, &block)
        define_processor(name, pre_processors, configuration, block)
      end

      # Get the defined pre-processors
      def pre_processors
        control.pre_processors
      end

      # Define a post-processor
      def post_process(name='block', configuration={}, &block)
        define_processor(name, post_processors, configuration, block)
      end

      # Get the defined post-processors
      def post_processors
        control.post_processors
      end

      # Get the binding object
      def get_binding
        binding
      end

      protected
      # Get an array of supported source types
      def source_types
        control.source_types
      end

      # Get an array of supported destination types
      def destination_types
        control.destination_types
      end

    end
  end
end

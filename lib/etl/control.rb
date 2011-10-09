require 'etl/control/context'
require 'etl/control/source'
require 'etl/control/destination'

module ETL #:nodoc:
  # Object representation of a control file
  class Control
    # The File object
    attr_reader :file

    # The error threshold
    attr_accessor :error_threshold

    class << self
      # Parse a control file and return a Control instance
      def parse(control_file)
        control_file = control_file.path if control_file.instance_of?(File)
        control = ETL::Control::Control.new(control_file)
        # TODO: better handling of parser errors. Return the line in the control file where the error occurs.
        eval(IO.readlines(control_file).join("\n"), Context.create(control), control_file)
        control.validate
        control
      end

      def parse_text(text)
        control = ETL::Control::Control.new('no-file')
        eval(text, Context.create(control), 'inline')
        control.validate
        control
      end

      # Resolve the given object to an ETL::Control::Control instance. Acceptable arguments
      # are:
      # * The path to a control file as a String
      # * A File object referencing the control file
      # * The ETL::Control::Control object (which will just be returned)
      #
      # Raises a ControlError if any other type is given
      def resolve(control)
        case control
        when String
          ETL::Control::Control.parse(File.new(control))
        when File
          ETL::Control::Control.parse(control)
        when ETL::Control::Control
          control
        else
          raise ControlError, "Control must be a String, File or Control object"
        end
      end
    end

    # Initialize the instance with the given File object
    def initialize(file)
      @file = file
    end

    # Get a list of dependencies
    def dependencies
      @dependencies ||= []
    end

    # Get the defined source
    def sources
      @sources ||= []
    end

    # Get the defined destinations
    def destinations
      @destinations ||= []
    end

    # Get the transforms with the specified name
    # def transform(name)
#         transforms[name] ||= []
#       end

    def after_read_processors
      @after_read_processors ||= []
    end

    # Get all of the "before write" processors
    def before_write_processors
      @before_write_processors ||= []
    end

    # Get an Array of preprocessors
    def pre_processors
      @pre_processors ||= []
    end

    # Get an Array of post processors
    def post_processors
      @post_processors ||= []
    end

    # Get an Array of all transforms for this control
    def transforms
      @transforms ||= []
    end

    # A hash of the screens executed before post-process
    def screens
      @screens ||= {
        :fatal => [],
        :error => [],
        :warn => []
      }
    end

    # A hash of the screens executed after post-process
    def after_post_process_screens
      @after_post_process_screens ||= {
        :fatal => [],
        :error => [],
        :warn => []
      }
    end

    # Get the error threshold. Defaults to 100.
    def error_threshold
      @error_threshold ||= 100
    end

    # Validate the control file
    def validate
      #unless sources.length > 0
      #  raise ControlError, "Configuration must include one of the following for the source: #{source_types.join(',')}"
      #end
      #unless destinations.length > 0
      #  raise ControlError, "Configuration must include one of the following for the destination: #{destination_types.join(',')}"
      #end
    end

    def source_types
      [:file, :database]
    end

    def destination_types
      [:file, :database]
    end

  end
end

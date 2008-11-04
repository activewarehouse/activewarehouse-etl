module ETL#:nodoc:
  module Transform#:nodoc:
    # Base class for transforms.
    #
    # A transform converts one value to another value using some sort of algorithm.
    #
    # A simple transform has two arguments, the field to transform and the name of the transform:
    #
    #   transform :ssn, :sha1
    # 
    # Transforms can also be blocks:
    #
    #   transform(:ssn){ |v| v[0,24] }
    #
    # Finally, a transform can include a configuration hash:
    #
    #   transform :sex, :decode, {:decode_table_path => 'delimited_decode.txt'}
    class Transform
      class << self
        # Transform the specified value using the given transforms. The transforms can either be
        # Proc objects or objects which extend from Transform and implement the method <tt>transform(value)</tt>.
        # Any other object will result in a ControlError being raised.
        def transform(name, value, row, transforms)
          transforms.each do |transform|
            benchmarks[transform.class] ||= 0
            benchmarks[transform.class] += Benchmark.realtime do
              Engine.logger.debug "Transforming field #{name} with #{transform.inspect}"
              case transform
              when Proc
                value = transform.call([name, value, row])
              when Transform
                value = transform.transform(name, value, row)
              else
                raise ControlError, "Unsupported transform configuration type: #{transform}"
              end
            end
          end
          value
        end
        
        def benchmarks
          @benchmarks ||= {}
        end
      end
      
      attr_reader :control, :name, :configuration
      
      # Initialize the transform object with the given control object, field name and 
      # configuration hash
      def initialize(control, name, configuration={})
        @control = control
        @name = name
        @configuration = configuration
      end
      
      def transform(name, value, row)
        raise "transform is an abstract method"
      end
    end
  end
end
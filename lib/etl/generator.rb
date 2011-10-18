module ETL #:nodoc:
  module Generator #:nodoc:
    autoload :SurrogateKeyGenerator, 'etl/generator/surrogate_key_generator'

    class << self
      # Get the Class for the specified name.
      #
      # For example, if name is :surrogate_key then a SurrogateKeyGenerator class is returned
      def class_for_name(name)
        ETL::Generator.const_get("#{name.to_s.camelize}Generator")
      end
    end

    # Base class for generators.
    class Generator
      class << self
        # Get the Class for the specified name.
        #
        # For example, if name is :surrogate_key then a SurrogateKeyGenerator class is returned
        def class_for_name(name)
          ETL::Generator.class_for_name(name)
        end
      end

      # Generate the next value. This method must be implemented by subclasses
      def next
        raise "Must be implemented by a subclass"
      end
    end
  end
end

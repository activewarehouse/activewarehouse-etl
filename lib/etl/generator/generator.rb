module ETL #:nodoc:
  module Generator #:nodoc:
    # Base class for generators.
    class Generator
      class << self
        # Get the Class for the specified name.
        #
        # For example, if name is :surrogate_key then a SurrogateKeyGenerator class is returned
        def class_for_name(name)
          ETL::Generator.const_get("#{name.to_s.camelize}Generator")
        end
      end
      
      # Generate the next value. This method must be implemented by subclasses
      def next
        raise "Must be implemented by a subclass"
      end
    end
  end
end
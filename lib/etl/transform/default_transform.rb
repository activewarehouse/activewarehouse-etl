module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform which will replace nil or empty values with a specified value.
    class DefaultTransform < Transform
      attr_accessor :default_value
      # Initialize the transform
      #
      # Configuration options:
      # * <tt>:default_value</tt>: The default value to use if the incoming value is blank
      def initialize(control, name, configuration)
        super
        @default_value = configuration[:default_value]
      end
      # Transform the value
      def transform(name, value, row)
        value.blank? ? default_value : value
      end
    end
  end
end
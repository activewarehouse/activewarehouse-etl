module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform a Date or Time to a formatted string instance
    class DateToStringTransform < ETL::Transform::Transform
      # Initialize the transformer.
      #
      # Configuration options:
      # * <tt>:format</tt>: A format passed to strftime. Defaults to %Y-%m-%d
      def initialize(control, name, configuration={})
        super
        @format = configuration[:format] || "%Y-%m-%d"
      end
      # Transform the value using strftime
      def transform(name, value, row)
        return value unless value.respond_to?(:strftime)
        value.strftime(@format)
      end
    end
  end
end
module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform a number to an ordinalized version using the ActiveSupport ordinalize
    # core extension
    class OrdinalizeTransform < ETL::Transform::Transform
      # Transform the value from a number to an ordinalized number
      def transform(name, value, row)
        value.ordinalize
      end
    end
  end
end
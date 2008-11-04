module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform a String representation of a date to a Time instance
    class StringToTimeTransform < ETL::Transform::Transform
      # Transform the value using Time.parse
      def transform(name, value, row)
        Time.parse(value) unless value.nil?
      end
    end
  end
end
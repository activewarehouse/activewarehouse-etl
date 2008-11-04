module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform a String representation of a date to a Date instance
    class StringToDateTransform < ETL::Transform::Transform
      # Transform the value using Date.parse
      def transform(name, value, row)
        return value if value.nil?
        begin
          Date.parse(value)
        rescue => e
          return value
        end
      end
    end
  end
end
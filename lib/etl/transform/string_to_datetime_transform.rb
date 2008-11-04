module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform a String representation of a date to a DateTime instance
    class StringToDateTimeTransform < ETL::Transform::Transform
      # Transform the value using DateTime.parse.
      #
      # WARNING: This transform is slow (due to the Ruby implementation), but if you need to 
      # parse timestamps before or after the values supported by the Time.parse.
      def transform(name, value, row)
        DateTime.parse(value) unless value.nil?
      end
    end
  end
end
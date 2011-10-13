require 'active_support/core_ext/integer/inflections.rb'

module ETL #:nodoc:
  class Transform #:nodoc:
    # Transform a number to an ordinalized version using the ActiveSupport ordinalize
    # core extension
    class OrdinalizeTransform < ETL::Transform
      # Transform the value from a number to an ordinalized number
      def transform(name, value, row)
        value.ordinalize
      end
    end
  end
end

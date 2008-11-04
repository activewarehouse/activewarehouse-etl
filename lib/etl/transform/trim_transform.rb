module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform to trim string
    class TrimTransform < ETL::Transform::Transform
      # Configuration options:
      # * <tt>:type</tt>: :left, :right or :both. Default is :both
      def initialize(control, name, configuration={})
        super
        @type = (configuration[:type] || :both).to_sym
      end
      # Transform the value
      def transform(name, value, row)
        case @type
        when :left
          value.lstrip
        when :right
          value.rstrip
        when :both
          value.strip
        else
          raise "Trim type, if specified, must be :left, :right or :both"
        end
      end
    end
  end
end
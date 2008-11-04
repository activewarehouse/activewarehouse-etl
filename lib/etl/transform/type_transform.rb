module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform from one type to another
    class TypeTransform < ETL::Transform::Transform
      # Initialize the transformer.
      # 
      # Configuration options:
      # * <tt>:type</tt>: The type to convert to. Supported types:
      # ** :string
      # ** :number,:integer
      # ** :float
      # ** :decimal
      def initialize(control, name, configuration={})
        super
        @type = configuration[:type]
        @significant = configuration[:significant] ||= 0
      end
      # Transform the value
      def transform(name, value, row)
        case @type
        when :string
          value.to_s
        when :number, :integer
          value.to_i
        when :float
          value.to_f
        when :decimal
          BigDecimal.new(value.to_s, @significant)
        else
          raise "Unsupported type: #{@type}"
        end
      end
    end
  end
end
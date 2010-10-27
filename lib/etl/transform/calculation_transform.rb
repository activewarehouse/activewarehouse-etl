module ETL
  module Transform
    class CalculationTransform < ETL::Transform::Transform
      attr_reader :function
      attr_reader :fields

      def initialize(control, name, configuration)
        @function = configuration[:function]
        @fields = configuration[:fields]
        super
      end
      
      def transform(name, value, row)
        return nil if row.nil?

        if (@function.eql? "A + B")
          first = ""
          first = row[@fields[0]] unless row[@fields[0]].nil?
          second = ""
          second = row[@fields[1]] unless row[@fields[1]].nil?
          row[name] = first + second
        end

        row[name]
      end

    end
  end
end

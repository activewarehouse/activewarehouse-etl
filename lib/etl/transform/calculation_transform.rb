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
        return nil if row[@fields[0]].nil?

        if (@function.eql? "A + B")
          first = row[@fields[0]]
          second = ""
          second = row[@fields[1]] unless row[@fields[1]].nil?
          row[name] = first + second
        end

        if (@function.eql? "date A")
          first = row[@fields[0]]
          row[name] = Time.parse(first)
        end

        row[name]
      end

    end
  end
end

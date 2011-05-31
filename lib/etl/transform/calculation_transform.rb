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
          result = ""
          @fields.each do |field|
            next if field.nil?

            string = ""
            if field.to_s.eql? field
              string = field
              begin
                string = eval('"' + field + '"')
              rescue
              end
            else
              string = row[field]
            end
            next if string.nil?

            result = result + string
          end

          row[name] = result
        end

        if (@function.eql? "date A")
          first = row[@fields[0]]
          row[name] = Time.parse(first)
        end

        if (@function.eql? "trim A")
          first = row[@fields[0]]
          row[name] = first.strip
        end

        if (@function.eql? "lower A")
          first = row[@fields[0]]
          row[name] = first.downcase
        end

        if (@function.eql? "upper A")
          first = row[@fields[0]]
          row[name] = first.upcase
        end

        if (@function.eql? "encoding A")
          # Bug from ruby 1.8 http://po-ru.com/diary/fixing-invalid-utf-8-in-ruby-revisited/
          first = row[@fields[0]]
          row[name] = Iconv.conv(@fields[1], @fields[2], first + ' ')[0..-2]
        end

        row[name]
      end

    end
  end
end

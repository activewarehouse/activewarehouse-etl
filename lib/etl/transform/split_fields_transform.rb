module ETL
  module Transform
    class SplitFieldsTransform < ETL::Transform::Transform
      attr_reader :delimiter
      attr_reader :new_fields

      def initialize(control, name, configuration)
        @delimiter = configuration[:delimiter] || ','
        @new_fields = configuration[:new_fields]
        super
      end
      
      def transform(name, value, row)
        return nil if row.nil?
        return nil if row[name].nil?

        fields = row[name].split(@delimiter)
        @new_fields.each_with_index do |new, index|
          row[new] = fields[index]
        end

        row[name]
      end

    end
  end
end

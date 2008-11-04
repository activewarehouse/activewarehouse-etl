#RAILS_ENV = 'development'
#require '../config/environment'

module ETL #:nodoc:
  module Control #:nodoc:
    class ModelSource < Source   
      
      def columns
        case definition
        when Array
          definition.collect(&:to_sym)
        when Hash
          definition.keys.collect(&:to_sym)
        else
          raise "Definition must be either an Array or a Hash"
        end
      end
      
      def railsmodel
        configuration[:model]
      end
      
      def order
        configuration[:order] || "id"
      end
         
      def each(&block)
          railsmodel.to_s.camelize.constantize.find(:all,:order=>order).each do |row|
            result_row = ETL::Row.new
            result_row.source = self
            columns.each do |column|
              result_row[column.to_sym] = row.send(column)
            end
            yield result_row
        end
      end
    end
  end
end
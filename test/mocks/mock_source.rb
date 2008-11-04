module ETL
  module Control
    # Usage:
    # - first set the data in your test setup
    #   MockSource[:my_input] = [ { :first_name => 'John', :last_name => 'Barry' }, { ...} ]
    # - then declare in the ctl file:
    #   source :in, { :type => :mock, :name => :my_input } 
    class MockSource < EnumerableSource
      def initialize(control, configuration, definition)
        super
        mock_source_name = configuration[:name] || 'mock_source'
        throw "No mock source data set for mock source '#{mock_source_name}'" if @@registry[mock_source_name].nil?
        configuration[:enumerable] = @@registry[mock_source_name]
      end
      def self.[]=(mock_source_name,mock_source_data)
        @@registry ||= {}
        @@registry[mock_source_name] = mock_source_data
      end
      def self.[](mock_source_name)
        @@registry[mock_source_name]
      end
    end
  end
end


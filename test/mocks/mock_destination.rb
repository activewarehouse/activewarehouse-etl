module ETL
  module Control
    # Usage:
    # - declare in the ctl file:
    #   destination :out, { :type => :mock, :name => :my_mock_output  }
    # - run the .ctl from your test
    # - then assert the content of the rows
    #   assert_equal [{:name => 'John Barry'},{:name => 'Gary Moore'}], MockDestination[:my_mock_output]
    class MockDestination < Destination
      def initialize(control, configuration, mapping={})
        super
        @mock_destination_name = configuration[:name] || 'mock_destination'
        @@registry ||= {}
        @@registry[@mock_destination_name] ||= []
      end
      def self.[](mock_destination_name)
        @@registry[mock_destination_name]
      end
      def write(row)
        @@registry[@mock_destination_name] << row
      end
      # the presence of close is asserted - just do nothing
      def close; end
    end
  end
end

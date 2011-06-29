require File.dirname(__FILE__) + '/test_helper'

class EnsureFieldsPresenceProcessorTest < Test::Unit::TestCase

  def new_processor(options)
    ETL::Processor::EnsureFieldsPresenceProcessor.new(nil, options)
  end
  
  should 'raise an error unless :fields is specified' do
    error = assert_raises(ETL::ControlError) { new_processor({}) }
    assert_equal ":fields must be specified", error.message
  end

  should 'raise an error if a field is missing in the row' do
    error = assert_raise(ETL::ControlError) do
      processor = new_processor(:fields => [:key])
      processor.process(ETL::Row[])
    end
    
    assert_match /missing required field\(s\)/, error.message
  end
  
  should 'return the row if the required fields are in the row' do
    row = ETL::Row[:first => nil, :second => "Barry"]
    assert_equal row, new_processor(:fields => [:first, :second]).process(row)
  end
  
end

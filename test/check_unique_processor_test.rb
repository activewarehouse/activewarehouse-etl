require File.dirname(__FILE__) + '/test_helper'

class CheckUniqueProcessorTest < Test::Unit::TestCase

  context 'CheckUniqueProcessor' do
    attr_reader :processor
    
    setup do
      @processor = ETL::Processor::CheckUniqueProcessor.new(nil,
        :keys => [:first, :second])
    end

    should "keep a row whose keys didn't already appear in the pipeline" do
      row = ETL::Row[:first => 'A', :second => 'B']

      assert_equal row, processor.process(row)
      
      assert_equal({ 'A|B' => 1 }, processor.compound_key_constraints)
    end
    
    should "remove a row whose keys already appeared in the pipeline" do
      row = ETL::Row[:first => 'A', :second => 'B']

      assert_equal row, processor.process(row)
      assert_equal nil, processor.process(row)
    end
    
    should "raise an error if a row lacks one of the keys specified" do
      row = ETL::Row[:first => 'A']
      
      error = assert_raises(ETL::ControlError) do
        processor.process(row)
      end
      
      assert_equal "Row missing required field :second for unicity check", error.message
    end
    
  end
  
end

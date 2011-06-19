require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end

class CheckExistProcessorTest < Test::Unit::TestCase

  context 'CheckExistProcessor' do

    setup do
      @config = {
        :target => :data_warehouse,
        :table => 'people',
        :columns => [:first_name, :last_name]
      }
    end
    
    should_eventually "compare based on all columns if no columns are provided" do
      # TBI
    end
    
    should_eventually "compare based on all columns except skipped ones if columns to skip are provided" do
      # TBI
    end
    
    should "raise an error if no table is provided" do
      error = assert_raises(ETL::ControlError) do
        ETL::Processor::CheckExistProcessor.new(nil, @config.except(:table))
      end
      # bug #2413 on assert_raises won't let me check error message above
      assert_equal 'table must be specified', error.message 
    end
    
    should "raise an error if no target is provided" do
      error = assert_raises(ETL::ControlError) do
        ETL::Processor::CheckExistProcessor.new(nil, @config.except(:target))
      end
      
      assert_equal 'target must be specified', error.message
    end
    
    should "bypass checking if the table has no rows" do
      Person.delete_all
      
      processor = ETL::Processor::CheckExistProcessor.new(nil, @config)
      assert_equal false, processor.should_check?
    end
    
    should "raise an error if one of the keys used for checking existence is not available in a row" do
      Person.delete_all
      # we need at least one record to avoid automatic skipping
      # this should be mocked instead, probably
      Person.create!(:first_name => 'John', :last_name => 'Barry', :ssn => '1234')
      
      error = assert_raise(ETL::ControlError) do
        row = ETL::Row[:first_name => 'John']
        processor = ETL::Processor::CheckExistProcessor.new(nil, @config)

        # guard against bypassing
        assert_equal true, processor.should_check?
        
        processor.process(row)
      end
      
      assert_equal "Row missing required field :last_name for existence check", error.message
    end
    
    should "return nil if the same row is found in database" do
      Person.delete_all
      Person.create!(:first_name => 'John', :last_name => 'Barry', :ssn => '1234')

      row = ETL::Row[:first_name => 'John', :last_name => 'Barry']
      processor = ETL::Processor::CheckExistProcessor.new(nil, @config)
      assert_equal true, processor.should_check? # guard against bypassing
        
      assert_equal nil, processor.process(row)
    end

    should "return the row if no same row is found in database" do
      Person.delete_all
      Person.create!(:first_name => 'John', :last_name => 'Barry', :ssn => '1234')

      row = ETL::Row[:first_name => 'John', :last_name => 'OtherName']
      processor = ETL::Processor::CheckExistProcessor.new(nil, @config)
      assert_equal true, processor.should_check? # guard against bypassing
        
      assert_equal row, processor.process(row)
    end
  
  end

end

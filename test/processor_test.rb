require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end

# Test pre- and post-processors
class ProcessorTest < Test::Unit::TestCase
  # Test bulk import functionality
  
  context "the bulk import processor" do
    should "should import successfully" do
      assert_nothing_raised { do_bulk_import }
      assert_equal 3, Person.count
      assert_equal "Foxworthy", Person.find(2).last_name
    end
  end
  
  def test_bulk_import_with_empties
    # this test ensure that one column with empty value will still allow
    # the row to be imported
    # this doesn't apply to the id column though - untested
    assert_nothing_raised { do_bulk_import('bulk_import_with_empties.txt') }
    assert_equal 3, Person.count
    assert Person.find(2).last_name.blank?
  end

  def test_truncate
    # TODO: implement test
  end
  
  private
  
  def do_bulk_import(file = 'bulk_import.txt')
    control = ETL::Control::Control.new(File.join(File.dirname(__FILE__), 'delimited.ctl'))
    configuration = {
      :file => "data/#{file}",
      :truncate => true,
      :target => :data_warehouse,
      :table => 'people'
    }
    processor = ETL::Processor::BulkImportProcessor.new(control, configuration)
    processor.process
  end
end

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
    end
  end
  
  def test_bulk_import_with_empties
    assert_nothing_raised { do_bulk_import('bulk_import_with_empties.txt') }
    assert_equal 1, Person.count
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

require 'spec_helper'

# @todo: Should we have this importer? Perhaps make it an abstract class, but move to an etl-extension.
describe ETL::Processor::BulkImportProcessor do
  # @todo: Implement the below, from the original test?
  #
  # context "the bulk import processor" do
  #   should "should import successfully" do
  #     assert_nothing_raised { do_bulk_import }
  #     assert_equal 3, Person.count
  #     assert_equal "Foxworthy", Person.find(2).last_name
  #   end
  # end
  #
  # def test_bulk_import_with_empties
  #   # this test ensure that one column with empty value will still allow
  #   # the row to be imported
  #   # this doesn't apply to the id column though - untested
  #   assert_nothing_raised { do_bulk_import('bulk_import_with_empties.txt') }
  #   assert_equal 3, Person.count
  #   assert Person.find(2).last_name.blank?
  # end
  #
  # def test_truncate
  #   # TODO: implement test
  # end
  #
  # private
  #
  # def do_bulk_import(file = 'bulk_import.txt')
  #   control = ETL::Control.new(File.join(File.dirname(__FILE__), 'delimited.ctl'))
  #   configuration = {
  #     :file => "data/#{file}",
  #     :truncate => true,
  #     :target => :data_warehouse,
  #     :table => 'people'
  #   }
  #   processor = ETL::Processor::BulkImportProcessor.new(control, configuration)
  #   processor.process
  # end
end

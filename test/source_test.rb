require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end
class SourceTest < Test::Unit::TestCase
  context "a database source" do
    setup do
      control = ETL::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
      configuration = {
        :database => 'etl_unittest',
        :target => :operational_database,
        :table => 'people',
      }
      definition = [ 
        :first_name,
        :last_name,
        :ssn,
      ]
      @source = ETL::Control::DatabaseSource.new(control, configuration, definition)
    end
    should "set the local file for extraction storage" do
      assert_match %r{source_data/localhost/etl_unittest/people/\d+.csv}, @source.local_file.to_s
    end
    should "find 1 row" do
      Person.delete_all
      assert_equal 0, Person.count
      Person.create!(:first_name => 'Bob', :last_name => 'Smith', :ssn => '123456789')
      assert_equal 1, Person.count
      rows = @source.collect { |row| row }
      assert_equal 1, rows.length
    end
  end

  context "a model source" do
    setup do
      control = ETL::Control.parse(File.dirname(__FILE__) + '/model_source.ctl')
      configuration = {

      }
      definition = [
        :first_name,
        :last_name,
        :ssn
      ]
    end
    should_eventually "find n rows" do
      
    end
  end
end
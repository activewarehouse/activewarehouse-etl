require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end
class SourceTest < Test::Unit::TestCase
  
  context "source" do
    should "set store_locally to true by default" do
      assert_equal true, Source.new(nil, { :store_locally => true }, nil).store_locally
    end
    
    should "let the user set store_locally to true" do
      assert_equal true, Source.new(nil, { :store_locally => true }, nil).store_locally
    end

    should "let the user set store_locally to false" do
      assert_equal false, Source.new(nil, { :store_locally => false }, nil).store_locally
    end
  end
  
  context "a file source" do
    context "with delimited data" do
      setup do
        control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
        configuration = {
          :file => 'data/delimited.txt',
          :parser => :csv
        }
        definition = self.definition + [:sex]
    
        source = ETL::Control::FileSource.new(control, configuration, definition)
        @rows = source.collect { |row| row }
      end
      should "find 3 rows in the delimited file" do
        assert_equal 3, @rows.length
      end
    end
  end
  
  context "a file source with a glob" do
    setup do
      control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/multiple_delimited.ctl')
      configuration = {
        :file => 'data/multiple_delimited_*.txt',
        :parser => :csv
      }

      source = ETL::Control::FileSource.new(control, configuration, definition)
      @rows = source.collect { |row| row }
    end
    should "find 6 rows in total" do
      assert_equal 6, @rows.length
    end
  end
  
  context "a file source with an absolute path" do
    setup do
      FileUtils.cp(File.dirname(__FILE__) + '/data/delimited.txt', '/tmp/delimited_abs.txt')

      control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
        '/delimited_absolute.ctl')
      configuration = {
        :file => '/tmp/delimited_abs.txt',
        :parser => :csv
      }
      definition = self.definition + [:sex]

      source = ETL::Control::FileSource.new(control, configuration, definition)
      @rows = source.collect { |row| row }
    end
    should "find 3 rows" do
      assert_equal 3, @rows.length
    end
  end
  
  context "multiple sources" do
    setup do
      control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
        '/multiple_source_delimited.ctl')
      @rows = control.sources.collect { |source| source.collect { |row| row }}.flatten!
    end
    should "find 12 rows" do
      assert_equal 12, @rows.length
    end
  end
  
  context "a database source" do
    setup do
      control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
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
  
  context "a file source with an xml parser" do
    setup do
      control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
        '/xml.ctl')
      @rows = control.sources.collect{ |source| source.collect { |row| row }}.flatten!
    end
    should "find 2 rows" do
      assert_equal 2, @rows.length
    end
  end

  context "a model source" do
    setup do
      control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/model_source.ctl')
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
  
  def definition
    [ 
      :first_name,
      :last_name,
      :ssn,
      {
        :name => :age,
        :type => :integer
      }
    ]
  end
end
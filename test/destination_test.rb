require 'rubygems'
require 'spreadsheet'
require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end

# Test the functionality of destinations
class DestinationTest < Test::Unit::TestCase  
  # Test a database destination
  def test_database_destination
    row = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row_needs_escape = ETL::Row[:id => 2, :first_name => "Foo's", :last_name => "Bar", :ssn => '000000000' ]
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited.ctl')
    
    Person.delete_all
    assert_equal 0, Person.count
    
    # First define a basic configuration to check defaults
    configuration = { 
      :target => :data_warehouse,
      :database => 'etl_unittest',
      :table => 'people',
      :buffer_size => 0 
    }
    mapping = { :order => [:id, :first_name, :last_name, :ssn] }
    dest = ETL::Control::DatabaseDestination.new(control, configuration, mapping)
    dest.write(row)
    dest.close
    
    assert_equal 1, Person.find(:all).length
  end
  
  def test_database_destination_with_control
    row = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited_destination_db.ctl')
    Person.delete_all
    assert_equal 0, Person.count
    d = control.destinations.first
    dest = ETL::Control::DatabaseDestination.new(control, d.configuration, d.mapping)
    dest.write(row)
    dest.close
    assert_equal 1, Person.count
  end

  # Test a update database destination
  def test_update_database_destination
    row = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited_update.ctl')
    
    Person.delete_all
    assert_equal 0, Person.count
    test_database_destination

    # First define a basic configuration to check defaults
    configuration = { 
      :type => :update_database,
      :target => :data_warehouse,
      :database => 'etl_unittest',
      :table => 'people',
      :buffer_size => 0 
    }
    mapping = {
      :conditions => [{:field => "\#{conn.quote_column_name(:id)}", :value => "\#{conn.quote(row[:id])}", :comp => "="}],
      :order => [:id, :first_name, :last_name, :ssn]
    }
    dest = ETL::Control::UpdateDatabaseDestination.new(control, configuration, mapping)
    dest.write(row)
    dest.close
    
    assert_equal 1, Person.find(:all).length

  end

  # Test a insert update database destination
  def test_insert_update_database_destination
    row = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row_needs_escape = ETL::Row[:id => 2, :first_name => "Foo's", :last_name => "Bar", :ssn => '000000000' ]
    row_needs_update = ETL::Row[:id => 1, :first_name => "Sean", :last_name => "Toon", :ssn => '000000000' ]
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited_insert_update.ctl')
    
    Person.delete_all
    assert_equal 0, Person.count
    
    # First define a basic configuration to check defaults
    configuration = { 
      :type => :insert_update_database,
      :target => :data_warehouse,
      :database => 'etl_unittest',
      :table => 'people',
      :buffer_size => 0 
    }
    mapping = {
      :primarykey => [:id],
      :order => [:id, :first_name, :last_name, :ssn]
    }
    dest = ETL::Control::InsertUpdateDatabaseDestination.new(control, configuration, mapping)
    dest.write(row)
    dest.write(row_needs_escape)
    dest.write(row_needs_update)
    dest.close
    
    assert_equal 2, Person.find(:all).length
  end
  
end

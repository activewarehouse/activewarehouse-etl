require 'rubygems'
require 'spreadsheet'
require File.dirname(__FILE__) + '/test_helper'

class Person < ActiveRecord::Base
end

class BadDestination < ETL::Control::Destination
  def initialize(control, configuration, mapping)
    super
  end
end

# Test the functionality of destinations
class DestinationTest < Test::Unit::TestCase
  # Test a file destination
  def test_file_destination
    outfile = 'output/test_file_destination.txt'
    outfile2 = 'output/test_file_destination.2.txt'
    row = ETL::Row[ :address => '123 SW 1st Street', :city => 'Melbourne', 
      :state => 'Florida', :country => 'United States' ]
    row_needs_escape = ETL::Row[ :address => "Allen's Way", 
      :city => 'Some City', :state => 'Some State', :country => 'Mexico' ]
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited.ctl')

    # First define a basic configuration to check defaults
    configuration = { 
      :file => outfile, 
      :buffer_size => 0,
    }
    mapping = { 
      :order => [:address, :city, :state, :country, :country_code],
      :virtual => {
        :country_code => Proc.new do |r|
          {
            'United States' => 'US',
            'Mexico' => 'MX'
          }[r[:country]]
        end
      }
    }
    
    dest = ETL::Control::FileDestination.new(control, configuration, mapping)    
    dest.write(row)
    dest.write(row_needs_escape)
    dest.close
    
    configuration[:file] = outfile2
    configuration[:separator] = '|'
    configuration[:eol] = "[EOL]\n"
    
    dest = ETL::Control::FileDestination.new(control, configuration, mapping)
    dest.write(row)
    dest.write(row_needs_escape)
    dest.close
    
    # Read back the resulting
    lines = open(File.join(File.dirname(__FILE__), outfile), 'r').readlines
    assert_equal "123 SW 1st Street,Melbourne,Florida,United States,US\n", lines[0]
    assert_equal "Allen's Way,Some City,Some State,Mexico,MX\n", lines[1]
    
    lines = open(File.join(File.dirname(__FILE__), outfile2), 'r').readlines
    assert_equal "123 SW 1st Street|Melbourne|Florida|United States|US[EOL]\n", lines[0]
    assert_equal "Allen's Way|Some City|Some State|Mexico|MX[EOL]\n", lines[1]
  end
  
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
  
  def test_unique
    row1 = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row2 = ETL::Row[:id => 2, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row3 = ETL::Row[:id => 3, :first_name => 'John', :last_name => 'Smith', :ssn => '000112222']
         
    outfile = 'output/test_unique.txt'
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')

    # First define a basic configuration to check defaults
    configuration = { :file => outfile, :buffer_size => 0, :unique => [:ssn]}
    mapping = { 
      :order => [:first_name, :last_name, :ssn]
    }
    dest = ETL::Control::FileDestination.new(control, configuration, mapping)    
    dest.write(row1)
    dest.write(row2)
    dest.write(row3)
    
    # Close (and flush) the destination
    dest.close
    
    # Read back the resulting
    lines = open(File.join(File.dirname(__FILE__), outfile), 'r').readlines
    assert_equal "Bob,Smith,111234444\n", lines[0]
    assert_equal "John,Smith,000112222\n", lines[1]
  end
  
  def test_multiple_unique
    row1 = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row2 = ETL::Row[:id => 2, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
    row3 = ETL::Row[:id => 3, :first_name => 'Bob', :last_name => 'Smith', :ssn => '000112222']
    
    outfile = 'output/test_multiple_unique.txt'
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')

    # First define a basic configuration to check defaults
    configuration = { :file => outfile, :buffer_size => 0, :unique => [:last_name,:first_name]}
    mapping = { 
      :order => [:first_name, :last_name, :ssn]
    }
    dest = ETL::Control::FileDestination.new(control, configuration, mapping)    
    dest.write(row1)
    dest.write(row2)
    dest.write(row3)
    
    # Close (and flush) the destination
    dest.close
    
    # Read back the resulting
    lines = open(File.join(File.dirname(__FILE__), outfile), 'r').readlines
    assert_equal "Bob,Smith,111234444\n", lines[0]
    assert_equal 1, lines.length
  end

  def test_bad_destination
    control = ETL::Control::Control.parse_text('')
    configuration = {}
    mapping = {}
    dest = BadDestination.new(control, configuration, mapping)
    dest.write(nil)
    assert_raise NotImplementedError do
      dest.flush
    end
    assert_raise NotImplementedError do
      dest.close
    end
  end

  def test_excel_destination
    outfile = 'output/test_excel_destination.xls'
    row = ETL::Row[ :address => '123 SW 1st Street', :city => 'Melbourne', 
      :state => 'Florida', :country => 'United States' ]
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + 
      '/delimited_excel.ctl')

    # First define a basic configuration to check defaults
    configuration = { 
      :file => outfile, 
      :buffer_size => 0,
    }
    mapping = { 
      :order => [:address, :city, :state, :country, :country_code],
      :virtual => {
        :country_code => Proc.new do |r|
          {
            'United States' => 'US',
            'Mexico' => 'MX'
          }[r[:country]]
        end
      }
    }
    
    dest = ETL::Control::ExcelDestination.new(control, configuration, mapping)    
    dest.write(row)
    dest.close
    
    # Read back the resulting
    book = Spreadsheet.open File.join(File.dirname(__FILE__), outfile)
    sheet = book.worksheet(0)

    assert_equal "123 SW 1st Street", sheet[0, 0]
    assert_equal "Melbourne", sheet[0, 1]
    assert_equal "Florida", sheet[0, 2]
    assert_equal "United States", sheet[0, 3]
    assert_equal "US", sheet[0, 4]
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

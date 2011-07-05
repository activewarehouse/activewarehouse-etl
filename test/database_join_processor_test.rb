require File.dirname(__FILE__) + '/test_helper'

class DatabaseJoinProcessorTest < Test::Unit::TestCase

  def new_processor(options)
    ETL::Processor::DatabaseJoinProcessor.new(nil, options)
  end
  
  should 'raise an error unless :fields is specified' do
    error = assert_raises(ETL::ControlError) { new_processor({}) }
    assert_equal ":target must be specified", error.message
  end

  should 'return the row and the database result' do
    row = ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']
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

    row = ETL::Row[:last_name => "Smith"]
    processor = new_processor(:target => :data_warehouse,
                              :query => "SELECT first_name FROM people WHERE last_name = \#{connection.quote(row[:last_name])}",
                              :fields => ["first_name"]).process(row)
    assert_equal row[:first_name], "Bob"
  end
  
end

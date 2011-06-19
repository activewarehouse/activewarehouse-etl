require File.dirname(__FILE__) + '/test_helper'

class EngineTest < Test::Unit::TestCase

  context 'connection' do
  
    should 'return an ActiveRecord configuration by name' do
      assert_not_nil ETL::Engine.connection(:data_warehouse)
    end
    
    should 'raise an error on non existent connection' do
      error = assert_raise(ETL::ETLError) do
        ETL::Engine.connection(:does_not_exist)
      end
      assert_equal "Cannot find connection named :does_not_exist", error.message
    end
    
    should 'raise an error when requesting a connection with no name' do
      error = assert_raise(ETL::ETLError) do
        ETL::Engine.connection("  ")
      end
      assert_equal "Connection with no name requested. Is there a missing :target parameter somewhere?", error.message
    end
  end
  
  context 'temp tables' do
    attr_reader :connection
    
    setup do
      @connection = ETL::Engine.connection(:data_warehouse)
    end
    
    should 'return unmodified table name when temp tables are disabled' do
      assert_equal 'foo', ETL::Engine.table('foo', ETL::Engine.connection(:data_warehouse))
    end
    
    should 'return temp table name instead of table name when temp tables are enabled' do
      ETL::Engine.use_temp_tables = true
      assert_equal 'tmp_people', ETL::Engine.table('people', connection)
      ETL::Engine.use_temp_tables = false
    end
  end
  
end
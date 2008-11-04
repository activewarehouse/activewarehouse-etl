require File.dirname(__FILE__) + '/test_helper'

class EngineTest < Test::Unit::TestCase
  
  def test_connections
    assert_equal 3, ActiveRecord::Base.configurations.length
    conn = ETL::Engine.connection(:data_warehouse)
    assert_not_nil conn
  end
  
  def test_non_existent_connection
    assert_raise ETL::ETLError do
      conn = ETL::Engine.connection(:does_not_exist)
    end
  end
  
  def test_engine_table_method_should_return_same_name_when_not_using_temp_tables
    assert_equal 'foo', ETL::Engine.table('foo', connection)
  end
  
  def test_engine_table_method_should_return_temp_name_when_using_temp_tables
    ETL::Engine.use_temp_tables = true
    assert_equal 'tmp_people', ETL::Engine.table('people', connection)
    ETL::Engine.use_temp_tables = false
  end
  
  protected
  def connection
    ETL::Engine.connection(:data_warehouse)
  end
  
end
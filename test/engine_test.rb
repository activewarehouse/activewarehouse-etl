require File.dirname(__FILE__) + '/test_helper'

class EngineTest < Test::Unit::TestCase

  context 'process' do
  
    should 'raise an error when a file which does not exist is given' do
      error = assert_raise(Errno::ENOENT) do
        ETL::Engine.process('foo-bar.ctl')
      end
      
      assert_equal "No such file or directory - foo-bar.ctl", error.message
    end
    
    should 'raise an error when an unknown file type is given' do
      error = assert_raise(RuntimeError) do
        ETL::Engine.process(__FILE__)
      end
      
      assert_match /Unsupported file type/, error.message
    end
    
    should_eventually 'stop as soon as the error threshold is reached' do
      engine = ETL::Engine.new

      assert_equal 0, engine.errors.size
      
      engine.process ETL::Control::Control.parse_text <<CTL
        set_error_threshold 1
        source :in, { :type => :enumerable, :enumerable => (1..100) }
        after_read { |row| raise "Failure" }
CTL
      
      assert_equal 1, engine.errors.size
    end
    
  end
  
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
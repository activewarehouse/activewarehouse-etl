require File.dirname(__FILE__) + '/test_helper'

class BatchTest < Test::Unit::TestCase
  attr_reader :file, :db_yaml, :engine
  def setup
    @file =  File.dirname(__FILE__) + '/all.ebf'
    @db_yaml = File.dirname(__FILE__) + '/database.yml'
    @engine = ETL::Engine.new
  end
  def teardown
    
  end
  def test_etl_batch_file
    #`etl #{file} -c #{db_yaml}`
  end
  def test_batch
    assert_nothing_raised do
      batch = ETL::Batch::Batch.resolve(file, engine)
      batch.execute
    end
  end
  def test_batch_with_file
    assert_nothing_raised do
      batch = ETL::Batch::Batch.resolve(File.new(file), engine)
      batch.execute
    end
  end
  def test_batch_with_batch_object
    assert_nothing_raised do
      batch_instance = ETL::Batch::Batch.new(File.new(file))
      batch_instance.engine = engine
      batch = ETL::Batch::Batch.resolve(batch_instance, engine)
      batch.execute
    end
  end
  def test_batch_with_object_should_fail
    assert_raise(RuntimeError) do
      batch = ETL::Batch::Batch.resolve(0, engine)
    end
  end
end
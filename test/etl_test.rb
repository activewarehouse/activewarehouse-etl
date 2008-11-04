require File.dirname(__FILE__) + '/test_helper'

# This is an integration test
class ETLTest < Test::Unit::TestCase
  # Test end-to-end integration of ETL engine processing for the delimited.ctl control file
  def test_delimited_single_file_load
    #ETL::Engine.logger = Logger.new(STDOUT)
    #ETL::Engine.logger.level = Logger::DEBUG
    
    ETL::Engine.init(:config => File.dirname(__FILE__) + '/database.yml')
    ETL::Engine.process(File.dirname(__FILE__) + '/delimited.ctl')
    lines = open(File.dirname(__FILE__) + '/output/delimited.txt').readlines
    assert_equal 3, lines.length
    
    data = lines[0].split(',')
    assert_equal '1', data[0]
    assert_equal 'Chris', data[1]
    assert_equal 'Smith', data[2]
    assert_equal '23cc5914d48b146f0fbb73c4', data[3]
    assert_equal '24', data[4]
    assert_equal 'Male', data[5]
    assert_equal 'test!', data[6]
    assert_nothing_raised { Time.parse(data[7]) }
    
    data = lines[1].split(',')
    assert_equal '2', data[0]
    assert_equal 'Jim', data[1]
    assert_equal 'Foxworthy', data[2]
    assert_equal '596e3534978b8c2b47851e37', data[3]
    assert_equal '51', data[4]
    assert_equal 'Male', data[5]
    assert_equal 'test!', data[6]
    assert_nothing_raised { Time.parse(data[7]) }
  end
  
  # Test end-to-end integration of ETL engine processing for the fixed_width.ctl control file
  def test_fixed_width_single_file_load
    ETL::Engine.process(File.dirname(__FILE__) + '/fixed_width.ctl')
    lines = open(File.dirname(__FILE__) + '/output/delimited.txt').readlines
    assert_equal 3, lines.length
  end
end
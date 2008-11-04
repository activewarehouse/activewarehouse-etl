require File.dirname(__FILE__) + '/test_helper'
include ETL
include ETL::Control

class TestWitness
end

class BlockProcessorTest < Test::Unit::TestCase
  
  def test_block_processor_should_work_as_both_after_read_and_before_write_row_processor
    MockSource[:block_processed_input] = [{ :first_name => 'John'},{:first_name => 'Gary'}]
    process 'block_processor.ctl'
    assert_equal 4, MockDestination[:block_processed_output].size
    assert_equal({ :first_name => 'John', :added_by_after_read => 'after-John', :added_by_before_write => "Row 1" }, MockDestination[:block_processed_output][0])
    assert_equal({ :new_row => 'added by post_processor' }, MockDestination[:block_processed_output][1])
    assert_equal({ :first_name => 'Gary', :added_by_after_read => 'after-Gary', :added_by_before_write => "Row 2" }, MockDestination[:block_processed_output][2])
    assert_equal({ :new_row => 'added by post_processor' }, MockDestination[:block_processed_output][3])
  end
  
  def test_block_processor_should_let_rows_be_removed_by_setting_it_to_nil
    MockSource[:block_input] = [{ :obsolete => true, :name => 'John'},{ :obsolete => false, :name => 'Gary'}]
    process 'block_processor_remove_rows.ctl'
    assert_equal([{ :obsolete => false, :name => 'Gary' }], MockDestination[:block_output]) # only one record should be kept
  end
  
  def test_block_processor_should_work_as_pre_or_post_processor
    flexmock(TestWitness).should_receive(:call).with("I'm called from pre_process")
    flexmock(TestWitness).should_receive(:call).with("I'm called from post_process")
    MockSource[:another_input] = [{ :obsolete => true, :name => 'John'},{ :obsolete => false, :name => 'Gary'}]
    process 'block_processor_pre_post_process.ctl'
    assert_equal(MockSource[:another_input], MockDestination[:another_output])
  end
  
  def test_block_error_should_be_propagated
    assert_raise(ControlError) { process 'block_processor_error.ctl' }
  end
  
end
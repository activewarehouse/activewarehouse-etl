require File.dirname(__FILE__) + '/test_helper'

class ControlTest < Test::Unit::TestCase
  # Test the ability to parse control files.
  def test_parse
    assert_nothing_raised do
      Dir.glob(File.join(File.dirname(__FILE__), '*.ctl')) do |f|
        ETL::Control.parse(f)
      end
    end
  end
  
  def test_bad_control_raises_error
    assert_raise ETL::ControlError do
      ETL::Control.resolve(0)
    end
  end
  
  def test_resolve_control_object
    assert_nothing_raised do
      ETL::Control.resolve(ETL::Control.parse(File.join(File.dirname(__FILE__), 'delimited.ctl')))
    end
  end
  
  def test_set_error_threshold
    assert_nothing_raised do
      ETL::Engine.process(File.join(File.dirname(__FILE__), 'errors.ctl'))
    end
  end
  
  def test_bad_processor_name
    assert_raise ETL::ControlError do
      s = "before_write :chunky_monkey"
      ETL::Control.parse_text(s)
    end
  end
  
  def test_dependencies
    s = "depends_on 'foo', 'bar'"
    control = ETL::Control.parse_text(s)
    assert_equal control.dependencies, ['foo','bar']
  end
end
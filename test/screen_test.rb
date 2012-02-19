require File.dirname(__FILE__) + '/test_helper'

class ScreenTest < Test::Unit::TestCase
  def test_screen
    ETL::Engine.process(File.dirname(__FILE__) + '/screen_test_fatal.ctl')
    assert_equal 2, ETL::Engine.exit_code
  end
end
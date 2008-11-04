require File.dirname(__FILE__) + '/test_helper'

class ScreenTest < Test::Unit::TestCase
  def test_screen
    assert_raises(SystemExit) do
      ETL::Engine.process(File.dirname(__FILE__) + '/screen_test_fatal.ctl')
    end
  end
end
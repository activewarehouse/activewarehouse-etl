require File.dirname(__FILE__) + '/test_helper'

class BadDirective < ETL::Batch::Directive
  
end

class BatchTest < Test::Unit::TestCase
  
  attr_reader :file
  attr_reader :engine
  def setup
    @file =  File.dirname(__FILE__) + '/all.ebf'
    @engine = ETL::Engine.new
  end
  
  def test_directive_without_implementation_should_fail
    batch = ETL::Batch::Batch.resolve(file, engine)
    assert_raise RuntimeError do
      d = BadDirective.new(batch)
      d.execute
    end
  end
end
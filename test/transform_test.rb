require File.dirname(__FILE__) + '/test_helper'

class MyResolver
  def resolve(value)
    4
  end
end

class TransformTest < Test::Unit::TestCase
  def test_foreign_key_lookup_transform
    control = ETL::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    configuration = {:collection => {'foo' => 1, 'bar' => 2, 'baz' => 3}}
    t = ETL::Transform::ForeignKeyLookupTransform.new(control, nil, configuration)
    
    assert_equal 1, t.transform(nil, 'foo', nil)
    assert_equal 2, t.transform(nil, 'bar', nil)
    assert_equal 3, t.transform(nil, 'baz', nil)
    assert_raises(ETL::ResolverError, 'Foreign key for bing not found and no resolver specified') do
      assert_equal 4, t.transform(nil, 'bing', nil)
    end
    
    configuration = {:collection => {'foo' => 1, 'bar' => 2, 'baz' => 3}, :resolver => MyResolver}
    t = ETL::Transform::ForeignKeyLookupTransform.new(control, nil, configuration)
    assert_equal 1, t.transform(nil, 'foo', nil)
    assert_equal 2, t.transform(nil, 'bar', nil)
    assert_equal 3, t.transform(nil, 'baz', nil)
    assert_equal 4, t.transform(nil, 'bing', nil)
  end
end

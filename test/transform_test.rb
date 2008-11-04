require File.dirname(__FILE__) + '/test_helper'

class MyResolver
  def resolve(value)
    4
  end
end

class TransformTest < Test::Unit::TestCase
  def test_sha1_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    digest_value = 'a9993e364706816aba3e25717850c26c9cd0d89d'
    assert_equal digest_value, ETL::Transform::Sha1Transform.new(
      control, nil
    ).transform('test', 'abc', [])
  end
  def test_block_transform
    #transforms = [Proc.new(){|name, value, row| value[0,2]}]
    #assert_equal '11', ETL::Transform::Transform.transform(:ssn, '1111223333', [], transforms)
  end
  def test_decode_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    configuration = {:decode_table_path => 'data/decode.txt'}
    
    t = ETL::Transform::DecodeTransform.new(control, nil, configuration)
    
    assert_equal 'Male', t.transform(nil, 'M', [])
    assert_equal 'Female', t.transform(nil, 'F', [])
    assert_equal 'Unknown', t.transform(nil, '', [])
    assert_equal 'Unknown', t.transform(nil, 'blah', [])
  end
  def test_string_to_date_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    t = ETL::Transform::StringToDateTransform.new(control, nil)
    
    assert_equal Date.parse('2005-01-01'), t.transform(nil, '2005-01-01', [])
    assert_equal Date.parse('2004-10-20 20:30:00'), t.transform(nil, '2004-10-20', [])
  end
  def test_date_to_string_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    t = ETL::Transform::DateToStringTransform.new(control, nil)
    
    d1 = Date.parse('2005-01-01')
    t1 = Time.parse('2004-10-20 23:03:23')
    assert_equal '2005-01-01', t.transform(nil, d1, [])
    assert_equal '2004-10-20', t.transform(nil, t1, [])
    
    t = ETL::Transform::DateToStringTransform.new(control, nil, {:format => '%m/%d/%Y'})
    
    assert_equal '01/01/2005', t.transform(nil, d1, [])
    assert_equal '10/20/2004', t.transform(nil, t1, [])
  end
  def test_string_to_datetime_transform
    v = '1/1/1900 04:34:30'
    t = ETL::Transform::StringToDateTimeTransform.new(flexmock(:control), nil)
    assert_equal DateTime.parse(v), t.transform(nil, v, nil)
  end
  def test_foreign_key_lookup_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
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
  def test_type_transform
    control = ETL::Control::Control.parse(File.dirname(__FILE__) + '/delimited.ctl')
    assert_equal 10, ETL::Transform::TypeTransform.new(control, nil, {:type => :number}).transform(nil, '10', nil)
    
    assert_equal BigDecimal::ROUND_HALF_UP, BigDecimal.mode(BigDecimal::ROUND_MODE)
    decimal_transformed = ETL::Transform::TypeTransform.new(
      control, nil, {:type => :decimal, :scale => 4}
    ).transform(nil, '10.0000000000000000000000000000000001', nil)
    assert_equal '10.0000000000000000000000000000000001', decimal_transformed.to_s('F')
  end
  def test_non_existent_transformer
    
  end
  def test_default_transform
    t = ETL::Transform::DefaultTransform.new(flexmock('control'), nil, {:default_value => 'foo'})
    assert_equal 'foo', t.transform(nil, '', nil)
    assert_equal 'foo', t.transform(nil, nil, nil)
    assert_equal 'bar', t.transform(nil, 'bar', nil)
  end
  def test_ordinalize_transform
    t = ETL::Transform::OrdinalizeTransform.new(flexmock('control'), nil, {})
    assert_equal '1st', t.transform(nil, 1, nil)
    assert_equal '10th', t.transform(nil, 10, nil)
  end
end
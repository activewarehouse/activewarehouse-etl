require File.dirname(__FILE__) + '/test_helper'

# TODO - use flexmock instead, but I'm not sure how to handle the respond_to part yet
class TestResolver
  attr_accessor :cache_loaded
  
  def initialize
    @cache_loaded = false
  end
  
  def load_cache
    @cache_loaded = true
  end
end

class ForeignKeyLookupTransformTest < Test::Unit::TestCase

  context 'configuration' do

    should 'enable cache by default' do
      resolver = TestResolver.new

      transform = ETL::Transform::ForeignKeyLookupTransform.new(nil, 'name',
        {:resolver => resolver})

      assert_equal true, resolver.cache_loaded
    end
    
    should 'allow to disable cache' do
      resolver = TestResolver.new

      transform = ETL::Transform::ForeignKeyLookupTransform.new(nil, 'name',
        {:resolver => resolver, :cache => false})
        
      assert_equal false, resolver.cache_loaded
    end

    should 'allow to enable cache' do
      resolver = TestResolver.new

      transform = ETL::Transform::ForeignKeyLookupTransform.new(nil, 'name',
        {:resolver => resolver, :cache => true})
        
      assert_equal true, resolver.cache_loaded
    end
    
  end
  

end
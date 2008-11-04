require File.dirname(__FILE__) + '/test_helper'

# Test generators
class GeneratorTest < Test::Unit::TestCase
  # Test the surrogate key generator
  def test_surrogate_key_generator
    generator_class = ETL::Generator::Generator.class_for_name(:surrogate_key)
    assert ETL::Generator::SurrogateKeyGenerator, generator_class
    generator = generator_class.new
    1.upto(10) do |i|
      assert_equal i, generator.next
    end
  end
end
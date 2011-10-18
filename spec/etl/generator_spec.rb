require 'spec_helper'

describe ETL::Generator do
  describe '.class_for_name' do
    let(:generator_class) { ETL::Generator.class_for_name(:surrogate_key) }

    it 'should find the class for a given name, if it is defined' do
      generator_class.should be ETL::Generator::SurrogateKeyGenerator
    end
  end
end

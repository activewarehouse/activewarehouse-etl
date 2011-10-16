require 'spec_helper'

describe ETL::Transform::DefaultTransform do
  let(:tf) { ETL::Transform::DefaultTransform.new(double('control'), nil, {:default_value => 'foo'}) }

  describe '#transform' do
    it 'should convert the string to an integer' do
      tf.transform(nil, '', nil).should     == 'foo'
      tf.transform(nil, nil, nil).should    == 'foo'
      tf.transform(nil, 'bar', nil).should  == 'bar'
    end
  end

end

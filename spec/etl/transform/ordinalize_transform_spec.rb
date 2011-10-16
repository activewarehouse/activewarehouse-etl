require 'spec_helper'

describe ETL::Transform::OrdinalizeTransform do
  let(:tf) { ETL::Transform::OrdinalizeTransform.new(double('control'), nil, {}) }

  describe '#transform' do
    it 'should convert the string to an integer' do
      tf.transform(nil, 1, nil).should  == '1st'
      tf.transform(nil, 10, nil).should == '10th'
    end
  end

end

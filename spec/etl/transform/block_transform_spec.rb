require 'spec_helper'

describe ETL::Transform::BlockTransform do
  let(:transform) { proc {|name, value, row| value[0,2]} }

  describe '#transform' do
    it "should execute the block and pass on its return value" do
      ETL::Transform::Transform.transform(:ssn, '1111223333', [], [transform]).should == '11'
    end
  end

end

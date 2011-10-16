require 'spec_helper'

describe ETL::Transform::TypeTransform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control.parse(ctl_file) }

  describe '#transform' do
    # @todo: Use :integer instead?
    context "When the transform's :type is :number" do
      let(:tf) { ETL::Transform::TypeTransform.new(control, nil, {:type => :number}) }

      it 'should convert the string to an integer' do
        tf.transform(nil, '10', nil).should be 10
      end

      # @todo: 'number' should support any kind of numeric transform, IMO.
      #
      # it 'should convert the string to a float' do
      #   tf.transform(nil, '10.1', nil).should == 10.1
      # end
    end

    context "When the transform's :type is :decimal" do
      let(:tf) { ETL::Transform::TypeTransform.new(control, nil, {:type => :decimal, :scale => 4}) }
      let(:big_decimal) { '10.0000000000000000000000000000000001' }

      it 'should set a default rounding mode for BigDecimal' do
        BigDecimal.mode(BigDecimal::ROUND_MODE).should == BigDecimal::ROUND_HALF_UP
      end

      it 'should convert the string to an decimal' do
        tf.transform(nil, big_decimal, nil).to_s('F').should == big_decimal
      end
    end
  end

end

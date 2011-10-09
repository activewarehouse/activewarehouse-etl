require 'spec_helper'

describe ETL::Control::Source do
  let(:source) { described_class }

  describe '#initialize' do
    context 'Store Locally' do
      it 'should be true by default' do
        source.new(nil, { }, nil).store_locally.should be_true
      end

      it 'should be true if the user sets :store_locally to true' do
        source.new(nil, { :store_locally => true }, nil).store_locally.should be_true
      end

      it 'should be false if the user sets :store_locally to false' do
        source.new(nil, { :store_locally => false }, nil).store_locally.should be_false
      end
    end
  end
end

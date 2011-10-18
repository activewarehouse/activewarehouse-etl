require 'spec_helper'

describe ETL::Generator::SurrogateKeyGenerator do
  let(:generator) { described_class.new }

  describe '#next' do
    it "should create numbers in a sequence" do
      one_to_ten = 1..10

      one_to_ten.map{ generator.next }.should == [*one_to_ten]
    end
  end
end

require 'spec_helper'

describe ETL::Processor::EnsureFieldsPresenceProcessor do
  let(:processor) { described_class.new(nil, {}) }

  describe '#initialize' do
    context "Invalid Arguments" do
      it 'should raise an error unless :fields is specified' do
        expect {  processor  }.to raise_error(ETL::ControlError, ":fields must be specified")
      end
    end
  end

  describe '#process' do
    context "When a field is present in the given row" do
      let(:processor) { described_class.new(nil, {:fields => [:first, :second]}) }

      it 'should return the row if the required fields are in the row' do
        row = ETL::Row[:first => nil, :second => "Barry"]
        processor.process(row)
      end
    end

    context "When a field is missing from the row" do
      let(:processor) { described_class.new(nil, {:fields => [:key]}) }

      it "should raise an ETL::ControlError" do
        expect {  processor.process(ETL::Row[])  }.to raise_error(ETL::ControlError, /missing required field\(s\)/)
      end
    end
  end
end

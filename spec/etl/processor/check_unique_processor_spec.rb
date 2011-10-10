require 'spec_helper'

describe ETL::Processor::CheckUniqueProcessor do
  # @todo: Do.
  let(:processor) { ETL::Processor::CheckUniqueProcessor.new(nil, :keys => [:first, :second]) }

  it "should keep a row whose keys didn't already appear in the pipeline" do
    row = ETL::Row[:first => 'A', :second => 'B']

    processor.process(row).should == row
    processor.compound_key_constraints.should == { 'A|B' => 1 }
  end

  it "should remove a row whose keys already appeared in the pipeline" do
    row = ETL::Row[:first => 'A', :second => 'B']

    processor.process(row).should == row
    processor.process(row).should == nil
  end

  it "should raise an error if a row lacks one of the keys specified" do
    row = ETL::Row[:first => 'A']

    expect {
      processor.process(row)
    }.to raise_exception(ETL::ControlError, "Row missing required field :second for unicity check")
  end
end

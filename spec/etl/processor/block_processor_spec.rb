require 'spec_helper'

describe ETL::Processor::BlockProcessor do
  class TestWitness; end

  let(:ctl_file) { fail 'You should set me.' }
  let(:mock_source) { fail 'You should set me.' }
  let(:mock_dest) { fail 'You should set me.' }

  let(:process!) { ETL::Engine.process(ctl_file) }

  before {
    mock_source
    process!
  }

  context "When used as an After-Read or a Before-Write Processor" do
    let(:ctl_file) { fixture_path('block_processor.ctl') }
    let(:mock_source) { MockSource[:block_processed_input] = [{ :first_name => 'John'},{:first_name => 'Gary'}] }
    let(:mock_dest) { MockDestination[:block_processed_output] }

    it "should output 4 rows: the two input rows, and two new rows" do
      mock_dest.should have(4).items
    end

    it "should add fields to the input rows, and create a new row from each input" do
      mock_dest.should == [
        { :first_name => 'John', :added_by_after_read => 'after-John', :added_by_before_write => "Row 1" },
        { :new_row => 'added by post_processor' },
        { :first_name => 'Gary', :added_by_after_read => 'after-Gary', :added_by_before_write => "Row 2" },
        { :new_row => 'added by post_processor' },
      ]
    end
  end

  context "When used as a Pre-Processor or a Post-Processor" do
    let(:ctl_file) { fixture_path('block_processor_pre_post_process.ctl') }
    let(:mock_dest) { MockDestination[:another_output] }
    let(:mock_source) { MockSource[:another_input] = [{ :obsolete => true, :name => 'John'},{ :obsolete => false, :name => 'Gary'}] }

    let(:process!) do
      TestWitness.should_receive(:call).with("I'm called from pre_process")
      TestWitness.should_receive(:call).with("I'm called from post_process")

      ETL::Engine.process(ctl_file)
    end

    # @todo: Not a very useful test.
    it "should be called during the pre-process and post-process steps" do
      mock_source.should == mock_dest
    end
  end

  context "Discarding / Removing a given row" do
    let(:ctl_file) { fixture_path('block_processor_remove_rows.ctl') }
    let(:mock_source) { MockSource[:block_input] = [{ :obsolete => true, :name => 'John'},{ :obsolete => false, :name => 'Gary'}] }
    let(:mock_dest) { MockDestination[:block_output] }

    it "should remove a row if nil is returned" do
      mock_dest.should == [{ :obsolete => false, :name => 'Gary' }] # only one record should be kept
    end
  end

  context "Error propagation" do
    let(:ctl_file) { fixture_path('block_processor_error.ctl') }
    let(:mock_source) { }
    let(:process!) { }

    it "should allow an exception to be raised" do
      expect {
        ETL::Engine.process(ctl_file)
      }.to raise_error(ETL::ControlError)
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe ETL::Processor::EncodeProcessor do
  let(:control)   { double('control') }
  let(:ctl_file)  { fixture_root.join 'fake-control.ctl' }

  describe "Encoding Conversion" do
    let(:source_file) { 'data/encode_source_latin1.txt' }
    let(:target_file) { 'output/encode_destination_utf-8.txt' }

    let(:source) { source_file }
    let(:target) { target_file }

    context "When the specified encodings are valid (known encodings)" do
      let(:configuration) { {:source_file => source, :source_encoding => 'latin1', :target_file => target, :target_encoding => 'utf-8'} }

      context "When the source / target files have relative paths" do
        before(:each) { control.should_receive(:file).twice.and_return(ctl_file) }

        it 'should correctly transform the source file' do
          ETL::Processor::EncodeProcessor.new(control, configuration).process

          fixture_for(target).should == "éphémère has accents.\nlet's encode them."
        end
      end

      context "When the source / target files have fully-qualified paths" do
        let(:source) { fixture_path(source_file) }
        let(:target) { fixture_root(target_file) }

        before(:each) { control.stub(:file) { fail 'control.file should not be called' } }

        it 'should correctly transform the source file' do
          ETL::Processor::EncodeProcessor.new(control, configuration).process

          fixture_for(target_file).should == "éphémère has accents.\nlet's encode them."
        end
      end
    end

    context "When the encoding is not known (and therefore, invalid)" do
      let(:configuration) { {:source_file => source, :source_encoding => 'an-invalid-encoding', :target_file => target, :target_encoding => 'utf-8'} }

      before(:each) { control.should_receive(:file).twice.and_return(ctl_file) }

      it "should raise an ETL::ControlError" do
        expect {
          ETL::Processor::EncodeProcessor.new(control, configuration)
        }.to raise_exception(ETL::ControlError, "Either the source encoding 'an-invalid-encoding' or the target encoding 'utf-8' is not supported")
      end
    end

    context "When the source and destination are the same" do
      let(:configuration) { {:source_file => source, :source_encoding => 'latin1', :target_file => source, :target_encoding => 'utf-8'} }

      before(:each) { control.should_receive(:file).twice.and_return(ctl_file) }

      it "should raise an ETL::ControlError" do
        expect {
          ETL::Processor::EncodeProcessor.new(control, configuration)
        }.to raise_exception(ETL::ControlError, "Source and target file cannot currently point to the same file")
      end
    end
  end
end

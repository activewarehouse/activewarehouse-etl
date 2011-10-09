require 'spec_helper'

describe ETL::Engine do
  describe 'Integrations' do
    context "When using a single delimited file as the source" do
      let(:delimited_ctl)     { fixture_path('delimited.ctl') }
      let(:delimited_outfile) { File.readlines(fixture_path('output/delimited.txt')) }

      it "should process the control file with no errors" do
        expect {
          ETL::Engine.process(delimited_ctl)
        }.to_not raise_exception
      end

      it "should write all lines, from the source, to the destination" do
        ETL::Engine.process(delimited_ctl)

        delimited_outfile.should have(3).items
      end

      it "should write each record, to the destination, as described in the control file" do
        ETL::Engine.process(delimited_ctl)

        delimited_outfile.map! { |line| line.split(',') }

        delimited_outfile.each_with_index do |record, index|
          record.should have(8).items
          record.first.should == (index + 1).to_s

          expect {
            Time.parse record.last
          }.to_not raise_exception
        end
      end
    end
  end
end

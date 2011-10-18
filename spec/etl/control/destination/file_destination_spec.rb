require 'spec_helper'

describe ETL::Control::FileDestination do
  let(:ctl_file){ fixture_path 'delimited.ctl' }
  let(:control) { ETL::Control::Control.parse(ctl_file) }
  let(:mapping) do
    country_codes = { 'United States' => 'US', 'Mexico' => 'MX' }
    cc_proc = proc {|r| country_codes[r[:country]]}

    {:order => [:address, :city, :state, :country, :country_code], :virtual => { :country_code => cc_proc }}
  end

  let(:outfile) { fixture_root 'output/test_file_destination.txt' }
  let(:output) { File.read(outfile) }

  let(:destination) { ETL::Control::FileDestination.new(control, configuration, mapping) }

  let(:simple_row) { ETL::Row[ :address => '123 SW 1st Street', :city => 'Melbourne', :state => 'Florida', :country => 'United States' ] }
  let(:row_needs_escape) { ETL::Row[ :address => "Allen's Way", :city => 'Some City', :state => 'Some State', :country => 'Mexico' ] }

  before(:each) {
    destination.write(simple_row)
    destination.write(row_needs_escape)
    destination.close
  }

  context "When using the destination's defaults" do
    let(:configuration) { {:file => outfile, :buffer_size => 0} }

    it "should output a standard CSV style document" do
      output.should == <<-DOCUMENT
123 SW 1st Street,Melbourne,Florida,United States,US
Allen's Way,Some City,Some State,Mexico,MX
DOCUMENT
    end
  end

  context "When using custom options for the document's output" do
    let(:configuration) { {:file => outfile, :buffer_size => 0, :separator => '|', :eol => "[EOL]\n"} }

    it "should use the custom separator / eol character(s)" do
      output.should == <<-DOCUMENT
123 SW 1st Street|Melbourne|Florida|United States|US[EOL]
Allen's Way|Some City|Some State|Mexico|MX[EOL]
DOCUMENT
    end
  end
end

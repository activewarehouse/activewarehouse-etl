require 'spec_helper'

describe ETL::Control::ExcelDestination do
  let(:ctl_file){ fixture_path 'delimited_excel.ctl' }
  let(:control) { ETL::Control::Control.parse(ctl_file) }
  let(:mapping) do
    country_codes = { 'United States' => 'US', 'Mexico' => 'MX' }
    cc_proc = proc {|r| country_codes[r[:country]]}

    {:order => [:address, :city, :state, :country, :country_code], :virtual => { :country_code => cc_proc }}
  end

  let(:configuration) { {:file => outfile, :buffer_size => 0} }

  let(:outfile) { fixture_root 'output/test_excel_destination.xls' }
  let(:output) { File.read(outfile) }

  let(:destination) { ETL::Control::ExcelDestination.new(control, configuration, mapping) }

  let(:row) { ETL::Row[ :address => '123 SW 1st Street', :city => 'Melbourne', :state => 'Florida', :country => 'United States' ] }

  before(:each) {
    destination.write(row)
    destination.close
  }

  context "When using the destination's defaults" do
    let(:book) { Spreadsheet.open(outfile) }
    let(:sheet) { book.worksheet(0) }

    it "should output a basic Excel document" do
      sheet[0, 0].should == "123 SW 1st Street"
      sheet[0, 1].should == "Melbourne"
      sheet[0, 2].should == "Florida"
      sheet[0, 3].should == "United States"
      sheet[0, 4].should == "US"
    end
  end
end

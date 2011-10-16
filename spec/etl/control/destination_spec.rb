require 'spec_helper'

describe ETL::Control::Destination do
  let(:ctl_file){ fixture_path 'delimited.ctl' }
  let(:control) { ETL::Control.parse(ctl_file) }

  let(:outfile) { fixture_root 'output/test_unique.txt' }
  let(:output) { File.read(outfile) }

  let(:mapping) { {:order => [:first_name, :last_name, :ssn]} }

  let(:destination) { ETL::Control::FileDestination.new(control, configuration, mapping) }

  let(:row1) { ETL::Row[:id => 1, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']  }
  let(:row2) { ETL::Row[:id => 2, :first_name => 'Bob', :last_name => 'Smith', :ssn => '111234444']  }
  let(:row3) { ETL::Row[:id => 3, :first_name => 'John', :last_name => 'Smith', :ssn => '000112222'] }

  context "when the destinations are valid" do
    before(:each) {
      destination.write(row1)
      destination.write(row2)
      destination.write(row3)
      destination.close
    }

    context "When outputing only the records that are unique to a single column" do
      let(:configuration) { {:file => outfile, :buffer_size => 0, :unique => [:ssn]} }

      it "should exclude rows with a duplicate value, for the given column" do
        output.should == <<-DOCUMENT
Bob,Smith,111234444
John,Smith,000112222
DOCUMENT
      end
    end

    context "When outputing only the records that are unique across multiple columns" do
      let(:row3) { ETL::Row[:id => 3, :first_name => 'Bob', :last_name => 'Smith', :ssn => '000112222'] }
      let(:configuration) { {:file => outfile, :buffer_size => 0, :unique => [:last_name,:first_name]} }

      it "should exclude rows with a duplicate value, for the set of columns" do
        output.should == <<-DOCUMENT
Bob,Smith,111234444
DOCUMENT
      end
    end
  end

  context "When the destination is bad" do
    let(:bad_destination) {
      Class.new(ETL::Control::Destination) do
        def initialize(control, configuration, mapping)
          super
        end
      end
    }

    let(:control) { control = ETL::Control.parse_text('') }
    let(:configuration) { {} }
    let(:mapping) { {} }
    let(:destination) { bad_destination.new(control, configuration, mapping) }

    it "should raise an error" do
      destination.write(nil)

      expect {
        destination.flush
      }.to raise_error(NotImplementedError)

      expect {
        destination.close
      }.to raise_error(NotImplementedError)
    end
  end
end

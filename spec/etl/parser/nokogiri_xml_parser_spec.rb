require 'spec_helper'

describe ETL::Parser::NokogiriXmlParser do
  it_should_behave_like 'ETL::Parser', 'xml.ctl'

  context "Parsing Nodes in an XML document" do
    let(:control) { ETL::Control.resolve(ctl_file) }
    let(:parser)  { ETL::Parser::NokogiriXmlParser.new(control.sources.first) }
    let(:rows)    { parser.collect { |row| row } }

    context "For all nodes" do
      let(:ctl_file)  { fixture_path('nokogiri_all.ctl') }

      it "should parse all elements in the collection" do
        rows.should have(3).items
        rows.first.should == {:first_name=>"Bob", :last_name=>"Smith", :ssn=>"123456789", :age=>"24", :hair_colour=>"black"}
      end
    end

    context "For only selected nodes" do
      let(:ctl_file)  { fixture_path('nokogiri_select.ctl') }

      it "should only parse elements of type 'client' in the collection" do
        rows.should have(2).items
        rows.first.should == {:first_name=>"Jane", :last_name=>"Doe", :ssn=>"111223333", :age=>"45", :hair_colour=>"blond"}
      end
    end
  end
end

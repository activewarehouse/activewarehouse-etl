require 'spec_helper'

shared_examples_for 'ETL::Parser' do |fixture_file|
  let(:ctl_file)  { fixture_path(fixture_file) }
  let(:control)   { ETL::Control.resolve(ctl_file) }
  let(:parser)    { described_class.new(control.sources.first) }

  describe '#initialize' do
    it "should store the field names, if provided" do
      parser.fields.should have(5).items
    end
  end

  describe '#each' do
    let(:rows) { parser.collect { |row| row } }

    it "should read each record from the Source file(s)" do
      rows.should have(3).items
    end

    it "should correctly read/parse records from the source file" do
      rows.first.should == {:first_name=>"Chris", :last_name=>"Smith", :ssn=>"111223333", :age=>"24", :sex => 'M'}
    end
  end

end

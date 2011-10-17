require 'spec_helper'

# @todo: Fix namespace structure. Should be ETL::Control::Source::FileSource
describe ETL::Control::FileSource do
  let(:ctl_file)    { fail "ctl_file must first be defined, at line -#{__LINE__}- in the file #{__FILE__}." }
  let(:src_config)  { fail "src_config must first be defined, at line -#{__LINE__}- in the file #{__FILE__}." }

  let(:control)     { ETL::Control::Control.parse(ctl_file) }
  let(:definition)  { [ :first_name, :last_name, :ssn, { :name => :age, :type => :integer } ] }

  context "When using a single file source" do
    let(:source)  { ETL::Control::FileSource.new(control, src_config, definition) }
    let(:rows)    { source.map { |row| row } }

    context "When using a relative path" do
      let(:ctl_file)    { fixture_path('delimited.ctl') }
      let(:src_config)  { {:file => 'data/delimited.txt', :parser => :csv} }

      before(:each) { definition << :sex }

      it 'should find 3 rows in the delimited file' do
        rows.should have(3).items
      end
    end

    context "When using a relative directory-glob as the file source" do
      let(:ctl_file)    { fixture_path('multiple_delimited.ctl') }
      let(:src_config)  { {:file => 'data/multiple_delimited_*.txt', :parser => :csv} }

      it "should find 6 rows in total" do
        rows.should have(6).items
      end
    end

    # @todo: Not the most useful test?  Oh well?
    context "When using an absolute path" do
      let(:ctl_file)    { fixture_path('delimited_absolute.ctl') }
      let(:src_config)  { {:file => fixture_path('data/delimited.txt'), :parser => :csv} }

      before(:each) { definition << :sex }

      it 'should (again) find 3 rows in the delimited file' do
        rows.should have(3).items
      end
    end

    context "When using a file source with an xml parser" do
      let(:ctl_file)  { fixture_path('xml.ctl') }
      let(:sources)   { control.sources }
      let(:rows)      { sources.map(&:to_a).tap(&:flatten!) }

      it "should find 3 rows" do
        rows.should have(3).items
      end

      it "should only contain file sources" do
        sources.each { |source| source.should be_an_instance_of ETL::Control::FileSource }
      end
    end
  end # When using a single file source

  context "When using multiple file sources" do
    context "multiple_source_delimited.ctl" do
      let(:ctl_file){ fixture_path('multiple_source_delimited.ctl') }
      let(:sources) { control.sources }
      let(:rows)    { sources.map(&:to_a).tap(&:flatten!) }

      it "should contain two sources" do
        control.should have(2).sources
      end

      it "should only contain file sources" do
        sources.each { |source| source.should be_an_instance_of ETL::Control::FileSource }
      end

      it "should find 12 rows in total" do
        rows.should have(12).items
      end
    end
  end # When using multiple file sources
end

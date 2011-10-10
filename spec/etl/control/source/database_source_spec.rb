require 'spec_helper'

# @todo: Fix namespace structure. Should be ETL::Control::Source::DatabaseSource
# @todo: Get rid of DatabaseSource, or make it abstract.
describe ETL::Control::DatabaseSource do
  let(:ctl_file)    { fixture_path('delimited.ctl') }
  let(:db_config)   { {:database => 'etl_unittest', :target => :operational_database, :table => 'people'} }
  let(:definition)  { [:first_name, :last_name, :ssn] }

  let(:target)      { db_config[:target] }
  let(:target_cfg)  { ETL::Base.configurations[target] }
  let(:database)    { target_cfg['database'] }

  let(:control) { ETL::Control.parse(ctl_file) }
  let(:source)  { ETL::Control::DatabaseSource.new(control, db_config, definition) }

  describe '#local_file' do
    context "When store locally is true" do
      let(:database_name) { ETL::Engine }
      let(:local_file_storage_pattern) { %r<source_data/localhost/#{database}/people/\d+.csv> }

      it "should set the local file for extraction storage" do
        source.local_file.should match local_file_storage_pattern
      end
    end

    context "When store locally is false" do
      pending it 'should not set a local file for extraction storage'
    end
  end

  pending "When a schema is imported with default / mock data (factory girl?) -- Or when Database stuff is evicted from the core library" do
    pending "should find 1 row" do
      Person.delete_all
      assert_equal 0, Person.count
      Person.create!(:first_name => 'Bob', :last_name => 'Smith', :ssn => '123456789')
      assert_equal 1, Person.count
      rows = @source.collect { |row| row }
      assert_equal 1, rows.length
    end
  end
end

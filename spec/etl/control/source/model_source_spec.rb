require 'spec_helper'

# @todo: Fix namespace structure. Should be ETL::Control::Source::ModelSource
# @todo: Get rid of ModelSource, or make it abstract. ActiveModelSource? Incompatible with Rails 2.
describe ETL::Control::ModelSource do
  let(:ctl_file)    { fixture_path('delimited.ctl') }
  let(:db_config)   {{ }}
  let(:definition)  { [:first_name, :last_name, :ssn] }

  pending "should find n rows" do
    
  end
end

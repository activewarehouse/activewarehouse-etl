require 'spec_helper'

describe ETL::Transform::Sha1Transform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control.parse(ctl_file) }

  let(:sha1_transform) { ETL::Transform::Sha1Transform.new(control, nil) }

  describe '#transform' do
    it 'should create a SHA1 digest of the input arguments' do
      sha1_transform.transform('test', 'abc', []).should == 'a9993e364706816aba3e25717850c26c9cd0d89d'
    end
  end

end

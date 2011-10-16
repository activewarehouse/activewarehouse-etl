require 'spec_helper'

describe ETL::Transform::DecodeTransform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control.parse(ctl_file) }

  let(:configuration) { {:decode_table_path => 'data/decode.txt'} }
  let(:decode_transform) { ETL::Transform::DecodeTransform.new(control, nil, configuration) }

  describe '#transform' do
    it 'should use the decode table (flatfile) to transform the input data' do
      decode_transform.transform(nil, 'M',    []).should == 'Male'
      decode_transform.transform(nil, 'F',    []).should == 'Female'
      decode_transform.transform(nil, '',     []).should == 'Unknown'
      decode_transform.transform(nil, 'blah', []).should == 'Unknown'
    end
  end

end

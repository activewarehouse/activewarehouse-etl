require 'spec_helper'

describe ETL::Transform::StringToDateTransform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control.parse(ctl_file) }

  let(:transform) { ETL::Transform::StringToDateTimeTransform.new(double('control'), nil) }

  describe '#transform' do
    it 'should convert the string to a DateTime object' do
      transform.transform(nil, '1/1/1900 04:34:30', nil).should == DateTime.parse('1/1/1900 04:34:30')
    end
  end

end

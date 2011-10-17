require 'spec_helper'

describe ETL::Transform::StringToDateTransform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control::Control.parse(ctl_file) }

  let(:transform) { ETL::Transform::StringToDateTransform.new(control, nil) }

  describe '#transform' do
    it 'should convert the string to a Date object' do
      transform.transform(nil, '2005-01-01', []).should == Date.parse('2005-01-01')
      transform.transform(nil, '2004-10-20', []).should == Date.parse('2004-10-20 20:30:00')
    end
  end

end

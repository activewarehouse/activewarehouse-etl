require 'spec_helper'

describe ETL::Transform::DateToStringTransform do
  let(:ctl_file) { fixture_path('delimited.ctl') }
  let(:control) { ETL::Control::Control.parse(ctl_file) }

  context "Using the default options" do
    let(:transform) { ETL::Transform::DateToStringTransform.new(control, nil) }

    it "should transform the date into the default string format" do
      transform.transform(nil, Date.parse('2005-01-01'), []).should == '2005-01-01'
      transform.transform(nil, Time.parse('2004-10-20 23:03:23'), []).should == '2004-10-20'
    end
  end

  context "When using a custom format" do
    let(:transform) { ETL::Transform::DateToStringTransform.new(control, nil, {:format => '%m/%d/%Y'}) }

    it "should output a string that matches the custom formatting" do
      transform.transform(nil, Date.parse('2005-01-01'), []).should == '01/01/2005'
      transform.transform(nil, Time.parse('2004-10-20 23:03:23'), []).should == '10/20/2004'
    end
  end

end

require 'spec_helper'

describe ETL::Control do
  let(:delimited_ctl) { fixture_path('delimited.ctl') }

  describe '.parse' do
    context "When parsing valid control files" do
      it "should not raise an exception" do
        expect {
          ETL::Control::Control.parse(delimited_ctl)
        }.to_not raise_exception
      end

      it "should internalize the DSL statements, in the control file" do
        control = ETL::Control::Control.parse(delimited_ctl)
        control.sources.should      have(1).items
        control.transforms.should   have(3).items
        control.destinations.should have(1).items
      end
    end
  end

  describe '.resolve' do
    context "Valid Arguments" do
      it "should be able to resolve an instance of Control" do
        expect {
          ETL::Control::Control.resolve(ETL::Control::Control.parse(delimited_ctl))
        }.to_not raise_exception
      end
    end

    context "Invalid Arguments" do
      it "should raise an ETL::ControlError" do
        expect {
          ETL::Control::Control.resolve(0)
        }.to raise_exception(ETL::ControlError)
      end
    end
  end

  describe '.parse_text' do
    context "Valid Arguments" do
      it "should correctly parse dependencies" do
        s = "depends_on 'foo', 'bar'"
        control = ETL::Control::Control.parse_text(s)
        control.dependencies.should == ['foo','bar']
      end

      it "should allow the error threshhold to be set" do
        s = "set_error_threshold 1"
        control = ETL::Control::Control.parse_text(s)
        control.error_threshold.should be 1
      end
    end

    context "Invalid Arguments" do
      it "should raise an ETL::ControlError" do
        expect {
          s = "before_write :chunky_monkey"
          ETL::Control::Control.parse_text(s)
        }.to raise_exception(ETL::ControlError)
      end
    end
  end

end

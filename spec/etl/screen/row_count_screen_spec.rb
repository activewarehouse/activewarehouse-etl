require 'spec_helper'

describe ETL::Screen::RowCountScreen do
  let(:screen_test_fatal) { fixture_path('screen_test_fatal.ctl') }

  context "When processed as part of a CTL file" do
    context "When the row count expectation is not met" do
      it "should raise a SystemExit error (@todo: Really?)" do
        expect {
          ETL::Engine.process(screen_test_fatal)
        }.to raise_error(SystemExit)
      end
    end
  end
end

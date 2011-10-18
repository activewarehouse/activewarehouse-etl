require 'spec_helper'

describe ETL::Parser::FixedWidthParser do
  it_should_behave_like 'ETL::Parser', 'fixed_width.ctl'
end

require 'spec_helper'

describe ETL::Parser::CsvParser do
  it_should_behave_like 'ETL::Parser', 'delimited.ctl'
end

require 'spec_helper'

describe ETL::Parser::SaxParser do
  it_should_behave_like 'ETL::Parser', 'sax.ctl'
end

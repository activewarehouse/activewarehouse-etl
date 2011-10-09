require 'spec_helper'

describe ETL::Parser::NokogiriXmlParser do
  it_should_behave_like 'ETL::Parser', 'xml.ctl'
end

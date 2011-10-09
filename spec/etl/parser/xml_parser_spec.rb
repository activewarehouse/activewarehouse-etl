require 'spec_helper'

describe ETL::Parser::XmlParser do
  it_should_behave_like 'ETL::Parser', 'xml.ctl'
end

require 'spec_helper'

describe ETL::Parser::ExcelParser do
  context 'excel.ctl' do
    it_should_behave_like 'ETL::Parser', 'excel.ctl'
  end

  context 'excel2.ctl' do
    it_should_behave_like 'ETL::Parser', 'excel2.ctl'
  end
end

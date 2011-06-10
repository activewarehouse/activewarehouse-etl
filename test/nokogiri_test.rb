require File.dirname(__FILE__) + '/test_helper'

# Test the flat text parsers
class ParserTest < Test::Unit::TestCase

  # Test the DOM-based Nokogiri XML parser. .
  def test_nokogiri_xml_parser_for_all_nodes
    control = ETL::Control::Control.resolve(
      File.dirname(__FILE__) + '/nokogiri_all.ctl')
    parser = ETL::Parser::NokogiriXmlParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal(
      { :hair_colour=>"black",
        :first_name=>"Bob", 
        :last_name=>"Smith", 
        :ssn=>"123456789", :age=>"24"}, rows.first)
  end

  # Test the DOM-based Nokogiri XML parser. .
  def test_nokogiri_xml_parser_for_selected_nodes
    control = ETL::Control::Control.resolve(
      File.dirname(__FILE__) + '/nokogiri_select.ctl')
    parser = ETL::Parser::NokogiriXmlParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 2, rows.length
    assert_equal(
      { :age=>"37",
        :hair_colour=>"black",
        :first_name=>"Jake",
        :last_name=>"Smithsonian",
        :ssn=>"133244566"}, rows.last)
  end

end

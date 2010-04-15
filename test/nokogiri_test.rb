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

  # Test the DOM-based Nokogiri XML Reader parser. .
  def test_nokogiri_xml_reader_parser_for_all_nodes
    control = ETL::Control::Control.resolve(
      File.dirname(__FILE__) + '/nokogiri_reader.ctl')
    parser = ETL::Parser::NokogiriXmlReaderParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal(
      { :hair_colour=>"black",
        :first_name=>"Bob", 
        :last_name=>"Smith", 
        :ssn=>"123456789", 
        :age=>"24"}, rows.first)
  end


=begin
  # Test the DOM-based Nokogiri XML Reader parser for selected nodes.
  # This might actaully be meaningless in the node by node selection
  # processs employed by reader.  If so then we will remove it.
  def test_nokogiri_xml_reader_parser_for_selected_nodes
    control = ETL::Control::Control.resolve(
      File.dirname(__FILE__) + '/nokogiri_reader.ctl')
    parser = ETL::Parser::NokogiriXmlReaderParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 2, rows.length
    assert_equal(
      { :age=>"37",
        :hair_colour=>"black",
        :first_name=>"Jake",
        :last_name=>"Smithsonian",
        :ssn=>"133244566"}, rows.last)
  end


   # Test the Nokogiri XML SAX parser which does not have a separate listener
   # class.  Subclass Nokogiri::XML::SAX::Document and implement listener
   # events in the subclass.  Then instantiate the subclass as the parser.
  def test_nokogiri_sax_parser
    control = ETL::Control::Control.resolve(
      File.dirname(__FILE__) + '/nokogiri_sax.ctl')
    parser = control.sources.first.parser
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal(
      { :hair_colour=>"black",
        :first_name=>"Bob", 
        :last_name=>"Smith", 
        :ssn=>"123456789", 
        :age=>"24"}, rows.first)
  end
=end

end

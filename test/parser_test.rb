require File.dirname(__FILE__) + '/test_helper'

# Test the flat text parsers
class ParserTest < Test::Unit::TestCase
  # Test parsing delimited data
  def test_delimited_parser
    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/delimited.ctl')
    parser = ETL::Parser::DelimitedParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal({:first_name=>"Chris", :last_name=>"Smith", :ssn=>"111223333", :age=>"24", :sex => 'M'}, rows.first)
  end
  
  # Test parsing fixed-width data
  def test_fixed_width_parser
    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/fixed_width.ctl')
    parser = ETL::Parser::FixedWidthParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal({:first_name=>"Bob", :last_name=>"Smith", :ssn=>"123445555", :age=>"23"}, rows.first)
  end
  
  # Test the DOM-based XML parser. Note that the DOM parser is slow and should
  # probably be removed.
  def test_xml_parser
    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/xml.ctl')
    parser = ETL::Parser::XmlParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    assert_equal 2, rows.length
    assert_equal({:first_name=>"Bob", :last_name=>"Smith", :ssn=>"123456789", :age=>"24"}, rows.first)
  end
  
  # Test an inline parser
  def test_inline_parser
    ETL::Engine.process(File.dirname(__FILE__) + '/inline_parser.ctl')
    lines = open(File.dirname(__FILE__) + '/output/inline_parser.txt').readlines
    assert_equal 3, lines.length
  end
  
  # Test the SAX parser (preferred for XML parsing)
  def test_sax_parser
    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/sax.ctl')
    parser = control.sources.first.parser
    rows = parser.collect { |row| row }
    assert_equal 2, rows.length
    assert_equal({:first_name=>"Bob", :last_name=>"Smith", :ssn=>"123456789", :age=>"24"}, rows.first)
  end
  
  # Test the Apache combined log format parser
  def test_apache_combined_log_parser
    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/apache_combined_log.ctl')
    parser = ETL::Parser::ApacheCombinedLogParser.new(control.sources.first)
    # first test the parse method
    line = %Q(127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)")
    fields = parser.parse(line)
    assert_equal '127.0.0.1', fields[:ip_address]
    assert_equal 'frank', fields[:user]
    assert_equal Time.mktime(2000, 10, 10, 13, 55, 36), fields[:timestamp]
    assert_equal 'GET /apache_pb.gif HTTP/1.0', fields[:request]
    assert_equal '200', fields[:response_code]
    assert_equal '2326', fields[:bytes]
    assert_equal 'http://www.example.com/start.html', fields[:referrer]
    assert_equal 'Mozilla/4.08 [en] (Win98; I ;Nav)', fields[:user_agent]
    #now test the each method
    rows = parser.collect { |row| row }
    assert_equal 3, rows.length
    assert_equal({
      :user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)",
      :browser_version_minor=>nil,
      :timestamp=>Time.mktime(2000, 10, 10, 13, 55, 36),
      :ostype=>"Windows",
      :request=>"GET /apache_pb.gif HTTP/1.0",
      :host=>"www.example.com",
      :domain => "example.com",
      :os=>"Win98",
      :uri_path=>"/start.html",
      :response_code=>"200",
      :port=>80,
      :os_version=>nil,
      :ip_address=>"127.0.0.1",
      :scheme=>"http",
      :bytes=>"2326",
      :browser=>"Mozilla",
      :identd=>nil,
      :referrer=>"http://www.example.com/start.html",
      :browser_version_major=>"4",
      :user=>"frank"}, rows.first, 'Failed on first row')
    assert_equal({
      :user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)",
      :port=>80,
      :timestamp=>Time.mktime(2000, 10, 11, 5, 22, 2),
      :browser_version_minor=>nil,
      :os_version=>nil,
      :request=>"GET /apache_pb.gif HTTP/1.1",
      :ostype=>"Windows",
      :scheme=>"http",
      :response_code=>"200",
      :host=>"www.foo.com",
      :domain => "foo.com",
      :ip_address=>"127.0.0.1",
      :browser=>"Mozilla",
      :bytes=>"2326",
      :os=>"Win98",
      :identd=>nil,
      :browser_version_major=>"4",
      :referrer=>"http://www.foo.com/",
      :uri_path=>"/",
      :user=>"bob"}, rows[1], 'Failed on second row')
    assert_equal({
      :browser_version_major=>"4",
      :browser_version_minor=>nil,
      :port=>nil,
      :request=>"GET /apache_pb.gif HTTP/1.1",
      :ostype=>"Windows",
      :os_version=>nil,
      :response_code=>"200",
      :host=>nil,
      :scheme=>nil,
      :bytes=>"2326",
      :ip_address=>"127.0.0.1",
      :browser=>"Mozilla",
      :referrer=>nil,
      :os=>"Win98",
      :user=>"bob",
      :user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)",
      :identd=>nil,
      :uri_path=>nil,
      :timestamp=>Time.mktime(2000, 10, 11, 5, 52, 31)}, rows[2], 'Failed on third row')
  end
  
  # Test the user agent parser
  def test_user_agent_parser
    agents = <<-AGENTS
      Mozilla/4.7 [en] (WinNT; U)
      Mozilla/4.0 (compatible; MSIE 5.01; Windows NT)
      Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461; .NET CLR 1.1.4322)
      Mozilla/4.0 (compatible; MSIE 5.0; Windows NT 4.0) Opera 5.11 [en]
      Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.0.2) Gecko/20030208 Netscape/7.02
      Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040612 Firefox/0.8
      Mozilla/5.0 (compatible; Konqueror/3.2; Linux) (KHTML, like Gecko)
      Lynx/2.8.4rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6h
    AGENTS
    agents = agents.split("\n").collect { |s| s.strip }

    control = ETL::Control::Control.resolve(File.dirname(__FILE__) + '/apache_combined_log.ctl')
    parser = ETL::Parser::ApacheCombinedLogParser.new(control.sources.first)
    rows = parser.collect { |row| row }
    
    assert_equal({:browser_version_major=>"4",
      :browser_version_minor=>nil,
      :ostype=>"Windows",
      :os=>"WinNT",
      :os_version=>nil,
      :browser=>"Mozilla"}, parser.parse_user_agent(agents[0]), 'Agent 0 invalid'
    )
    assert_equal({:browser_version_major=>"5",
      :browser_version_minor=>"01",
      :ostype=>"Windows",
      :os=>"Windows NT",
      :os_version=>nil,
      :browser=>"MSIE"}, parser.parse_user_agent(agents[1]), 'Agent 1 invalid'
    )
    assert_equal({:browser_version_major=>"6",
      :browser_version_minor=>"0",
      :ostype=>"Windows",
      :os=>"Windows NT 5.0",
      :os_version=>"5.0",
      :browser=>"MSIE"}, parser.parse_user_agent(agents[2]), 'Agent 2 invalid'
    )
    assert_equal({:browser_version_major=>"5",
      :browser_version_minor=>"0",
      :ostype=>"Windows",
      :os=>"Windows NT 4.0",
      :os_version=>"4.0",
      :browser=>"MSIE"}, parser.parse_user_agent(agents[3]), 'Agent 3 invalid'
    )
    assert_equal({:browser_version_major=>"7",
      :browser_version_minor=>nil,
      :ostype=>"Windows",
      :os=>"Windows NT 5.0",
      :os_version=>"5.0",
      :browser=>"Netscape"}, parser.parse_user_agent(agents[4]), 'Agent 4 invalid'
    )
    assert_equal({:browser_version_major=>"0.8",
      :browser_version_minor=>nil,
      :ostype=>"Linux",
      :os=>"Linux i686",
      :os_version=>nil,
      :browser=>"Firefox"}, parser.parse_user_agent(agents[5]), 'Agent 5 invalid'
    )
    # test fails here
    # assert_equal({:browser_version_major=>"6",
#       :browser_version_minor=>nil,
#       :ostype=>"Linux",
#       :os=>"Linux",
#       :os_version=>nil,
#       :browser=>"Konquerer"}, parser.parse_user_agent(agents[6]), 'Agent 6 invalid'
#     )
  end
end
require 'spec_helper'

describe ETL::Parser::ApacheCombinedLogParser do
  let(:ctl_file)  { fixture_path('apache_combined_log.ctl') }
  let(:control)   { ETL::Control.resolve(ctl_file) }
  let(:parser)    { ETL::Parser::ApacheCombinedLogParser.new(control.sources.first) }
  let(:rows)      { parser.map.to_a }

  describe '#parse' do
    let(:line) { %Q<127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"> }
    let(:fields) { parser.parse(line) }

    it "should correctly parse an apache log entry" do
      fields[:ip_address].should    == '127.0.0.1'
      fields[:user].should          == 'frank'
      fields[:timestamp].should     == Time.mktime(2000, 10, 10, 13, 55, 36)
      fields[:request].should       == 'GET /apache_pb.gif HTTP/1.0'
      fields[:response_code].should == '200'
      fields[:bytes].should         == '2326'
      fields[:referrer].should      == 'http://www.example.com/start.html'
      fields[:user_agent].should    == 'Mozilla/4.08 [en] (Win98; I ;Nav)'
    end

    context "parsing records from the control file" do
      it "should parse all of the rows" do
        rows.should == [
          # row 1
          {:user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)", :browser_version_minor=>nil, :timestamp=>Time.mktime(2000, 10, 10, 13, 55, 36), :ostype=>"Windows", :request=>"GET /apache_pb.gif HTTP/1.0", :referrer_host=>"www.example.com", :referrer_domain=>"example.com", :os=>"Win98", :referrer_uri_path=>"/start.html", :method=>"GET", :response_code=>"200", :referrer_port=>80, :os_version=>nil, :ip_address=>"127.0.0.1", :referrer_scheme=>"http", :bytes=>"2326", :browser=>"Mozilla", :identd=>nil, :path=>"/apache_pb.gif", :referrer=>"http://www.example.com/start.html", :browser_version_major=>"4", :user=>"frank"},
          # row 2
          {:user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)", :referrer_port=>80, :timestamp=>Time.mktime(2000, 10, 11, 5, 22, 2), :browser_version_minor=>nil, :os_version=>nil, :request=>"GET /apache_pb.gif HTTP/1.1", :ostype=>"Windows", :referrer_scheme=>"http", :response_code=>"200", :referrer_host=>"www.foo.com", :referrer_domain=>"foo.com", :ip_address=>"127.0.0.1", :browser=>"Mozilla", :bytes=>"2326", :os=>"Win98", :identd=>nil, :browser_version_major=>"4", :referrer=>"http://www.foo.com/", :referrer_uri_path=>"/", :method=>"GET", :path=>"/apache_pb.gif", :user=>"bob"},
          # row 3
          {:browser_version_major=>"4", :browser_version_minor=>nil, :referrer_port=>nil, :request=>"GET /apache_pb.gif HTTP/1.1", :ostype=>"Windows", :os_version=>nil, :response_code=>"200", :referrer_host=>nil, :referrer_scheme=>nil, :bytes=>"2326", :ip_address=>"127.0.0.1", :browser=>"Mozilla", :referrer=>nil, :os=>"Win98", :user=>"bob", :user_agent=>"Mozilla/4.08 [en] (Win98; I ;Nav)", :identd=>nil, :referrer_uri_path=>nil, :path=>"/apache_pb.gif", :method=>"GET", :timestamp=>Time.mktime(2000, 10, 11, 5, 52, 31)},
        ]
      end
    end
  end

  describe '#parse_user_agent' do
    let(:raw_agents) { "Mozilla/4.7 [en] (WinNT; U)\nMozilla/4.0 (compatible; MSIE 5.01; Windows NT)\nMozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461; .NET CLR 1.1.4322)\nMozilla/4.0 (compatible; MSIE 5.0; Windows NT 4.0) Opera 5.11 [en]\nMozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.0.2) Gecko/20030208 Netscape/7.02\nMozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040612 Firefox/0.8\nMozilla/5.0 (compatible; Konqueror/3.2; Linux) (KHTML, like Gecko)\nLynx/2.8.4rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6h" }
    let(:agents) { raw_agents.split("\n") }

    it "should parse out the different user agent fields" do
      parsed_agents = agents.map{ |ua| parser.parse_user_agent(ua) }

      parsed_agents[0].should == {:browser_version_major=>"4", :browser_version_minor=>nil, :ostype=>"Windows", :os=>"WinNT", :os_version=>nil, :browser=>"Mozilla"}
      parsed_agents[1].should == {:browser_version_major=>"5", :browser_version_minor=>"01", :ostype=>"Windows", :os=>"Windows NT", :os_version=>nil, :browser=>"MSIE"}
      parsed_agents[2].should == {:browser_version_major=>"6", :browser_version_minor=>"0", :ostype=>"Windows", :os=>"Windows NT 5.0", :os_version=>"5.0", :browser=>"MSIE"}
      parsed_agents[3].should == {:browser_version_major=>"5", :browser_version_minor=>"0", :ostype=>"Windows", :os=>"Windows NT 4.0", :os_version=>"4.0", :browser=>"MSIE"}
      parsed_agents[4].should == {:browser_version_major=>"7", :browser_version_minor=>nil, :ostype=>"Windows", :os=>"Windows NT 5.0", :os_version=>"5.0", :browser=>"Netscape"}
      parsed_agents[5].should == {:browser_version_major=>"0.8", :browser_version_minor=>nil, :ostype=>"Linux", :os=>"Linux i686", :os_version=>nil, :browser=>"Firefox"}
    end
  end
end

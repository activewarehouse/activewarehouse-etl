module ETL #:nodoc:
  module Parser #:nodoc:
    # Parser which can parser the Apache Combined Log Format as defined at
    # http://httpd.apache.org/docs/2.2/logs.html
    class ApacheCombinedLogParser < ETL::Parser::Parser
      include HttpTools
      def initialize(source, options={})
        super
      end

      def each
        Dir.glob(file).each do |file|
          File.open(file).each_line do |line|
            yield parse(line)
          end
        end
      end
      
      def parse(line)
        # example line:  127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
        line =~ /^(\S+)\s(\S+)\s(\S+)\s\[([^\]]*)\]\s"([^"]*)"\s(\d*)\s(\d*)\s"([^"]*)"\s"([^"]*)"$/
        fields = {
          :ip_address => $1,
          :identd => $2,
          :user => $3,
          :timestamp => $4,
          :request => $5,
          :response_code => $6,
          :bytes => $7,
          :referrer => $8,
          :user_agent => $9,
        }
        #fields[:timestamp] =~ r%{(\d\d)/(\w\w\w)/(\d\d\d\d):(\d\d):(\d\d):(\d\d) -(\d\d\d\d)}
        d = Date._strptime(fields[:timestamp], '%d/%b/%Y:%H:%M:%S') unless fields[:timestamp].nil?
        fields[:timestamp] = Time.mktime(d[:year], d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:sec_fraction]) unless d.nil?
        
        fields[:method], fields[:path] = fields[:request].split(/\s/)

        fields.merge!(parse_user_agent(fields[:user_agent])) unless fields[:user_agent].nil?
        fields.merge!(parse_uri(fields[:referrer], :prefix => 'referrer_'))
        
        fields.each do |key, value|
          fields[key] = nil if value == '-'
        end
      end
      
    end
  end
end
require 'uri'

# Module which has utility methods for HTTP.
module HttpTools
  # Parse the given user agent string
  #
  # Code taken from http://gemtacular.com/gems/ParseUserAgent
  def parse_user_agent(user_agent)
    if '-' == user_agent
      #raise 'Invalid User Agent'
      #puts 'Invalid User Agent'
    end
    
    browser, browser_version_major, browser_version_minor, ostype, os, os_version = nil

    # fix Opera
    #useragent =~ s/Opera (\d)/Opera\/$1/i;
    useragent = user_agent.gsub(/(Opera [\d])/,'Opera\1')

    # grab all Agent/version strings as 'agents'
    agents = Array.new
    user_agent.split(/\s+/).each {|string| 
      if string =~ /\//
        agents<< string
      end
    }

    # cycle through the agents to set browser and version (MSIE is set later)
    if agents && agents.length > 0
        agents.each {|agent|
          parts = agent.split('/')
          browser = parts[0]
          browser_version = parts[1]
          if browser == 'Firefox'
            browser_version_major = parts[1].slice(0,3)
            browser_version_minor = parts[1].sub(browser_version_major,'').sub('.','')
          elsif browser == 'Safari'
            if parts[1].slice(0,3).to_f < 400
              browser_version_major = '1'
            else
              browser_version_major = '2'
            end
          else
            browser_version_major = parts[1].slice(0,1)
          end
        }
    end

    # grab all of the properties (within parens)
    # should be in relation to the agent if possible  
    detail = user_agent
    user_agent.gsub(/\((.*)\)/,'').split(/\s/).each {|part| detail = detail.gsub(part,'')}
    detail = detail.gsub('(','').gsub(')','').lstrip
    properties = detail.split(/;\s+/)

    # cycle through the properties to set known quantities
    properties.each do |property| 
      if property =~ /^Win/
        ostype = 'Windows'
        os = property
        if parts = property.split(/ /,2)
          if parts[1] =~ /^NT/
            ostype = 'Windows'
            subparts = parts[1].split(/ /,2)
            if subparts[1] == '5'
              os_version = '2000'
            elsif subparts[1] == '5.1'
              os_version = 'XP'
            else
              os_version = subparts[1]
            end
          end
        end
      end
      if property == 'Macintosh'
        ostype = 'Macintosh'
        os = property
      end
      if property =~ /OS X/
        ostype = 'Macintosh'
        os_version = 'OS X'
        os = property
      end
      if property =~ /^Linux/
        ostype = 'Linux'
        os = property
      end
      if property =~ /^MSIE/
        browser = 'MSIE'
        browser_version = property.gsub('MSIE ','').lstrip
        browser_version_major,browser_version_minor = browser_version.split('.')
      end
    end
    
    result = {
      :browser => browser, 
      :browser_version_major => browser_version_major, 
      :browser_version_minor => browser_version_minor, 
      :ostype => ostype, 
      :os_version => os_version,
      :os => os,
    }
    result.each do |key, value|
      result[key] = value.blank? ? nil : value.strip
    end
    result
  end
  
  # Parse a URI. If options[:prefix] is set then prepend it to the keys for the hash that
  # is returned.
  def parse_uri(uri_string, options={})
    prefix = options[:prefix] ||= ''
    empty_hash = {
      "#{prefix}scheme".to_sym => nil, 
      "#{prefix}host".to_sym => nil, 
      "#{prefix}port".to_sym => nil, 
      "#{prefix}uri_path".to_sym => nil, 
      "#{prefix}domain".to_sym => nil
    }
    if uri_string
      #attempt to parse uri --if it's a uri then catch the problem and set everything to nil
      begin
        uri = URI.parse(uri_string)    
        results = {
          "#{prefix}scheme".to_sym => uri.scheme, 
          "#{prefix}host".to_sym => uri.host, 
          "#{prefix}port".to_sym => uri.port, 
          "#{prefix}uri_path".to_sym => uri.path
        }
        results["#{prefix}domain".to_sym] = $1 if uri.host =~ /\.?([^\.]+\.[^\.]+$)/
        results
      rescue
        empty_hash
      end
    else
      empty_hash
    end
  end
end
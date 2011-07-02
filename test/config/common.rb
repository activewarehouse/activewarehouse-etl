require 'rbconfig'

def common_gemfile(rails_version)
  source :rubygems

  # using explicit versions for the gems to avoid any weirdness later on
  gem "activesupport", rails_version
  gem "activerecord", rails_version

  gem "fastercsv", "1.5.4"
  gem "spreadsheet", "0.6.5.4"
  gem "tmail", "1.2.7.1"
  gem "net-sftp", "2.0.5"
  gem "zip", "2.0.2"

  gem "shoulda", "2.11.3"
  gem "flexmock", "0.9.0"

  gem "mysql", "2.8.1"
  gem "pg", "0.11.0"
  
  gem "nokogiri", "1.4.4"
  
  gem "rdoc"
  
  gem "adapter_extensions", :git => 'git@github.com:activewarehouse/adapter_extensions.git'
  
  gem "jruby-openssl" if RUBY_PLATFORM == "java"
end
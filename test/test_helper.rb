require 'rubygems'
require 'bundler/setup'

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

Dir[File.dirname(__FILE__) + "/vendor/**/lib"].each { |lib| $:.unshift(lib) }

require 'test/unit'
require 'pp'
require 'etl'
require 'shoulda'
require 'flexmock/test_unit'

ETL::Engine.init(:config => File.dirname(__FILE__) + '/config/database.yml')
ETL::Engine.logger = Logger.new(STDOUT)
# ETL::Engine.logger.level = Logger::DEBUG
ETL::Engine.logger.level = Logger::FATAL

db = ENV['DB'] ||= 'mysql'
require "connection/#{db}/connection"
ActiveRecord::Base.establish_connection :operational_database
ETL::Execution::Job.delete_all

require 'mocks/mock_source'
require 'mocks/mock_destination'

# shortcut to launch a ctl file
def process(file)
  Engine.process(File.join(File.dirname(__FILE__), file))
end

puts "ActiveRecord::VERSION = #{ActiveRecord::VERSION::STRING}"


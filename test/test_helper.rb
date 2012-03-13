$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'test/unit'
require 'pp'
require 'etl'
require 'shoulda'
require 'flexmock/test_unit'

raise "Missing required DB environment variable" unless ENV['DB']

database_yml = File.dirname(__FILE__) + '/config/database.yml'
ETL::Engine.init(:config => database_yml)
ETL::Engine.logger = Logger.new(STDOUT)
# ETL::Engine.logger.level = Logger::DEBUG
ETL::Engine.logger.level = Logger::FATAL

ActiveRecord::Base.establish_connection :operational_database
ETL::Execution::Job.delete_all

require 'mocks/mock_source'
require 'mocks/mock_destination'

# shortcut to launch a ctl file
def process(file)
  Engine.process(File.join(File.dirname(__FILE__), file))
end

puts "ActiveRecord::VERSION = #{ActiveRecord::VERSION::STRING}"

class Person < ActiveRecord::Base
end

def current_adapter
  ENV['DB']
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__))

require 'test/unit'
require 'pp'
require 'etl'
require 'shoulda'
require 'flexmock/test_unit'

ETL::Engine.init(:config => File.dirname(__FILE__) + '/database.yml')
ETL::Engine.logger = Logger.new(STDOUT)
# ETL::Engine.logger.level = Logger::DEBUG
ETL::Engine.logger.level = Logger::FATAL

db = ENV['DB'] ||= 'native_mysql'
require "connection/#{db}/connection"
ActiveRecord::Base.establish_connection :operational_database

if db == 'postgresql'
  # TODO: Is there a better way to avoid errors when this sequence
  # doesn't exist or isn't initialized?
  ActiveRecord::Base.connection.execute "SELECT nextval('people_id_seq')"
end

ETL::Execution::Job.delete_all

require 'mocks/mock_source'
require 'mocks/mock_destination'

# shortcut to launch a ctl file
def process(file)
  Engine.process(File.join(File.dirname(__FILE__), file))
end

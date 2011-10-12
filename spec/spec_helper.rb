require 'bundler/setup'
require 'fileutils'

Bundler.require :default, :development, :test

require 'etl'

spec_path = Bundler.root.join("spec")

# Pull in the support files
Dir[ spec_path.join("support/**/*.rb") ].each{|f| require f}

# Pull in the shared examples
Dir[ spec_path.join("shared_examples/**/*.rb") ].each{|f| require f}

RSpec.configure do |c|
  c.include CustomMatchers
  c.include CustomFixtures

  MockSource = ETL::Control::MockSource
  MockDestination = ETL::Control::MockDestination

  c.before(:all) do
    db_config = spec_path.join('db/database.sqlite3.yml')
    ETL::Engine.init({:config => db_config})

    ETL::Engine.logger = Logger.new(STDOUT)
    ETL::Engine.logger.level = Logger::FATAL
  end

  c.before(:each) do
    FileUtils.rm Dir[ fixture_root.join('output/*') ]
    MockSource.registry.clear
    MockDestination.registry.clear
  end

end

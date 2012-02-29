require 'bundler'
require 'rake'
require 'rake/testtask'

namespace :test do

  def run_tests(rvm, rails, database)
    database_yml = File.dirname(__FILE__) + "/test/config/database.#{database}.yml"
    FileUtils.cp(database_yml, 'test/config/database.yml')

    puts
    puts "============ Ruby #{rvm} - Rails #{rails} - Db #{database} ============="
    puts
    
    rvm_script = File.expand_path("~/.rvm/scripts/rvm")
    
    # a bit hackish - source rvm as described here
    # https://rvm.beginrescueend.com/workflow/scripting/
    sh <<-BASH
    source #{rvm_script}
    export BUNDLE_GEMFILE=test/config/Gemfile.rails-#{rails}
    rvm #{rvm}
    bundle install
    rake test
BASH
  end

  desc 'Run the tests in all combinations described in test-matrix.yml'
  task :matrix do
    # a la travis
    require 'yaml'
    data = YAML.load(IO.read(File.dirname(__FILE__) + '/test-matrix.yml'))
    data['rvm'].each do |rvm|
      data['rails'].each do |rails|
        data['database'].each do |database|
          run_tests(rvm, rails, database)
        end
      end
    end
  end
end

task :default => :test

desc 'Test the ETL application.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << '.'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  # TODO: reset the database
end

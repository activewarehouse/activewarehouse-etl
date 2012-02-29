require 'bundler'
require 'rake'
require 'rake/testtask'

def system!(cmd)
  puts cmd
  raise "Command failed!" unless system(cmd)
end

begin
  require 'tasks/standalone_migrations'
rescue LoadError => e
  puts "gem install standalone_migrations to get db:migrate:* tasks! (Error: #{e})"
end

# experimental tasks to reproduce the Travis behaviour locally
namespace :ci do

  desc "Create required databases for tests (db in [mysql, mysql2, postgresql])"
  task :create_db, :db do |t, args|
    db = args[:db] || ENV['DB']
    case db
      when /mysql/;
        # TODO - extract this info from database.yml
        system! "mysql -e 'create database activewarehouse_etl_test;'"
        system! "mysql activewarehouse_etl_test < test/config/databases/mysql_setup.sql"
      when /postgres/;
        system! "psql -c 'create database activewarehouse_etl_test;' -U postgres"
        system! "psql -d activewarehouse_etl_test -U postgres -f test/config/databases/postgresql_setup.sql"
      else abort("I don't know how to create the database for DB=#{db}!")
    end
  end

  desc "For current RVM, run the tests for one db and one gemfile"
  task :run_one, :db, :gemfile do |t, args|
    ENV['BUNDLE_GEMFILE'] = File.expand_path(args[:gemfile] || (File.dirname(__FILE__) + '/test/config/gemfiles/Gemfile.rails-3.2.x'))
    ENV['DB'] = args[:db] || 'mysql2'
    system! "bundle install"
    # trick: pass RAILS_ENV to force the db to be created by standalone migrations
    system! "bundle exec rake db:create"
    system! "bundle exec rake db:schema:load"
  end

  desc "For current RVM, run the tests for all the combination in travis configuration"
  task :run_matrix do
    require 'cartesian'
    config = YAML.load_file('.travis.yml')
    config['env'].cartesian(config['gemfile']).each do |*x|
      env, gemfile = *x.flatten
      db = env.gsub('DB=', '')
      print [db, gemfile].inspect.ljust(40) + ": "
      cmd = "rake \"ci:run_one[#{db},#{gemfile}]\""
      result = system "#{cmd} > /dev/null 2>&1"
      result = result ? "OK" : "FAILED! - re-run with: #{cmd}"
      puts result
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

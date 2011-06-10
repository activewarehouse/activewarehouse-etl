require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rake/contrib/rubyforgepublisher'

require File.join(File.dirname(__FILE__), 'lib/etl', 'version')

namespace :test do

  def run_tests(rvm, rails, database)
    database_yml = File.dirname(__FILE__) + "/test/config/database.#{database}.yml"
    FileUtils.cp(database_yml, 'test/database.yml')

    puts
    puts "============ Ruby #{rvm} - Rails #{rails} - Db #{database} ============="
    puts

    sh <<-BASH
    BUNDLE_GEMFILE=test/config/Gemfile.rails-#{rails} bundle install > null
    BUNDLE_GEMFILE=test/config/Gemfile.rails-#{rails} rvm #{rvm} rake test
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
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  # TODO: reset the database
end

desc 'Generate documentation for the ETL application.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActiveWarehouse ETL'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :rcov do
  desc 'Measures test coverage'
  task :test do
    rm_f 'coverage.data'
    mkdir 'coverage' unless File.exist?('coverage')
    rcov = "rcov --aggregate coverage.data --text-summary -Ilib"
    system("#{rcov} test/*_test.rb")
    # system("open coverage/index.html") if PLATFORM['darwin']
  end
end

desc "Generate code statistics"
task :lines do
  lines, codelines, total_lines, total_codelines = 0, 0, 0, 0

  for file_name in FileList["lib/**/*.rb"]
    next if file_name =~ /vendor/
    f = File.open(file_name)

    while line = f.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
    puts "L: #{sprintf("%4d", lines)}, LOC #{sprintf("%4d", codelines)} | #{file_name}"

    total_lines     += lines
    total_codelines += codelines

    lines, codelines = 0, 0
  end

  puts "Total: Lines #{total_lines}, LOC #{total_codelines}"
end

desc "Publish the release files to RubyForge."
task :release => [ :package ] do
  `rubyforge login`

  for ext in %w( gem tgz zip )
    release_command = "rubyforge add_release activewarehouse #{AWETL::PKG_NAME} 'REL #{AWETL::PKG_VERSION}' pkg/#{AWETL::PKG_NAME}-#{AWETL::PKG_VERSION}.#{ext}"
    puts release_command
    system(release_command)
  end
end

desc "Publish the API documentation"
task :pdoc => [:rdoc] do 
  Rake::SshDirPublisher.new("aeden@rubyforge.org", "/var/www/gforge-projects/activewarehouse/etl/rdoc", "rdoc").upload
end

desc "Reinstall the gem from a local package copy"
task :reinstall => [:package] do
  windows = RUBY_PLATFORM =~ /mswin/
  sudo = windows ? '' : 'sudo'
  gem = windows ? 'gem.bat' : 'gem'
  `#{sudo} #{gem} uninstall #{AWETL::PKG_NAME} -x`
  `#{sudo} #{gem} install pkg/#{AWETL::PKG_NAME}-#{AWETL::PKG_VERSION}`
end
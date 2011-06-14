require 'bundler'
require 'rake'
require 'rake/testtask'
require 'rdoc'
require 'rdoc/task'

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

desc "Publish the API documentation (UNTESTED CURRENTLY)"
task :pdoc => [:rdoc] do 
  Rake::SshDirPublisher.new("aeden@rubyforge.org", "/var/www/gforge-projects/activewarehouse/etl/rdoc", "rdoc").upload
end

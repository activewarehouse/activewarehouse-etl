require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'

require File.join(File.dirname(__FILE__), 'lib/etl', 'version')

module AWETL
  PKG_BUILD       = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
  PKG_NAME        = 'activewarehouse-etl'
  PKG_VERSION     = ETL::VERSION::STRING + PKG_BUILD
  PKG_FILE_NAME   = "#{PKG_NAME}-#{PKG_VERSION}"
  PKG_DESTINATION = ENV["PKG_DESTINATION"] || "../#{PKG_NAME}"
end

desc 'Default: run unit tests.'
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

# Gem Spec

module AWETL
  def self.package_files(package_prefix)
    FileList[
      "#{package_prefix}CHANGELOG",
      "#{package_prefix}LICENSE",
      "#{package_prefix}README",
      "#{package_prefix}TODO",
      "#{package_prefix}Rakefile",
      "#{package_prefix}bin/**/*",
      "#{package_prefix}doc/**/*",
      "#{package_prefix}lib/**/*",
      "#{package_prefix}examples/**/*",
    ] - [ "#{package_prefix}test" ]
  end

  def self.spec(package_prefix = '')
    Gem::Specification.new do |s|
      s.name = 'activewarehouse-etl'
      s.version = AWETL::PKG_VERSION
      s.summary = "Pure Ruby ETL package."
      s.description = <<-EOF
        ActiveWarehouse ETL is a pure Ruby Extract-Transform-Load application for loading data into a database.
      EOF

      s.add_dependency('rake',                '>= 0.7.1')
      s.add_dependency('activesupport',       '>= 1.3.1')
      s.add_dependency('activerecord',        '>= 1.14.4')
      s.add_dependency('fastercsv',           '>= 1.2.0')
      s.add_dependency('adapter_extensions',  '>= 0.1.0')

      s.rdoc_options << '--exclude' << '.'
      s.has_rdoc = false

      s.files = package_files(package_prefix).to_a.delete_if {|f| f.include?('.svn')}
      s.require_path = 'lib'

      s.bindir = "#{package_prefix}bin" # Use these for applications.
      s.executables = ['etl']
      s.default_executable = "etl"

      s.author = "Anthony Eden"
      s.email = "anthonyeden@gmail.com"
      s.homepage = "http://activewarehouse.rubyforge.org/etl"
      s.rubyforge_project = "activewarehouse"
    end
  end
end

Rake::GemPackageTask.new(AWETL.spec) do |pkg|
  pkg.gem_spec = AWETL.spec
  pkg.need_tar = true
  pkg.need_zip = true
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

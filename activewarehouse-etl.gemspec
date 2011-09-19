# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'etl/version'

Gem::Specification.new do |s|
  s.name = %q{activewarehouse-etl}
  s.version = ETL::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Anthony Eden", "Thibaut Barrère"]
  s.email = ["thibaut.barrere@gmail.com"]
  s.homepage = "https://github.com/activewarehouse/activewarehouse-etl"
  s.summary = %q{Pure Ruby ETL package.}
  s.description = %q{ActiveWarehouse ETL is a pure Ruby Extract-Transform-Load application for loading data into a database.}

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency('rake',                '>= 0.8.3')
  s.add_runtime_dependency('activesupport',       '>= 2.1.0')
  s.add_runtime_dependency('activerecord',        '>= 2.1.0')
  s.add_runtime_dependency('fastercsv',           '>= 1.2.0')
  s.add_runtime_dependency('adapter_extensions',  '>= 0.9.5.rc1')

  s.add_development_dependency('shoulda', '~>2.11.3')
  s.add_development_dependency('flexmock', '~>0.9.0')
  s.add_development_dependency('mysql', '~>2.8.1')
  s.add_development_dependency('mysql2', '~>0.3.7')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('spreadsheet', '~>0.6.5.4')

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test}/*`.split("\n")
  s.executables        = %w(etl)
  s.require_path       = "lib"
end

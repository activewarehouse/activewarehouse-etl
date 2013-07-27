def declare_gems(activerecord_version)
  source "https://rubygems.org"

  gem 'activerecord', activerecord_version
  gem 'adapter_extensions', :git => 'https://github.com/activewarehouse/adapter_extensions.git'

  if activerecord_version < '3.1'
    gem 'mysql2', '< 0.3'
  else
    # use our own fork for bulk load support until issue fixed:
    # https://github.com/brianmario/mysql2/pull/242
    gem 'mysql2', :git => 'https://github.com/activewarehouse/mysql2.git'
  end

  gem 'pg'
  gem 'activerecord-sqlserver-adapter'

  gem 'awesome_print'
  gem 'rake'
  gem 'flexmock'
  gem 'shoulda', '3.0.1'
  gem 'sqlite3'

  gem 'spreadsheet'
  gem 'nokogiri'
  gem 'fastercsv'

  gem 'roo'

  gem 'standalone_migrations', '1.0.5'
end
source "http://rubygems.org"

# Specify your gem's dependencies in ..gemspec
gemspec

group :development, :test do
  platforms :mri do
    gem 'mysql',    '~>2.8.1'
    gem 'mysql2',   '~>0.3.7'
    gem 'sqlite3',  '~>1.3.4'
  end

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter', '~>1.2.0'
  end
end

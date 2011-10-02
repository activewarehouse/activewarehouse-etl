require 'bundler/setup'

Bundler.require :default, :development, :test

Dir[ Bundler.root.join("spec/support/**/*.rb") ].each{|f| require f}

RSpec.configure do |c|
  c.include CustomMatchers
  c.include CustomFixtures
end

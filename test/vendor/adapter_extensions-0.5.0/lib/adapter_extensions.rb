# Extensions to the Rails ActiveRecord adapters.
#
# Requiring this file will require all of the necessary files to function.

puts "Using AdapterExtensions"

require 'rubygems'
require 'active_support'
require 'active_record'

$:.unshift(File.dirname(__FILE__))
Dir[File.dirname(__FILE__) + "/adapter_extensions/**/*.rb"].each { |file| require(file) }
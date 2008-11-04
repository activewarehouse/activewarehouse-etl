require 'etl/generator/generator'
Dir[File.dirname(__FILE__) + "/generator/*.rb"].each { |file| require(file) }
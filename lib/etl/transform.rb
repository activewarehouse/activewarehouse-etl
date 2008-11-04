require 'etl/transform/transform'
Dir[File.dirname(__FILE__) + "/transform/*.rb"].each { |file| require(file) }
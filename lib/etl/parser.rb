# This source file contains the ETL::Parser module and requires all of the files
# in the parser directory ending with .rb

module ETL #:nodoc:
  # The ETL::Parser module provides various text parsers.
  module Parser
  end
end

require 'etl/parser/parser'
Dir[File.dirname(__FILE__) + "/parser/*.rb"].each { |file| require(file) }
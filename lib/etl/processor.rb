# This source file contains the ETL::Processor module and requires all of the processors

module ETL #:nodoc:
  # The ETL::Processor module contains row-level and bulk processors
  module Processor
  end
end

require 'etl/processor/processor'
require 'etl/processor/row_processor'
Dir[File.dirname(__FILE__) + "/processor/*.rb"].each { |file| require(file) }
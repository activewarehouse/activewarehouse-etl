# This source file contains the ETL::Screen module and requires all of the 
# screens

module ETL #:nodoc:
  # The ETL::Screen module contains pre-built screens useful for checking the 
  # ETL state during execution. Screens may be fatal, which will result in 
  # termination of the ETL process, errors, which will result in the
  # termination of just the current ETL control file, or warnings, which will
  # result in a warning message.
  module Screen
  end
end

Dir[File.dirname(__FILE__) + "/screen/*.rb"].each { |file| require(file) }
require 'etl/screen/row_count_screen.rb'

module ETL #:nodoc:
  # The ETL::Screen module contains pre-built screens useful for checking the 
  # ETL state during execution. Screens may be fatal, which will result in 
  # termination of the ETL process, errors, which will result in the
  # termination of just the current ETL control file, or warnings, which will
  # result in a warning message.
  module Screen; end
end

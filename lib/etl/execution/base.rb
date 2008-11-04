module ETL #:nodoc:
  module Execution #:nodoc:
    # Base class for ETL execution information
    class Base < ActiveRecord::Base
      self.abstract_class = true
      establish_connection :etl_execution
    end
  end
end
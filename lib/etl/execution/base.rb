module ETL #:nodoc:
  module Execution #:nodoc:
    # Base class for ETL execution information
    class Base < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
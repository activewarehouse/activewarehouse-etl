module ETL #:nodoc:
  class Execution #:nodoc:
    # Base class for ETL execution information
    class Base < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end

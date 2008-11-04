module ETL #:nodoc:
  module Execution #:nodoc:
    # Persistent class representing an ETL batch
    class Batch < Base
      has_many :jobs
    end
  end
end
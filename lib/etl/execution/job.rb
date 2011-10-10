module ETL #:nodoc:
  class Execution #:nodoc:
    # Persistent class representing an ETL job
    class Job < Base
      belongs_to :batch
    end
  end
end

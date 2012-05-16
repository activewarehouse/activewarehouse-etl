module ETL #:nodoc:
  module Execution #:nodoc:
    # Persistent class representing an ETL job
    class Job < Base
      belongs_to :batch
      attr_accessible :control_file, :status, :batch_id
    end
  end
end

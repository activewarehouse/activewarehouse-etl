module ETL #:nodoc:
  module Execution #:nodoc:
    # Persistent class representing an ETL batch
    class Batch < Base
      belongs_to :batch
      has_many :batches
      has_many :jobs
      attr_accessible :batch_file, :status, :completed_at
    end
  end
end

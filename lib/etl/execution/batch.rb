module ETL #:nodoc:
  module Execution #:nodoc:
    # Persistent class representing an ETL batch
    class Batch < Base
      belongs_to :batch
      has_many :batches
      has_many :jobs
    end
  end
end

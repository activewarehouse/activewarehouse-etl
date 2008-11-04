module ETL #:nodoc:
  module Execution #:nodoc:
    # Represents a single record
    class Record < ETL::Execution::Base
      belongs_to :table
      class << self
        attr_accessor :time_spent
        def time_spent
          @time_spent ||= 0
        end
        def average_time_spent
          return 0 if time_spent == 0
          ETL::Engine.rows_read / time_spent
        end
      end
    end
  end
end
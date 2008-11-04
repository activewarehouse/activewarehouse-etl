module ETL #:nodoc
  # Classes which store information about ETL execution
  module Execution
    # Execution management
    class Execution
      class << self
        # Migrate the data store
        def migrate
          ETL::Execution::Migration.migrate
        end
      end
    end
  end
end

require 'etl/execution/base'
require 'etl/execution/batch'
require 'etl/execution/job'
require 'etl/execution/record'
require 'etl/execution/migration'
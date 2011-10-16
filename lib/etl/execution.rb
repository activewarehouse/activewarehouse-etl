module ETL #:nodoc
  # Classes which store information about ETL execution
  # Execution management
  class Execution
    autoload :Base,       'etl/execution/base'
    autoload :Batch,      'etl/execution/batch'
    autoload :Job,        'etl/execution/job'
    autoload :Migration,  'etl/execution/migration'

    # Migrate the data store
    def self.migrate
      ETL::Execution::Migration.migrate
    end
  end
end

# @todo: Autoload this and spit out a deprecation warning.
ETL::Execution::Execution = ETL::Execution

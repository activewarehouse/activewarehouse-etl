if RUBY_VERSION < '1.9'
  require 'faster_csv'
  ETL::CSV = FasterCSV
else
  require 'csv'
  ETL::CSV = ::CSV
end

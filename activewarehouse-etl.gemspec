Gem::Specification.new do |s|
  s.name = %q{activewarehouse-etl}
  s.version = "0.9.1.2"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anthony Eden"]
  s.bindir = %q{bin}
  s.date = %q{2008-08-14}
  s.default_executable = %q{etl}
  s.description = %q{ActiveWarehouse ETL is a pure Ruby Extract-Transform-Load application for loading data into a database.}
  s.email = %q{anthonyeden@gmail.com}
  s.executables = ["etl"]
  s.files = ["CHANGELOG", "LICENSE", "README", "TODO", "Rakefile", "bin/etl", "bin/etl.cmd", "lib/etl", "lib/etl.rb", "lib/etl/batch", "lib/etl/batch.rb", "lib/etl/builder", "lib/etl/builder.rb", "lib/etl/commands", "lib/etl/control", "lib/etl/control.rb", "lib/etl/core_ext", "lib/etl/core_ext.rb", "lib/etl/engine.rb", "lib/etl/execution", "lib/etl/execution.rb", "lib/etl/generator", "lib/etl/generator.rb", "lib/etl/http_tools.rb", "lib/etl/parser", "lib/etl/parser.rb", "lib/etl/processor", "lib/etl/processor.rb", "lib/etl/row.rb", "lib/etl/screen", "lib/etl/screen.rb", "lib/etl/transform", "lib/etl/transform.rb", "lib/etl/util.rb", "lib/etl/version.rb", "lib/etl/batch/batch.rb", "lib/etl/batch/directives.rb", "lib/etl/builder/date_dimension_builder.rb", "lib/etl/builder/time_dimension_builder.rb", "lib/etl/commands/etl.rb", "lib/etl/control/control.rb", "lib/etl/control/destination", "lib/etl/control/destination.rb", "lib/etl/control/source", "lib/etl/control/source.rb", "lib/etl/control/destination/database_destination.rb", "lib/etl/control/destination/file_destination.rb", "lib/etl/control/source/database_source.rb", "lib/etl/control/source/enumerable_source.rb", "lib/etl/control/source/file_source.rb", "lib/etl/control/source/model_source.rb", "lib/etl/core_ext/time", "lib/etl/core_ext/time.rb", "lib/etl/core_ext/time/calculations.rb", "lib/etl/execution/base.rb", "lib/etl/execution/batch.rb", "lib/etl/execution/job.rb", "lib/etl/execution/migration.rb", "lib/etl/generator/generator.rb", "lib/etl/generator/surrogate_key_generator.rb", "lib/etl/parser/apache_combined_log_parser.rb", "lib/etl/parser/delimited_parser.rb", "lib/etl/parser/excel_parser.rb", "lib/etl/parser/fixed_width_parser.rb", "lib/etl/parser/parser.rb", "lib/etl/parser/sax_parser.rb", "lib/etl/parser/xml_parser.rb", "lib/etl/processor/block_processor.rb", "lib/etl/processor/bulk_import_processor.rb", "lib/etl/processor/check_exist_processor.rb", "lib/etl/processor/check_unique_processor.rb", "lib/etl/processor/copy_field_processor.rb", "lib/etl/processor/encode_processor.rb", "lib/etl/processor/hierarchy_exploder_processor.rb", "lib/etl/processor/print_row_processor.rb", "lib/etl/processor/processor.rb", "lib/etl/processor/rename_processor.rb", "lib/etl/processor/require_non_blank_processor.rb", "lib/etl/processor/row_processor.rb", "lib/etl/processor/sequence_processor.rb", "lib/etl/processor/surrogate_key_processor.rb", "lib/etl/processor/truncate_processor.rb", "lib/etl/screen/row_count_screen.rb", "lib/etl/transform/block_transform.rb", "lib/etl/transform/date_to_string_transform.rb", "lib/etl/transform/decode_transform.rb", "lib/etl/transform/default_transform.rb", "lib/etl/transform/foreign_key_lookup_transform.rb", "lib/etl/transform/hierarchy_lookup_transform.rb", "lib/etl/transform/ordinalize_transform.rb", "lib/etl/transform/sha1_transform.rb", "lib/etl/transform/string_to_date_transform.rb", "lib/etl/transform/string_to_datetime_transform.rb", "lib/etl/transform/string_to_time_transform.rb", "lib/etl/transform/transform.rb", "lib/etl/transform/trim_transform.rb", "lib/etl/transform/type_transform.rb", "examples/database.example.yml"]
  s.homepage = %q{http://activewarehouse.rubyforge.org/etl}
  s.rdoc_options = ["--exclude", "."]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{activewarehouse}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Pure Ruby ETL package.}

  s.add_dependency(%q<rake>, [">= 0.7.1"])
  s.add_dependency(%q<activesupport>, [">= 1.3.1"])
  s.add_dependency(%q<activerecord>, [">= 1.14.4"])
  s.add_dependency(%q<fastercsv>, [">= 1.2.0"])
  s.add_dependency(%q<adapter_extensions>, [">= 0.1.0"])
end

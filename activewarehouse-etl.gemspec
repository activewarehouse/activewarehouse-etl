Gem::Specification.new do |s|
  s.name = %q{activewarehouse-etl}
  s.version = "0.9.1"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anthony Eden"]
  s.bindir = %q{etl/bin}
  s.date = %q{2008-08-14}
  s.default_executable = %q{etl}
  s.description = %q{ActiveWarehouse ETL is a pure Ruby Extract-Transform-Load application for loading data into a database.}
  s.email = %q{anthonyeden@gmail.com}
  s.executables = ["etl"]
  s.files = ["etl/CHANGELOG", "etl/LICENSE", "etl/README", "etl/TODO", "etl/Rakefile", "etl/bin/etl", "etl/bin/etl.cmd", "etl/lib/etl", "etl/lib/etl.rb", "etl/lib/etl/batch", "etl/lib/etl/batch.rb", "etl/lib/etl/builder", "etl/lib/etl/builder.rb", "etl/lib/etl/commands", "etl/lib/etl/control", "etl/lib/etl/control.rb", "etl/lib/etl/core_ext", "etl/lib/etl/core_ext.rb", "etl/lib/etl/engine.rb", "etl/lib/etl/execution", "etl/lib/etl/execution.rb", "etl/lib/etl/generator", "etl/lib/etl/generator.rb", "etl/lib/etl/http_tools.rb", "etl/lib/etl/parser", "etl/lib/etl/parser.rb", "etl/lib/etl/processor", "etl/lib/etl/processor.rb", "etl/lib/etl/row.rb", "etl/lib/etl/screen", "etl/lib/etl/screen.rb", "etl/lib/etl/transform", "etl/lib/etl/transform.rb", "etl/lib/etl/util.rb", "etl/lib/etl/version.rb", "etl/lib/etl/batch/batch.rb", "etl/lib/etl/batch/directives.rb", "etl/lib/etl/builder/date_dimension_builder.rb", "etl/lib/etl/commands/etl.rb", "etl/lib/etl/control/control.rb", "etl/lib/etl/control/destination", "etl/lib/etl/control/destination.rb", "etl/lib/etl/control/source", "etl/lib/etl/control/source.rb", "etl/lib/etl/control/destination/database_destination.rb", "etl/lib/etl/control/destination/file_destination.rb", "etl/lib/etl/control/source/database_source.rb", "etl/lib/etl/control/source/enumerable_source.rb", "etl/lib/etl/control/source/file_source.rb", "etl/lib/etl/control/source/model_source.rb", "etl/lib/etl/core_ext/time", "etl/lib/etl/core_ext/time.rb", "etl/lib/etl/core_ext/time/calculations.rb", "etl/lib/etl/execution/base.rb", "etl/lib/etl/execution/batch.rb", "etl/lib/etl/execution/job.rb", "etl/lib/etl/execution/migration.rb", "etl/lib/etl/generator/generator.rb", "etl/lib/etl/generator/surrogate_key_generator.rb", "etl/lib/etl/parser/apache_combined_log_parser.rb", "etl/lib/etl/parser/delimited_parser.rb", "etl/lib/etl/parser/fixed_width_parser.rb", "etl/lib/etl/parser/parser.rb", "etl/lib/etl/parser/sax_parser.rb", "etl/lib/etl/parser/xml_parser.rb", "etl/lib/etl/processor/block_processor.rb", "etl/lib/etl/processor/bulk_import_processor.rb", "etl/lib/etl/processor/check_exist_processor.rb", "etl/lib/etl/processor/check_unique_processor.rb", "etl/lib/etl/processor/copy_field_processor.rb", "etl/lib/etl/processor/encode_processor.rb", "etl/lib/etl/processor/hierarchy_exploder_processor.rb", "etl/lib/etl/processor/print_row_processor.rb", "etl/lib/etl/processor/processor.rb", "etl/lib/etl/processor/rename_processor.rb", "etl/lib/etl/processor/require_non_blank_processor.rb", "etl/lib/etl/processor/row_processor.rb", "etl/lib/etl/processor/sequence_processor.rb", "etl/lib/etl/processor/surrogate_key_processor.rb", "etl/lib/etl/processor/truncate_processor.rb", "etl/lib/etl/screen/row_count_screen.rb", "etl/lib/etl/transform/block_transform.rb", "etl/lib/etl/transform/date_to_string_transform.rb", "etl/lib/etl/transform/decode_transform.rb", "etl/lib/etl/transform/default_transform.rb", "etl/lib/etl/transform/foreign_key_lookup_transform.rb", "etl/lib/etl/transform/hierarchy_lookup_transform.rb", "etl/lib/etl/transform/ordinalize_transform.rb", "etl/lib/etl/transform/sha1_transform.rb", "etl/lib/etl/transform/string_to_date_transform.rb", "etl/lib/etl/transform/string_to_datetime_transform.rb", "etl/lib/etl/transform/string_to_time_transform.rb", "etl/lib/etl/transform/transform.rb", "etl/lib/etl/transform/trim_transform.rb", "etl/lib/etl/transform/type_transform.rb", "etl/examples/database.example.yml"]
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

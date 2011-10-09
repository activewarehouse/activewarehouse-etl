require 'spec_helper'

describe ETL::Parser::ApacheCombinedLogParser do
  let(:ctl_file)  { fixture_path('apache_combined_log.ctl') }
  let(:control)   { ETL::Control.resolve(ctl_file) }
  let(:parser)    { ETL::Parser::ApacheCombinedLogParser.new(control.sources.first) }
  let(:rows)      { parser.collect { |row| row } }

  # @todo: Do.
end

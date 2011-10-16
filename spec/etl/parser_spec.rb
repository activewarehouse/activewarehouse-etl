require 'spec_helper'

describe ETL::Parser do
  describe 'Inline Parsing' do
    let(:ctl_file) { fixture_path('inline_parser.ctl') }
    let(:outfile) { fixture_root('output/inline_parser.txt') }
    let(:output) { File.readlines(outfile) }

    # @todo: Crappy test?
    it "should correctly output the records" do
      ETL::Engine.process(ctl_file)
      output.should have(3).items
    end
  end
end

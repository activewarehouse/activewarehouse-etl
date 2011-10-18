require "spec_helper"

IGNORE = /\.(gitmodules|txt$|png$|tar$|gz$|rbc$|gem$|pdf$)/

describe "The application itself" do
  xit "has no malformed whitespace" do
    files = `git ls-files`.split("\n").select {|fn| fn !~ IGNORE}

    files.should be_well_formed
  end
end

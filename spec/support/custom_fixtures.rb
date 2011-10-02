require 'bundler'

module CustomFixtures
  attr_reader :fixtures

  # @param [#to_sym]
  # @return [String]
  def fixture_for(name)
    fixtures[name.to_sym][:fixture]
  end
  alias :fixture :fixture_for

  # @param [#to_sym]
  # @return [String]
  def path_for(name)
    fixtures[name.to_sym][:path]
  end

  # @see ConfigFixtures#create_fixture_hash
  def fixtures
    @fixtures ||= begin
      hash = Hash.new {|k,v| k[v] = {}}
      hash.merge!(create_fixture_hash)
    end
  end

  # @return [Hash{Symbol => String}]
  def create_fixture_hash
    Hash[ find_fixtures.map{|fpath| map_fixture(fpath) } ]
  end

  # @param [String]
  # @return [Array<Symbol, String>]
  def map_fixture(fpath)
    [symbolize_filename(fpath), {:path => fpath, :fixture => read_file(fpath)}]
  end

  # @return [Array<String>]
  def find_fixtures
    Dir.glob Bundler.root.join('spec/fixtures/**/*')
  end

  # @param [String]
  # @return [Symbol]
  def symbolize_filename(fpath)
    fname = File.basename(fpath)
    fname.split(/\W/).shift.to_sym
  end

  # @param [String]
  # @return [String]
  def read_file(fpath)
    File.read(fpath)
  end
end

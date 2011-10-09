require 'bundler'

module CustomFixtures
  attr_reader :fixtures

  # @param [#to_sym]
  # @return [String]
  def fixture_for(name)
    file_fixtures[name][:fixture]
  end
  alias :fixture :fixture_for

  # @param [#to_sym]
  # @return [String]
  def path_for(name)
    file_fixtures[name][:path]
  end
  alias :path         :path_for
  alias :fixture_path :path_for

  # @see ConfigFixtures#create_fixture_hash
  def file_fixtures
    @file_fixtures ||= begin
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
    [relative_path(fpath), {:path => fpath, :fixture => read_file(fpath)}]
  end

  # @return [Array<String>]
  def find_fixtures
    @find_fixtures ||= begin
      files = Dir[ fixture_root.join('**/*') ]
      files.reject! { |fi| File.directory?(fi) }
      files
    end
  end

  def fixture_root
    @project_root ||= Bundler.root.join('spec/fixtures/')
  end

  def relative_path(from_path)
    from_path.gsub(fixture_root.to_s, '')
  end

  # @param [String]
  # @return [String]
  def read_file(fpath)
    File.read(fpath)
  end
end

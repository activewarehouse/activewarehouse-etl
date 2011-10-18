require 'bundler'

module CustomFixtures
  attr_reader :fixtures

  Hash_of_Hashes = Hash.new { |k,v| k[v] = {} }

  # @param [#to_sym]
  # @return [String]
  def fixture_for(name)
    read_file path_for(name)
  end
  alias :fixture :fixture_for

  # @param [#to_sym]
  # @return [String]
  def path_for(name)
    file_fixtures[name][:path] || file_fixtures![name][:path]
  end
  alias :path         :path_for
  alias :fixture_path :path_for

  # @see ConfigFixtures#create_fixture_hash
  def file_fixtures
    @file_fixtures ||= file_fixtures!
  end

  def file_fixtures!
    @file_fixtures = Hash_of_Hashes.merge create_fixture_hash
  end

  # @return [Hash{Symbol => String}]
  def create_fixture_hash
    Hash[ find_fixtures.map{|fpath| map_fixture(fpath) } ]
  end

  # @param [String]
  # @return [Array<Symbol, String>]
  def map_fixture(fpath)
    [ relative_path(fpath), {:path => fpath} ]
  end

  # @return [Array<String>]
  def find_fixtures
    Dir[ fixture_root('**/*') ].tap do |files|
      files.reject! { |fi| File.directory?(fi) }
    end
  end

  def fixture_root(join_str=nil)
    return project_root.join(join_str) if join_str

    project_root
  end

  def project_root
    @project_root ||= Bundler.root.join('spec/fixtures/')
  end

  def relative_path(from_path)
    from_path.gsub(project_root.to_s, '')
  end

  # @param [String]
  # @return [String]
  def read_file(fpath)
    File.read(fpath)
  end
end

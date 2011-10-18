class MyParser < ETL::Parser::Parser
  def each
    [{:name => 'foo'},{:name => 'bar'},{:name => 'baz'}].each do |row|
      yield row
    end
  end
end

source :in, {
  :file => '',
  :parser => MyParser
}, 
[ 
  :name
]

destination :out, {:file => 'output/inline_parser.txt'},{:order => [:name]}
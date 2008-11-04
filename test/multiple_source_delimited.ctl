# puts "executing delimited.ctl"

source :source1, {
  :file => 'data/multiple_delimited_*.txt',
  :parser => :delimited
}, 
[ 
  :first_name,
  :last_name,
  :ssn,
  {
    :name => :age,
    :type => :integer
  }
]

source :source2, {
  :file => 'data/multiple_delimited_*.txt',
  :parser => :delimited
}, 
[ 
  :first_name,
  :last_name,
  :ssn,
  {
    :name => :age,
    :type => :integer
  }
]

transform :ssn, :sha1
transform(:ssn){ |v| v[0,24] }

destination :out, {
  :file => 'output/multiple_source_delimited.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}
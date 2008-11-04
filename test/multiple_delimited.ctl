# puts "executing delimited.ctl"

source :in, {
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

destination :out, {
  :file => 'output/multiple_delimited.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}

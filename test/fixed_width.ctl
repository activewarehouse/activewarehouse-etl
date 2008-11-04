# puts "executing fixed_width.ctl"

source :in, {
  :file => 'data/fixed_width.txt',
  :parser => :fixed_width
}, 
{
  :first_name => {
    :start => 1,
    :length => 9
  },
  :last_name => {
    :start => 10,
    :length => 12
  },
  :ssn => {
    :start => 22,
    :length => 9
  },
  :age => {
    :start => 31,
    :length => 2,
    :type => :integer
  }
}

transform :ssn, :sha1
transform(:ssn){ |n, v, r| v[0,24] }

destination :out, {
  :file => 'output/fixed_width.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}
# puts "executing delimited.ctl"

source :in, {
  :file => '/tmp/delimited_abs.txt',
  :parser => {
    :name => :delimited
  }
}, 
[ 
  :first_name,
  :last_name,
  :ssn,
  {
    :name => :age,
    :type => :integer
  },
  :sex
]

transform :ssn, :sha1
transform(:ssn){ |n, v, row| v[0,24] }
transform :sex, :decode, {:decode_table_path => 'data/decode.txt'}

destination :out, {
  :file => 'data/delimited_abs.txt'
},
{
  :order => [:first_name, :last_name, :ssn, :age, :sex, :test, :calc_test],
  :virtual => {
    :test => "test!",
    :calc_test => Time.now
  }
}
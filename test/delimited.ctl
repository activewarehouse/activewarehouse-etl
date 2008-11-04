source :in, {
  :file => 'data/delimited.txt',
  :parser => {
    :name => :delimited
  }
}, 
[ 
  :first_name,
  :last_name,
  :ssn,
  :age,
  :sex
]

#transform :age, :type, :type => :number
transform :ssn, :sha1
transform(:ssn){ |n, v, row| v[0,24] }
transform :sex, :decode, {:decode_table_path => 'data/decode.txt'}

destination :out, {
  :file => 'output/delimited.txt'
},
{
  :order => [:id, :first_name, :last_name, :ssn, :age, :sex, :test, :calc_test],
  :virtual => {
    :id => :surrogate_key,
    :test => "test!",
    :calc_test => Time.now
  },
}
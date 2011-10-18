source :in, {
  :file => 'data/delimited.txt',
  :parser => {
    :name => :csv
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
  :type => :update_database,
  :target => :data_warehouse,
  :database => 'etl_unittest',
  :table => 'people'
},
{
  :conditions => [{:field => "\#{conn.quote_column_name(:id)}", :value => "\#{conn.quote(row[:id])}", :comp => "="}],
  :order => [:id, :first_name, :last_name, :ssn, :age, :sex, :test, :calc_test],
  :virtual => {
    :id => :surrogate_key,
    :test => "test!",
    :calc_test => Time.now
  },
}

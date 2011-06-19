source :in, {
  :file => 'data/delimited.txt',
  :parser => :csv
}, 
[ 
  :id,
  :first_name,
  :last_name,
  :ssn
]

transform :ssn, :sha1
transform(:ssn){ |v| v[0,24] }

destination :out, {
  :type => :database,
  :target => :data_warehouse,
  :database => 'etl_unittest',
  :table => 'people',
},
{
  :order => [:id, :first_name, :last_name, :ssn]
}
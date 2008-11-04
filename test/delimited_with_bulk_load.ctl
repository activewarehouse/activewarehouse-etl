infile = 'data/people.txt'
outfile = 'output/people.txt'

source :in, {
  :file => infile,
  :parser => {
    :name => :delimited
  }
}, 
[ 
  :first_name,
  :last_name,
]

before_write :surrogate_key, :target => :data_warehouse, :table => 'person_dimension', :column => 'id'
before_write :check_exists, {
  :target => :data_warehouse, 
  :table => 'person_dimension', 
  :columns => [:first_name, :last_name]
}

destination :out, {
  :file => outfile
},
{
  :order => [:id, :first_name, :last_name]
}

post_process :bulk_import, {
  :file => outfile,
  :target => :data_warehouse,
  :table => 'person_dimension',
  :order => [:id, :first_name, :last_name]
}
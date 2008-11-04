source :in, {
  :type => :model
}, 
[ 
  :first_name,
  :last_name
]

destination :out, {
  :file => 'data/model_out.txt'
},
{
  :order => [:first_name, :last_name],
}
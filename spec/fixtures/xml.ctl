# puts "executing fixed_width.ctl"

source :in, {
  :file => 'data/xml.xml',
  :parser => :xml
}, 
{
  :collection => 'people/person',
  :fields => [
    :first_name,
    :last_name,
    {
      :name => :ssn,
      :xpath => 'social_security_number'
    },
    {
      :name => :age,
      :type => :integer
    }
  ]
}

destination :out, {
  :file => 'output/xml.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn]
}

transform :ssn, :sha1
transform(:ssn){ |v| v[0,24] }
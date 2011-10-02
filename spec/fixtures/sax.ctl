# puts "executing fixed_width.ctl"

source :in, {
  :file => 'data/sax.xml',
  :parser => :sax
}, 
{
  :write_trigger => 'people/person',
  :fields => {
    :first_name => 'people/person/first_name',
    :last_name => 'people/person/last_name',
    :ssn => 'people/person/social_security_number',
    :age => 'people/person[age]'
  }
}

transform :ssn, :sha1
transform(:ssn){ |v| v[0,24] }
transform :age, :type, {:type => :number}

destination :out, {
  :file => 'output/sax.out.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}
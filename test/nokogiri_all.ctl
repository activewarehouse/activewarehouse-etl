# puts "executing nokogiri_all.ctl"

source :in, {
  :file => 'data/nokogiri.xml',
  :parser => :nokogiri_xml
}, 
{
  :collection => 'people/person',
  :fields => [
    :first_name,
    :last_name,
    {
      :name => :ssn,
      :xpath => '@ssn'
    },
    {
      :name => :age,
      :type => :integer
    },
    {
      :name => :hair_colour,
      :xpath => 'colours/hair'
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

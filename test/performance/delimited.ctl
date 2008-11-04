# puts "executing delimited.ctl"

source :in, {
  :file => 'delimited.txt',
  :parser => :delimited
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
transform(:ssn){ |v| v[0,24] }
transform :sex, :decode, {:decode_table_path => 'delimited_decode.txt'}

destination :out, {
  :file => 'delimited.out.txt'
},
{
  :order => [:first_name, :last_name, :name, :ssn, :age, :sex],
  :virtual => {
    :name => Proc.new { |row| "#{row[:first_name]} #{row[:last_name]}" }
  }
}
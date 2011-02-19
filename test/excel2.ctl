source :in, {
  :file => 'data/excel2.xls',
  :parser => :excel
}, 
{
  :ignore_blank_line => true,
  :worksheets => [ 1 ],
  :fields => [ 
      :first_name,
      :last_name,
      :ssn,
      :age
  ]
}

transform :ssn, :sha1
transform(:ssn){ |n, v, r| v[0,24] }


destination :out, {
  :file => 'output/excel2.out.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}
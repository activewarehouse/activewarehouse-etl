source :in, {
  :file => 'data/excel2.xls',
  :parser => :excel
}, 
{
  :first_line_is_header => true,
  :worksheets => [ 1 ]
}

transform :ssn, :sha1
transform(:ssn){ |n, v, r| v[0,24] }


destination :out, {
  :file => 'output/excel2.out.txt'
}, 
{
  :order => [:first_name, :last_name, :ssn, :age]
}
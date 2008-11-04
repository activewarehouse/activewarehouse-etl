source :in, {
  :file => 'data/apache_combined_log.txt',
  :parser => :apache_combined_log
}

destination :out, {
  :file => 'output/apache_combined_log.txt'
}, 
{
  :order => []
}
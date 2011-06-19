source :in, {
  :file => "scd/#{ENV['run_number']}.txt",
  :parser => :csv
},
[
  :first_name,
  :last_name,
  :address,
  :city,
  :state,
  :zip_code
]

destination :out, {
  :type => :database,
  :target => :data_warehouse,
  :database => 'etl_unittest',
  :table => 'person_dimension',
  :natural_key => [:first_name, :last_name],
  :scd => {
    :type => 2,
    :dimension_target => :data_warehouse,
    :dimension_table => 'person_dimension'
  },
  :scd_fields => ENV['type_2_scd_fields'] ? Marshal.load(ENV['type_2_scd_fields']) : [:address, :city, :state, :zip_code]
}, 
{
  :order => [
    :id, :first_name, :last_name, :address, :city, :state, :zip_code, :effective_date, :end_date, :latest_version
  ],
  :virtual => {
    :id => ETL::Generator::SurrogateKeyGenerator.new(:target => :data_warehouse, :table => 'person_dimension')
  }
}

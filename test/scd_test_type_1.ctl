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

# NOTE: These are not usually required for a type 1 SCD dimension, but since
# we're sharing this table with the type 2 tests, they're necessary.
transform :effective_date, :default, :default_value => Time.now.to_s(:db)
transform :end_date, :default, :default_value => '9999-12-31 00:00:00'
transform :latest_version, :default, :default_value => true

destination :out, {
  :file => 'output/scd_test_type_1.txt',
  :natural_key => [:first_name, :last_name],
  :scd => {
    :type => 1,
    :dimension_target => :data_warehouse,
    :dimension_table => 'person_dimension'
  },
  :scd_fields => [:address, :city, :state, :zip_code]
}, 
{
  :order => [
    :id, :first_name, :last_name, :address, :city, :state, :zip_code, :effective_date, :end_date, :latest_version
  ],
  :virtual => {
    :id => ETL::Generator::SurrogateKeyGenerator.new(:target => :data_warehouse, :table => 'person_dimension')
  }
}

post_process :bulk_import, {
  :file => 'output/scd_test_type_1.txt',
  :target => :data_warehouse,
  :table => 'person_dimension'
}
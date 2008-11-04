class ErrorProcessor < ETL::Processor::RowProcessor
  def initialize(control, configuration)
    super
  end
  def process(row)
    raise RuntimeError, "Generated error"
  end
end

set_error_threshold 1

source :in, {
  :type => :enumerable,
  :enumerable => [
    {:first_name => 'Bob',:last_name => 'Smith'},
    {:first_name => 'Joe', :last_name => 'Thompson'}
  ]
},
[
  :first_name,
  :last_name
]

after_read ErrorProcessor
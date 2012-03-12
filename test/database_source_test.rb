require File.dirname(__FILE__) + '/test_helper'

class DatabaseSourceTest < Test::Unit::TestCase

  if current_adapter =~ /mysql/
    context 'with mysqlstream enabled' do
      setup do
        Person.delete_all
        Person.create!(:first_name => 'Bob', :last_name => 'Smith', :ssn => '123456789')
        Person.create!(:first_name => 'John', :last_name => 'Barry', :ssn => '123456790')
      end

      should 'support store_locally' do
        source = ETL::Control::DatabaseSource.new(nil, {
          :target => 'operational_database',
          :table => 'people',
          :mysqlstream => true,
          :store_locally => true
        }, nil)

        assert_equal 2, source.to_a.size
      end
    end
  end
end
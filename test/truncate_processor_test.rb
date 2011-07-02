require File.dirname(__FILE__) + '/test_helper'

include ETL::Processor

class TruncateTest < ActiveRecord::Base
  set_table_name 'truncate_test'
end

class TruncateProcessorTest < Test::Unit::TestCase

  def create_item!
    TruncateTest.create!(:x => 'ABC')
  end
  
  def truncate!(options=nil)
    TruncateProcessor.new(nil,
      :target => :data_warehouse,
      :table => TruncateTest.table_name,
      :options => options
      ).process
  end
  
  should 'reset ids by default' do
    create_item!
    truncate!
    assert_equal 1, create_item!.id
  end

  if ETL::Engine.connection(:data_warehouse).class.name =~ /postgres/i
    should 'allow disabling id reset for postgres' do
      truncate!
      create_item!
      truncate!('CONTINUE IDENTITY')
      assert_equal 2, create_item!.id
    end
  end
end
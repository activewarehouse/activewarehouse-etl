require File.dirname(__FILE__) + '/test_helper'

class ScdTest < Test::Unit::TestCase
  context "when working with a slowly changing dimension" do
    setup do
      @connection = ETL::Engine.connection(:data_warehouse)
      @connection.delete("DELETE FROM person_dimension")
      @end_of_time = DateTime.parse('9999-12-31 00:00:00')
    end
    context "of type 1" do
      context "on run 1" do
        setup do
          do_type_1_run(1)
        end
        should "insert record" do
          assert_equal 1, count_bobs
        end
        should "set the original address" do
          assert_boston_address(find_bobs.first)
        end
        should "set the original id" do
          assert_equal 1, find_bobs.first.id
        end
        should "skip the load if there is no change" do
          do_type_1_run(1)
          lines = lines_for('scd_test_type_1.txt')
          assert lines.empty?, "scheduled load expected to be empty, was #{lines.size} records"
        end
      end
      context "on run 2" do
        setup do
          do_type_1_run(1)
          do_type_1_run(2)
        end
        should "delete the old record" do
          assert_equal 1, count_bobs, "new record created, but old not deleted: #{find_bobs.inspect}"
        end
        should "update the address" do
          assert_los_angeles_address(find_bobs.last)
        end
        should "keep id" do
          assert_equal 1, find_bobs.first.id
        end
        should "only change once even if run again" do
          do_type_1_run(2)
          assert_equal 1, count_bobs
          lines = lines_for('scd_test_type_1.txt')
          assert lines.empty?, "scheduled load expected to be empty, was #{lines.size} records"
        end
        should "revert address on new record" do
          do_type_1_run(1)
          assert_boston_address(find_bobs.first)
        end
        should "keep record on revert" do
          do_type_1_run(1)
          assert_equal 1, count_bobs
        end
      end
    end
    context "of type 2" do
      context "on run 1" do
        setup do
          do_type_2_run(1)
        end
        should "insert record" do
          assert_equal 1, count_bobs
        end
        should "set the original record" do
          assert_boston_address(find_bobs.first)
        end
        should "set the original id" do
          assert_equal 1, find_bobs.first.id
        end
        should "set the effective date" do
          # doing comparison on strings, as comparison on objects
          # doesn't consider things equal for some yet to be understood
          # reason
          assert_equal current_datetime.to_s, find_bobs.first.effective_date.to_s
        end
        should "set the end date" do
          assert_equal @end_of_time, find_bobs.first.end_date
        end
        should "set the latest version flag" do
          assert find_bobs.first.latest_version?
        end
        should "skip the load if there is no change" do
          do_type_2_run(1)
          assert_equal 1, find_bobs.last.id, "scheduled load expected to be empty"
        end
        
      end
      context "on run 2" do
        setup do
          do_type_2_run(1)
          do_type_2_run(2)
        end
        should "insert new record" do
          assert_equal 2, count_bobs
        end
        should "keep the primary key of the original version" do
          assert_not_nil find_bobs.detect { |bob| 1 == bob.id }
        end
        should "increment the primary key for the new version" do
          assert_not_nil find_bobs.detect { |bob| 2 == bob.id }
        end
        should "expire the old record" do
          original_bob = find_bobs.detect { |bob| 1 == bob.id }
          new_bob = find_bobs.detect { |bob| 2 == bob.id }
          assert_equal new_bob.effective_date, original_bob.end_date
        end
        should "keep the address for the expired record" do
          assert_boston_address(find_bobs.detect { |bob| 1 == bob.id })
        end
        should "update the address on the new record" do
          assert_los_angeles_address(find_bobs.detect { |bob| 2 == bob.id })
        end
        should "activate the new record" do
          # doing comparison on strings, as comparison on objects
          # doesn't consider things equal for some yet to be understood
          # reason
          assert_equal current_datetime.to_s, find_bobs.detect { |bob| 2 == bob.id }.effective_date.to_s
        end
        should "set the end date for the new record" do
          assert_equal @end_of_time, find_bobs.detect { |bob| 2 == bob.id }.end_date
        end
        should "shift the latest version" do
          original_bob = find_bobs.detect { |bob| 1 == bob.id }
          new_bob = find_bobs.detect { |bob| 2 == bob.id }
          assert !original_bob.latest_version?
          assert new_bob.latest_version?
        end
        should "only execute a change once" do
          do_type_2_run(2)
          assert_equal 2, count_bobs, "scheduled load expected to be empty"
        end
        should "insert new records on revert" do
          do_type_2_run(1)
          assert_equal 3, count_bobs
        end
        should "update address on new record on revert" do
          do_type_2_run(1)
          assert_boston_address(find_bobs.detect { |bob| 3 == bob.id })
        end
        should "only delete one row on an scd change" do
          # Two records right now
          assert_equal 2, count_bobs
          do_type_2_run(1) # put third version in (same as first version, but that's irrelevant)
          # was failing because first and second versions were being deleted.
          assert_equal 3, count_bobs
        end
      end
      context "on non sdc fields that change" do
        setup do
          do_type_2_run_with_only_city_state_zip_scd(1)
          do_type_2_run_with_only_city_state_zip_scd(2)
        end
        should "not create an extra record" do
          do_type_2_run_with_only_city_state_zip_scd(3)
          assert_equal 2, count_bobs
        end
        should "keep id" do
          do_type_2_run_with_only_city_state_zip_scd(3)
          assert_not_nil find_bobs.detect { |bob| 2 == bob.id }
        end
        should "keep dates" do
          old_bob = find_bobs.detect { |bob| 2 == bob.id }
          do_type_2_run_with_only_city_state_zip_scd(3)
          new_bob = find_bobs.detect { |bob| 2 == bob.id }
          assert_equal old_bob.end_date, new_bob.end_date
          assert_equal old_bob.effective_date, new_bob.effective_date
        end
        should "keep the latest version flag" do
          do_type_2_run_with_only_city_state_zip_scd(3)
          assert find_bobs.detect { |bob| 2 == bob.id }.latest_version?
        end
        should "treat non scd fields like type 1 fields" do
          do_type_2_run_with_only_city_state_zip_scd(3)
          assert_los_angeles_address(find_bobs.detect { |bob| 2 == bob.id }, "280 Pine Street")
        end
        should "skip load when there is no change" do
          do_type_2_run_with_only_city_state_zip_scd(2)
          assert_equal 2, count_bobs, "scheduled load expected to be empty"
        end
      end
    end
  end
  
  def do_type_2_run(run_num)
    ENV['run_number'] = run_num.to_s
    assert_nothing_raised do
      run_ctl_file("scd_test_type_2.ctl")
    end
  end
  
  def do_type_2_run_with_only_city_state_zip_scd(run_num)
    ENV['type_2_scd_fields'] = Marshal.dump([:city, :state, :zip_code])
    do_type_2_run(run_num)
  end
  
  def do_type_1_run(run_num)
    ENV['run_number'] = run_num.to_s
    assert_nothing_raised do
      run_ctl_file("scd_test_type_1.ctl")
    end
  end
  
  def lines_for(file)
    File.readlines(File.dirname(__FILE__) + "/output/#{file}")
  end
  
  def run_ctl_file(file)
    ETL::Engine.process(File.dirname(__FILE__) + "/#{file}")
  end
  
  def count_bobs
    @connection.select_value(
      "SELECT count(*) FROM person_dimension WHERE first_name = 'Bob' and last_name = 'Smith'").to_i
  end
  
  def find_bobs
    bobs = @connection.select_all(
      "SELECT * FROM person_dimension WHERE first_name = 'Bob' and last_name = 'Smith'")
    bobs.each do |bob|
      def bob.id
        self["id"].to_i
      end
      def bob.effective_date
        DateTime.parse(self["effective_date"])
      end
      def bob.end_date
        DateTime.parse(self["end_date"])
      end
      def bob.latest_version?
        ActiveRecord::ConnectionAdapters::Column.value_to_boolean(self["latest_version"])
      end
    end
    bobs
  end
  
  def current_datetime
    DateTime.parse(Time.now.to_s(:db))
  end
  
  def assert_boston_address(bob, street = "200 South Drive")
    assert_equal street, bob['address'], bob.inspect
    assert_equal "Boston", bob['city'], bob.inspect
    assert_equal "MA", bob['state'], bob.inspect
    assert_equal "32123", bob['zip_code'], bob.inspect
  end
  
  def assert_los_angeles_address(bob, street = "1010 SW 23rd St")
    assert_equal street, bob['address'], bob.inspect
    assert_equal "Los Angeles", bob['city'], bob.inspect
    assert_equal "CA", bob['state'], bob.inspect
    assert_equal "90392", bob['zip_code'], bob.inspect
  end
end

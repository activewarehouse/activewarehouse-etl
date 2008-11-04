require File.dirname(__FILE__) + '/test_helper'

class DateDimensionBuilderTest < Test::Unit::TestCase
  
  context "the DateDimensionBuilder" do
    context "when initialized with defaults" do
      setup do
        @builder = ETL::Builder::DateDimensionBuilder.new
      end
      should "have a start date of 5 years ago" do
        assert_equal Time.now.years_ago(5).to_date, @builder.start_date.to_date
      end
      should "have an end date of now" do
        assert_equal Time.now.to_date, @builder.end_date.to_date
      end
      should "have an empty of array of holiday indicators" do
        assert_equal [], @builder.holiday_indicators
      end
    end
    context "when initialized with arguments" do
      setup do 
        @start_date = Time.now.years_ago(2)
        @end_date = Time.now.years_ago(1)
        @builder = ETL::Builder::DateDimensionBuilder.new(@start_date, @end_date)
      end
      should "respect a custom start date" do
        assert_equal @start_date.to_date, @builder.start_date.to_date
      end
      should "respect a custom end date" do
        assert_equal @end_date.to_date, @builder.end_date.to_date
      end
    end
    context "when building a date dimension using the default settings" do
      setup do
        # specific dates required when testing, because leap years affect
        # how many records are built
        @start_date = Date.parse('2002-05-19').to_time
        @end_date = Date.parse('2007-05-19').to_time
        @builder = ETL::Builder::DateDimensionBuilder.new(@start_date, @end_date)
        @records = @builder.build
      end
      should "build a dimension with the correct number of records" do
        assert_equal 1827, @records.length
      end
      should "have the correct first date" do
        assert_date_dimension_record_equal(@builder.start_date, @records.first)
      end
    end
    context "when building a date dimension with a fiscal year offset month" do
      should_eventually "respect the fiscal year offset month" do
        
      end
    end
  end
  
  def assert_date_dimension_record_equal(date, record)
    real_date = date
    date = date.to_time
    assert_equal date.strftime("%m/%d/%Y"), record[:date]
    assert_equal date.strftime("%B %d,%Y"), record[:full_date_description]
    assert_equal date.strftime("%A"), record[:day_of_week]
    assert_equal date.day, record[:day_number_in_calendar_month]
    assert_equal date.yday, record[:day_number_in_calendar_year]
    assert_equal date.day, record[:day_number_in_fiscal_month]
    assert_equal date.fiscal_year_yday, record[:day_number_in_fiscal_year]
    assert_equal "Week #{date.week}", record[:calendar_week]
    assert_equal date.week, record[:calendar_week_number_in_year]
    assert_equal date.strftime("%B"), record[:calendar_month_name]
    assert_equal date.month, record[:calendar_month_number_in_year]
    assert_equal date.strftime("%Y-%m"), record[:calendar_year_month]
    assert_equal "Q#{date.quarter}", record[:calendar_quarter]
    assert_equal date.quarter, record[:calendar_quarter_number_in_year]
    assert_equal "#{date.strftime('%Y')}-#{record[:calendar_quarter]}", record[:calendar_year_quarter]
    assert_equal "#{date.year}", record[:calendar_year]
    assert_equal "FY Week #{date.fiscal_year_week}", record[:fiscal_week]
    assert_equal date.fiscal_year_week, record[:fiscal_week_number_in_year]
    assert_equal date.fiscal_year_month, record[:fiscal_month]
    assert_equal date.fiscal_year_month, record[:fiscal_month_number_in_year]
    assert_equal "FY#{date.fiscal_year}-" + date.fiscal_year_month.to_s.rjust(2, '0'), record[:fiscal_year_month]
    assert_equal "FY Q#{date.fiscal_year_quarter}", record[:fiscal_quarter]
    assert_equal "FY#{date.fiscal_year}-Q#{date.fiscal_year_quarter}", record[:fiscal_year_quarter]
    assert_equal date.fiscal_year_quarter, record[:fiscal_year_quarter_number]
    assert_equal "FY#{date.fiscal_year}", record[:fiscal_year]
    assert_equal date.fiscal_year, record[:fiscal_year_number]
    assert_equal 'Nonholiday', record[:holiday_indicator]
    assert_equal weekday_indicators[date.wday], record[:weekday_indicator]
    assert_equal 'None', record[:selling_season]
    assert_equal 'None', record[:major_event]
    assert_equal record[:sql_date_stamp], real_date
  end
  
  private
  def weekday_indicators
    ['Weekend','Weekday','Weekday','Weekday','Weekday','Weekday','Weekend']
  end
end
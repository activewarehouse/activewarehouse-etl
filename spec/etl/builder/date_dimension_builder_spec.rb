require 'spec_helper'

describe ETL::Builder::DateDimensionBuilder do
  let(:builder) { ETL::Builder::DateDimensionBuilder.new }

  describe '#initialize' do
    context "when initialized with defaults" do
      # @todo: Why should it be 5 years ago?
      it "should have a start date of 5 years ago" do
        builder.start_date.to_date.should == Time.now.years_ago(5).to_date
      end

      it "should have an end date of now" do
        builder.end_date.to_date.should == Time.now.to_date
      end

      it "should have an empty of array of holiday indicators" do
        builder.holiday_indicators.should == []
      end
    end

    # @todo: Why is it called "date" when it appears to be storing Time? Bad.
    # @todo: Maybe use the "started_on" / "started_at" convention for date / time?
    context "when initialized with arguments" do
      let(:start_date) { Time.now.years_ago(2) }
      let(:end_date) { Time.now.years_ago(1) }
      let(:builder) { ETL::Builder::DateDimensionBuilder.new(start_date, end_date) }

      it "should respect a custom start date" do
        builder.start_date.to_date.should == start_date.to_date
      end

      it "should respect a custom end date" do
        builder.end_date.to_date.should == end_date.to_date
      end
    end

    context "when building a date dimension using the default settings" do
      # Comments from original test:
      #   specific dates required when testing, because leap years affect how many records are built
      let(:start_date) { Date.parse('2002-05-19').to_time }
      let(:end_date) { Date.parse('2007-05-19').to_time }
      let(:builder) { ETL::Builder::DateDimensionBuilder.new(start_date, end_date) }

      let(:records) { builder.build }

      it "should build a dimension with the correct number of records" do
        records.should have(1827).items
      end

      it "should have the correct first date" do
        records.first[:date].should == builder.start_date.strftime("%m/%d/%Y")
      end
    end

    context "when building a date dimension with a fiscal year offset month" do
      pending "respect the fiscal year offset month"
    end
  end

  # @todo: Test this turkey the correct way.
  #
  # def assert_date_dimension_record_equal(date, record)
  #   real_date = date
  #   date = date.to_time
  #   assert_equal date.strftime("%m/%d/%Y"), record[:date]
  #   assert_equal date.strftime("%B %d,%Y"), record[:full_date_description]
  #   assert_equal date.strftime("%A"), record[:day_of_week]
  #   assert_equal date.day, record[:day_number_in_calendar_month]
  #   assert_equal date.yday, record[:day_number_in_calendar_year]
  #   assert_equal date.day, record[:day_number_in_fiscal_month]
  #   assert_equal date.fiscal_year_yday, record[:day_number_in_fiscal_year]
  #   assert_equal "Week #{date.week}", record[:calendar_week]
  #   assert_equal date.week, record[:calendar_week_number_in_year]
  #   assert_equal date.strftime("%B"), record[:calendar_month_name]
  #   assert_equal date.month, record[:calendar_month_number_in_year]
  #   assert_equal date.strftime("%Y-%m"), record[:calendar_year_month]
  #   assert_equal "Q#{date.quarter}", record[:calendar_quarter]
  #   assert_equal date.quarter, record[:calendar_quarter_number_in_year]
  #   assert_equal "#{date.strftime('%Y')}-#{record[:calendar_quarter]}", record[:calendar_year_quarter]
  #   assert_equal "#{date.year}", record[:calendar_year]
  #   assert_equal "FY Week #{date.fiscal_year_week}", record[:fiscal_week]
  #   assert_equal date.fiscal_year_week, record[:fiscal_week_number_in_year]
  #   assert_equal date.fiscal_year_month, record[:fiscal_month]
  #   assert_equal date.fiscal_year_month, record[:fiscal_month_number_in_year]
  #   assert_equal "FY#{date.fiscal_year}-" + date.fiscal_year_month.to_s.rjust(2, '0'), record[:fiscal_year_month]
  #   assert_equal "FY Q#{date.fiscal_year_quarter}", record[:fiscal_quarter]
  #   assert_equal "FY#{date.fiscal_year}-Q#{date.fiscal_year_quarter}", record[:fiscal_year_quarter]
  #   assert_equal date.fiscal_year_quarter, record[:fiscal_year_quarter_number]
  #   assert_equal "FY#{date.fiscal_year}", record[:fiscal_year]
  #   assert_equal date.fiscal_year, record[:fiscal_year_number]
  #   assert_equal 'Nonholiday', record[:holiday_indicator]
  #   assert_equal weekday_indicators[date.wday], record[:weekday_indicator]
  #   assert_equal 'None', record[:selling_season]
  #   assert_equal 'None', record[:major_event]
  #   assert_equal record[:sql_date_stamp], real_date
  # end
  # 
  # private
  # def weekday_indicators
  #   ['Weekend','Weekday','Weekday','Weekday','Weekday','Weekday','Weekend']
  # end
end

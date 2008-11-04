module ETL #:nodoc:
  module Builder #:nodoc:
    # A builder which will build a data structure which can be used to populate a date dimension using 
    # commonly used date dimension columns.
    class DateDimensionBuilder
      # Specify the start date for the first record
      attr_accessor :start_date
      
      # Specify the end date for the last record
      attr_accessor :end_date
      
      # Define any holiday indicators
      attr_accessor :holiday_indicators

      # Add offset month for fiscal year
      attr_accessor :fiscal_year_offset_month
      
      # Define the weekday indicators. The default array begins on Sunday and goes to Saturday.
      cattr_accessor :weekday_indicators
      @@weekday_indicators = ['Weekend','Weekday','Weekday','Weekday','Weekday','Weekday','Weekend']
      
      # Initialize the builder.
      # 
      # * <tt>start_date</tt>: The start date. Defaults to 5 years ago from today.
      # * <tt>end_date</tt>: The end date. Defaults to now.
      def initialize(start_date=Time.now.years_ago(5), end_date=Time.now, fiscal_year_offset_month=10)
        @start_date = start_date.to_date
        @end_date = end_date.to_date
        @fiscal_year_offset_month = fiscal_year_offset_month.to_i
        @holiday_indicators = []
      end
      
      # Returns an array of hashes representing records in the dimension.
      def build(options={})
        (start_date..end_date).map { |date| record_from_date(date) }
      end

      private

      # Returns a hash representing a record in the dimension. The values for each record are 
      # accessed by name.
      def record_from_date(date)
        time = date.to_time # need methods only available in Time
        record = {}
        record[:date] = time.strftime("%m/%d/%Y")
        record[:full_date_description] = time.strftime("%B %d,%Y")
        record[:day_of_week] = time.strftime("%A")
        record[:day_in_week] = record[:day_of_week] # alias
        #record[:day_number_in_epoch] = time.to_i / 24
        #record[:week_number_in_epoch] = time.to_i / (24 * 7)
        #record[:month_number_in_epoch] = time.to_i / (24 * 7 * 30)
        record[:day_number_in_calendar_month] = time.day
        record[:day_number_in_calendar_year] = time.yday
        record[:day_number_in_fiscal_month] = time.day # should this be different from CY?
        record[:day_number_in_fiscal_year] = time.fiscal_year_yday(fiscal_year_offset_month)
        #record[:last_day_in_week_indicator] = 
        #record[:last_day_in_month_indicator] =
        #record[:calendar_week_ending_date] = 
        record[:calendar_week] = "Week #{time.week}"
        record[:calendar_week_number] = time.week
        record[:calendar_week_number_in_year] = time.week # DEPRECATED
        record[:calendar_month_name] = time.strftime("%B")
        record[:calendar_month_number_in_year] = time.month # DEPRECATED
        record[:calendar_month_number] = time.month
        record[:calendar_year_month] = time.strftime("%Y-%m")
        record[:calendar_quarter] = "Q#{time.quarter}"
        record[:calendar_quarter_number] = time.quarter
        record[:calendar_quarter_number_in_year] = time.quarter # DEPRECATED
        record[:calendar_year_quarter] = "#{time.strftime('%Y')}-#{record[:calendar_quarter]}"
        #record[:calendar_half_year] = 
        record[:calendar_year] = "#{time.year}"
        record[:fiscal_week] = "FY Week #{time.fiscal_year_week(fiscal_year_offset_month)}"
        record[:fiscal_week_number_in_year] = time.fiscal_year_week(fiscal_year_offset_month) # DEPRECATED
        record[:fiscal_week_number] = time.fiscal_year_week(fiscal_year_offset_month)
        record[:fiscal_month] = time.fiscal_year_month(fiscal_year_offset_month)
        record[:fiscal_month_number] = time.fiscal_year_month(fiscal_year_offset_month)
        record[:fiscal_month_number_in_year] = time.fiscal_year_month(fiscal_year_offset_month) # DEPRECATED
        record[:fiscal_year_month] = "FY#{time.fiscal_year(fiscal_year_offset_month)}-" + time.fiscal_year_month(fiscal_year_offset_month).to_s.rjust(2, '0')
        record[:fiscal_quarter] = "FY Q#{time.fiscal_year_quarter(fiscal_year_offset_month)}"
        record[:fiscal_year_quarter] = "FY#{time.fiscal_year(fiscal_year_offset_month)}-Q#{time.fiscal_year_quarter(fiscal_year_offset_month)}"
        record[:fiscal_quarter_number] = time.fiscal_year_quarter(fiscal_year_offset_month) # DEPRECATED
        record[:fiscal_year_quarter_number] = time.fiscal_year_quarter(fiscal_year_offset_month)
        #record[:fiscal_half_year] = 
        record[:fiscal_year] = "FY#{time.fiscal_year(fiscal_year_offset_month)}"
        record[:fiscal_year_number] = time.fiscal_year(fiscal_year_offset_month)
        record[:holiday_indicator] = holiday_indicators.include?(date) ? 'Holiday' : 'Nonholiday'
        record[:weekday_indicator] = weekday_indicators[time.wday]
        record[:selling_season] = 'None'
        record[:major_event] = 'None'
        record[:sql_date_stamp] = date

        record
      end
    end
  end
end

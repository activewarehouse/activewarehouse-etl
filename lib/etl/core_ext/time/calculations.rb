#Updated by Jack Hong on 04/05/08

module ETL #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Enables the use of time calculations within Time itself
      module Calculations
        def week
          cyw = ((yday - 1) / 7) + 1
          cyw = 52 if cyw == 53
          cyw
        end
        def quarter
          ((month - 1) / 3) + 1
        end
        def fiscal_year_week(offset_month=10)
          fyw = ((fiscal_year_yday(offset_month) - 1) / 7) + 1
          fyw = 52 if fyw == 53
          fyw
        end
        def fiscal_year_month(offset_month=10)
          shifted_month = month - (offset_month - 1)
          shifted_month += 12 if shifted_month <= 0
          shifted_month
        end
        def fiscal_year_quarter(offset_month=10)
          ((fiscal_year_month(offset_month) - 1) / 3) + 1
        end
        def fiscal_year(offset_month=10)
          month >= offset_month ? year + 1 : year
        end
        def fiscal_year_yday(offset_month=10)
          offset_days = 0
          1.upto(offset_month - 1) { |m| offset_days += ::Time.days_in_month(m, year) }
          shifted_year_day = yday - offset_days
          shifted_year_day += 365 if shifted_year_day <= 0
          shifted_year_day
        end
      end
    end
  end
end

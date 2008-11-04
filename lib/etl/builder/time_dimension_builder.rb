module ETL #:nodoc:
  module Builder #:nodoc:
    # Builder that creates a simple time dimension.
    class TimeDimensionBuilder
      def initialize
        # Returns an array of hashes representing records in the dimension. The values for each record are 
        # accessed by name.
        def build(options={})
          records = []
          0.upto(23) do |t_hour|
            0.upto(59) do |t_minute|
              0.upto(59) do |t_second|
                t_hour_string = t_hour.to_s.rjust(2, '0')
                t_minute_string = t_minute.to_s.rjust(2, '0')
                t_second_string = t_second.to_s.rjust(2, '0')
                record = {}
                record[:hour] = t_hour
                record[:minute] = t_minute
                record[:second] = t_second
                record[:minute_description] = "#{t_hour_string}:#{t_minute_string}"
                record[:full_description] = "#{t_hour_string}:#{t_minute_string}:#{t_second_string}"
                records << record
              end
            end
          end
          records
        end
      end
    end
  end
end
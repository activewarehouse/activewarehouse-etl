module ETL
  module Util
    # Return the distance of time in words from the given from_time to the specified to_time. If to_time
    # is not specified then Time.now is used. By default seconds are included...set the include_seconds
    # argument to false to disable the seconds.
    def distance_of_time_in_words(from_time, to_time=Time.now)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      seconds = (to_time - from_time).round
      distance_in_days = (seconds/(60*60*24)).round
      seconds = seconds % (60*60*24)
      distance_in_hours = (seconds/(60*60)).round
      seconds = seconds % (60*60)
      distance_in_minutes = (seconds/60).round
      seconds = seconds % 60
      distance_in_seconds = seconds
    
      s = ''
      s << "#{distance_in_days} days," if distance_in_days > 0
      s << "#{distance_in_hours} hours, " if distance_in_hours > 0
      s << "#{distance_in_minutes} minutes, " if distance_in_minutes > 0
      s << "#{distance_in_seconds} seconds"
      s
    end
  
    # Get the approximate disntance of time in words from the given from_time
    # to the the given to_time. If to_time is not specified then it is set
    # to Time.now. By default seconds are included...set the include_seconds
    # argument to false to disable the seconds.
    def approximate_distance_of_time_in_words(from_time, to_time=Time.now, include_seconds=true)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round
    
      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
        case distance_in_seconds
          when 0..4   then 'less than 5 seconds'
          when 5..9   then 'less than 10 seconds'
          when 10..19 then 'less than 20 seconds'
          when 20..39 then 'half a minute'
          when 40..59 then 'less than a minute'
          else             '1 minute'
        end
        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then 'about 1 hour'
        when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2879      then '1 day'
        when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
        when 43200..86399    then 'about 1 month'
        when 86400..525959   then "#{(distance_in_minutes / 43200).round} months"
        when 525960..1051919 then 'about 1 year'
        else                      "over #{(distance_in_minutes / 525960).round} years"
      end
    end
  end
end
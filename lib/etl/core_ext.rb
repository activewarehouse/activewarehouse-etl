require 'etl/core_ext/object'
require 'etl/core_ext/time'

class Object
  include ETL::CoreExt::Object::OptionalRequire
end

class Time
  include ETL::CoreExt::Time::Calculations
end

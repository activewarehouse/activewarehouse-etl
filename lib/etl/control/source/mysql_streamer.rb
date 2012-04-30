require 'open3'

# Internal: The MySQL streamer is a helper with works with the database_source
#           in order to allow you to use the --quick option (which stops MySQL)
#           from building a full result set,  also we don't build a full resultset
#           in Ruby - instead we yield a row at a time
#
class MySqlStreamer
  # Internal: Creates a MySQL Streamer
  #
  # query - the SQL query
  # target - the name of the ETL configuration (ie. development/production)
  # connection - the ActiveRecord connection
  #
  # Examples
  #
  #   MySqlStreamer.new("select * from bob", "development", my_connection)
  #
  def initialize(query, target, connection)
    # Lets just be safe and also make sure there aren't new lines
    # in the SQL - its bound to cause trouble
    @query = query.split.join(' ')
    @name = target
    @first_row = connection.select_all("#{query} LIMIT 1")
  end

  # We implement some bits of a hash so that database_source
  # can use them
  def any?
    @first_row.any?
  end 

  def first
    @first_row.first
  end

  def mandatory_option!(hash, key)
    value = hash[key]
    raise "Missing key #{key} in connection configuration #{@name}" if value.blank?
    value
  end

  def each
    keys = nil

    config = ETL::Base.configurations[@name.to_s]
    host = mandatory_option!(config, 'host')
    username = mandatory_option!(config, 'username')
    database = mandatory_option!(config, 'database')
    password = config['password'] # this one can omitted in some cases

    mysql_command = """mysql --quick -h #{host} -u #{username} -e \"#{@query.gsub("\n","")}\" -D #{database} --password=#{password} -B"""
    Open3.popen3(mysql_command) do |stdin, out, err, external|
      until (line = out.gets).nil? do
        line = line.gsub("\n","")
        if keys.nil?
          keys = line.split("\t")
        else
          hash = Hash[keys.zip(line.split("\t"))]
          # map out NULL to nil
          hash.each do |k, v|
            hash[k] = nil if v == 'NULL'
          end
          yield hash
        end
      end
      error = err.gets
      if (!error.nil? && error.strip.length > 0)
        throw error
      end
    end
  end
end
require 'open3'
require 'tempfile'

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
    run_mysql(:quick, :batch) do |stdin, out, err, external|
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

  private

  def run_mysql(*args)
    config = ETL::Base.configurations[@name.to_s]
    options = args.extract_options!.merge(
      'host' => mandatory_option!(config, 'host'),
      'user' => mandatory_option!(config, 'username'),
      'database' => mandatory_option!(config, 'database'),
      'password' => config['password'],
      'execute' => "\"#{@query}\"")

    Tempfile.open('mysqlstreamer') do |option_file|
      option_file.puts '[client]'
      args.each {|keyword| option_file.puts keyword}
      options.each {|key, value| option_file.puts "#{key}=#{value}"}
      option_file.flush

      yield Open3.popen3("mysql --defaults-extra-file=#{option_file.path}")
    end
  end
end

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
	    @first_row = connection.select_all("#{query} limit 1")
	end

	# We implement some bits of a hash so that database_source
	# can use them
	def any?
	    @first_row.any?
	end 

	def first
	    @first_row.first
	end

	def each
		puts "Using the Streaming MySQL from the command line"
		keys = nil
		connection_configuration = ETL::Base.configurations[@name.to_s]
		mysql_command = """mysql --quick -h #{connection_configuration["host"]} -u #{connection_configuration["username"]} -e \"#{@query.gsub("\n","")}\" -D #{connection_configuration["database"]} --password=#{connection_configuration["password"]} -B"""
		Open3.popen3(mysql_command) do |stdin, out, err, external|
			until (line = out.gets).nil? do
				line = line.gsub("\n","")
				if keys.nil?
					keys = line.split("\t")
				else
					hash = Hash[keys.zip(line.split("\t"))]
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
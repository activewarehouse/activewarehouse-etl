require 'open3'

class MySqlStreamer

	def initialize(query, target)
		@query = query
		@name = target
	end

	def each
		puts "Using the Streaming MySQL from the command line"
		keys = nil
		connection_configuration = ETL::Base.configurations[@name.to_s]
		mysql_command = """mysql --quick -u #{connection_configuration["username"]} -e \"#{@query.gsub("\n","")}\" -D #{connection_configuration["database"]} --password=#{connection_configuration["password"]} -B"""
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
			if (error.strip.length > 0)
				throw error
			end
		end
	end
end
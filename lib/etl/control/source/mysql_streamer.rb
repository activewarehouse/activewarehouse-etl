require 'open3'

class MySqlStreamer

	def initialize(query, connection)
		@query = query
		@connection = connection
		puts "Connection is #{connection.inspect}"
	end

	def each(&block)
		keys = nil
		mysql_command = """mysql -u root -e '#{@query}' -D core_development -B --quick"""
		Open3.popen3(mysql_command) do |stdin, out, err, external|  
			until (line = out.gets).nil? do
		      	line = line.gsub("\n","")
		      	if keys.nil?
		      		keys = line.split("\t")
		      	else
		      		hash = Hash[keys.zip(line.split("\t"))]
		        	yield hash.inspect
		        end
		    end

		    
		end
	end
	  
end
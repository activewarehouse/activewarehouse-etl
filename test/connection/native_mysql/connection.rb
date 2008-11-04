print "Using native MySQL\n"

puts "Resetting database"
conn = ETL::Engine.connection(:data_warehouse)
conn.recreate_database(conn.current_database)
conn.reconnect!
lines = open(File.join(File.dirname(__FILE__), 'schema.sql')).readlines
lines.join.split(';').each { |line| conn.execute(line) }
conn.disconnect!
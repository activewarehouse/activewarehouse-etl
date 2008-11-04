print "Using PostgreSQL\n"

puts "Resetting database"
conn = ETL::Engine.connection(:data_warehouse)

lines = open(File.join(File.dirname(__FILE__), 'schema.sql')).readlines
lines.join.split(';').each_with_index do |line, index|
  begin
    conn.execute(line)
  rescue => e
    puts "failed to load line #{index}: #{e}"
  end
end

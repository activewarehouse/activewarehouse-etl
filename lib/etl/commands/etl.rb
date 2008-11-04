#--
# Copyright (c) 2006 Anthony Eden
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'benchmark'
require 'getoptlong'

# Print a usage statement
def usage #:nodoc:
  puts "Usage: etl file [file file ...]" # TODO: add the command line options
end

def execute
  opts = GetoptLong.new(
    [ '--version', '-v', GetoptLong::NO_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--limit', '-l', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--offset', '-o', GetoptLong::REQUIRED_ARGUMENT],
    [ '--newlog', '-n', GetoptLong::NO_ARGUMENT ],
    [ '--skip-bulk-import', '-s', GetoptLong::NO_ARGUMENT ],
    [ '--read-locally', GetoptLong::NO_ARGUMENT],
    [ '--rails-root', GetoptLong::REQUIRED_ARGUMENT]
  )
  
  options = {}
  opts.each do |opt, arg|
    case opt
    when '--version'
      puts "ActiveWarehouse ETL version #{ETL::VERSION::STRING}"
      return
    when '--help'
      usage
      return
    when '--config'
      options[:config] = arg
    when '--limit'
      options[:limit] = arg.to_i
    when '--offset'
      options[:offset] = arg.to_i
    when '--newlog'
      options[:newlog] = true
    when '--skip-bulk-import'
      puts "skip bulk import enabled"
      options[:skip_bulk_import] = true
    when '--read-locally'
      puts "read locally enabled"
      options[:read_locally] = true
    when '--rails-root'
      options[:rails_root] = arg
      puts "rails root set to #{options[:rails_root]}"
    end
  end

  if ARGV.length < 1
    usage
  else
    puts "Starting ETL process"

    ETL::Engine.init(options)
    ARGV.each do |f|
      ETL::Engine.realtime_activity = true
      ETL::Engine.process(f)
    end
  
    puts "ETL process complete\n\n"
  end
end

execute
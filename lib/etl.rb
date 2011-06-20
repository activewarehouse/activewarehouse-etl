# This source file requires all of the necessary gems and source files for ActiveWarehouse ETL. If you
# load this source file all of the other required files and gems will also be brought into the 
# runtime.

#--
# Copyright (c) 2006-2007 Anthony Eden
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

require 'logger'
require 'yaml'
require 'erb'

require 'rubygems'

unless defined?(REXML::VERSION)
  require 'rexml/rexml'
  unless defined?(REXML::VERSION)
    REXML::VERSION = REXML::Version
  end
end

require 'active_support'
require 'active_record'
require 'adapter_extensions'

if RUBY_VERSION < '1.9'
  require 'faster_csv'
  CSV = FasterCSV unless defined?(CSV)
else
  require 'csv'
end

# patch for https://github.com/activewarehouse/activewarehouse-etl/issues/24
# allow components to require optional gems
class Object
  def optional_require(feature)
    begin
      require feature
    rescue LoadError
    end
  end
end

$:.unshift(File.dirname(__FILE__))

require 'etl/core_ext'
require 'etl/util'
require 'etl/http_tools'
require 'etl/builder'
require 'etl/version'
require 'etl/engine'
require 'etl/control'
require 'etl/batch'
require 'etl/row'
require 'etl/parser'
require 'etl/transform'
require 'etl/processor'
require 'etl/generator'
require 'etl/screen'

module ETL #:nodoc:
  class ETLError < StandardError #:nodoc:
  end
  class ControlError < ETLError #:nodoc:
  end
  class DefinitionError < ControlError #:nodoc:
  end
  class ConfigurationError < ControlError #:nodoc:
  end
  class MismatchError < ETLError #:nodoc:
  end
  class ResolverError < ETLError #:nodoc:
  end
  class ScreenError < ETLError #:nodoc:
  end
  class FatalScreenError < ScreenError #:nodoc:
  end
end
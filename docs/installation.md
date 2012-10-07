---
layout: documentation
title: Documentation - Installation

current: Installation
---
# Installation

To install ActiveWarehouse ETL you must first install Ruby and Rubygems. Once you have a functioning Ruby and Rubygems installation you can install by simply running gem install:

    gem install activewarehouse-etl

If you are installing this into a Ruby on Rails project then yo may use the Bundler `Gemfile`.  Make sure you run `bundle install` after making the changes.

    gem 'activewarehouse-etl'

Or you may simply clone the repository into some place on your Ruby load path.

    git clone http://github.com/activewarehouse/activewarehouse-etl.git

Note that if you do not use the gem install you will still require Ruby Gems and all the other dependencies listed below. Further, the etl executable will reside in activewarehouse-etl/bin. You must either link to etl from somewhere in your PATH or run it by specifying the full directory path /path/to/activewarehouse-etl/bin/etl

ActiveWarehouse ETL depends on FasterCSV, ActiveRecord, ActiveSupport and SQLite3. If these libraries are not already installed they should be installed along with ActiveWarehouse ETL. Naturally, if you use any other DBMS you need the adapter for that as well.

Finally, if you are running the etl command line, ensure that you are either including a config file that includes rails or add `require 'rails/all'` to the bin/etl script if required.
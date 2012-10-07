---
layout: documentation
title: Documentation - Getting Started

current: Getting Started
---
# Getting Started

Be sure to run through the <a href="/docs/installation.html">Installation page</a> to get the gem installed first.

ActiveWarehouse ETL uses ActiveRecord to configure databases that it will connect to, whether that be the `etl_execution` that it uses internally to track status or the databases you are using in your control scripts.

We need to create a `database.yml` file to configure ActiveRecord, ActiveWarehouse ETL will look for this `config/database.yml` in your current directory.  Here's an starter example:

    # APP_ROOT/config/database.yml

    etl_execution:
      database: my_app_etl_execution
      adapter: mysql
      hostname: localhost
      username: root
      password:

Here we configure the `etl_execution` environment to connect to the `my_app_etl_execution` database. The `etl_execution` environment is the one that ActiveWarehouse ETL uses to track internal status, and is required.  Here we gave it MySQL configuration options, but you are free to use any adapters that ActiveRecord supports.


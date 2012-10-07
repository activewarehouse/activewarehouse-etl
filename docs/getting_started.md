---
layout: documentation
title: Documentation - Getting Started

current: Getting Started
---
# Getting Started

Be sure to run through the <a href="/docs/installation.html">Installation page</a> to get the gem installed first.

ActiveWarehouse ETL currently uses ActiveRecord to connect to databases that are configured, whether that be the `etl_execution` that it uses internally to track status or the databases you are using in your control scripts.

<div class="alert alert-block alert-notice">
  <h3>ActiveRecord plans</h3>
  <p>
    ActiveWarehouse ETL currently uses ActiveRecord to connect to databases, there are plans to move off this and be more agnostic in the future but for now you'll need ActiveRecord 3+.
  </p>
</div>

We need to create a `database.yml` file to configure ActiveRecord, ActiveWarehouse ETL will look for a `database.yml` in the config directory.  Here's an example:

    # APP_ROOT/config/database.yml
    etl_execution:
      database: my_app_etl_execution
      adapter: mysql
      hostname: localhost
      username: root
      password:

Here we configure the `etl_execution` environment to connect to the `my_app_etl_execution` database. The `etl_execution` environment is the one that ActiveWarehouse ETL uses to track internal status, and is required.  Here we gave it MySQL configuration options, but you are free to use any adapters that ActiveRecord supports.

Create the database above and let's move on to a simple control script.
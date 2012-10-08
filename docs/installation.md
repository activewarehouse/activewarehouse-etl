---
layout: documentation
title: Documentation - Installation

current: Installation
---
# Installation

To install ActiveWarehouse ETL you must first install Ruby and RubyGems.

### From RubyGems

Install by simply running gem install:

{% highlight bash %}
gem install activewarehouse-etl
{% endhighlight %}

### Into a Rails project

If you are installing this into a Ruby on Rails project then you should use the Bundler `Gemfile`.  Make sure you run `bundle install` after making the changes.

To use the latest stable release:

{% highlight ruby %}
gem 'activewarehouse-etl'
{% endhighlight %}

To use the latest dev release, use with caution:

{% highlight ruby %}
gem 'activewarehouse-etl', :git => "git://github.com/activewarehouse/activewarehouse-etl.git" 
{% endhighlight %}


### Building the gem from source

Alternatively you can install by cloning the repository, building the gem and installing it manually:

{% highlight bash %}
git clone http://github.com/activewarehouse/activewarehouse-etl.git
cd activewarehouse-etl
bundle --without test
bundle exec rake install
{% endhighlight %}

### Using directly from the source

{% highlight bash %}
git clone http://github.com/activewarehouse/activewarehouse-etl.git
{% endhighlight %}

The etl executable will reside in activewarehouse-etl/bin. You must either link to etl from somewhere in your PATH or run it by specifying the full directory path `/path/to/activewarehouse-etl/bin/etl`.

Finally, when you run the etl command line, ensure that you are either including a config file that includes rails or add `require 'rails/all'` to the bin/etl script if required.

TODO: 

* installing a specific release candidate
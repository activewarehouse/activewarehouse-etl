h1. ActiveWarehouse-ETL

>>> :warning: THIS GEM IS NOT MAINTAINED ANYMORE - Consider using "Kiba ETL":http://www.kiba-etl.org instead <<<

ActiveWarehouse-ETL is a Ruby Extract-Transform-Load (ETL) tool.

This tool is both usable and used in production under its current form - but be aware the project is under reorganization: a new team is shaping up and we're working mostly on making it easier for people to contribute first. Up-to-date documentation will only come later.

"!https://secure.travis-ci.org/activewarehouse/activewarehouse-etl.png!":http://travis-ci.org/activewarehouse/activewarehouse-etl

h2. Usage

The documentation is sparse and not everything is up to date, too, but here are useful bits to get you started:

* read the "Introduction":https://github.com/activewarehouse/activewarehouse-etl/wiki/Documentation
* later on, refer to the "RDoc":http://rdoc.info/github/activewarehouse/activewarehouse-etl/master/frames (be sure to check out Processor and Transform)
* read the "source":https://github.com/activewarehouse/activewarehouse-etl/tree/master/lib/etl

If you're lost, please ask questions on the "Google Group":http://groups.google.com/group/activewarehouse-discuss and we'll take care of it.

One thing to keep in mind is that ActiveWarehouse-ETL is highly hackable: you can pretty much create all you need with extra ruby code, even if it's not currently supported.

h2. Compatibility

See "Travis":http://travis-ci.org/activewarehouse/activewarehouse-etl and our set of "gemfiles":https://github.com/activewarehouse/activewarehouse-etl/tree/master/test/config/gemfiles for the currently tested combinations.

If you meet any error, please drop a line on the "Google Group":http://groups.google.com/group/activewarehouse-discuss so that we can fix it.

h2. Contributing

Fork on GitHub and after you've committed tested patches, send a pull request.

TODO: explain how to run the tests like on Travis.

* install RVM and Bundler
* install MySQL and/or Postgresql (you can use brew for that)
* edit test/config/database.yml if needed (don't commit this file though)
* run (for instance):

    @rake "ci:run_one[mysql2,test/config/gemfiles/Gemfile.rails-3.0.x]"@

or for all the combinations:
    
    @rake ci:run_matrix@

h2. Contributors

ActiveWarehouse-ETL is the work of many people since late 2006 - here is a list, in no particular order:

* Anthony Eden
* Chris DiMartino
* Darrell Fuhriman
* Fabien Carrion
* Jacob Maine
* James B. Byrne
* Jay Zeschin
* Jeremy Lecour
* Steve Meyfroidt
* Seth Ladd
* "Thibaut Barrère":https://github.com/thbar
* Stephen Touset
* sasikumargn
* Andrew Kuklewicz
* Leif Gustafson
* Andrew Sodt
* Tyler Kiley
* Colman Nady
* Scott Gonyea
* "Philip Dodds":https://github.com/pdodds
* "Sinisa Grgic":https://github.com/sgrgic
* "Kenny Meyer":https://github.com/kennym
* "Chris":https://github.com/chrisgogreen
* "Peter Glerup Ericson":https://github.com/pgericson
* "Ian Morgan":https://github.com/seeingidog
* "Julien Biard":https://github.com/tchukuchuk
* "Jamie van Dyke":https://github.com/fearoffish

If your name should be on the list but isn't, please leave a comment!

h2. Features

Currently supported features:

* ETL Domain Specific Language (DSL) - Control files are specified in a Ruby-based DSL
* Multiple source types. Current supported types:
** Fixed-width and delimited text files
** XML files through SAX
** Apache combined log format
* Multiple destination types - file and database destinations
* Support for extracting from multiple sources in a single job
* Support for writing to multiple destinations in a single job
* A variety of built-in transformations are included:
** Date-to-string, string-to-date, string-to-datetime, string-to-timestamp
** Type transformation supporting strings, integers, floats and big decimals
** Trim
** SHA-1
** Decode from an external decode file
** Default replacement for empty values
** Ordinalize
** Hierarchy lookup
** Foreign key lookup
** Ruby blocks
** Any custom transformation class
* A variety of build-in row-level processors
** Check exists processor to determine if the record already exists in the destination database
** Check unique processor to determine whether a matching record was processed during this job execution
** Copy field
** Rename field
** Hierarchy exploder which takes a tree structure defined through a parent id and explodes it into a hierarchy bridge table
** Surrogate key generator including support for looking up the last surrogate key from the target table using a custom query
** Sequence generator including support for context-sensitive sequences where the context can be defined as a combination of fields from the source data
** New row-level processors can easily be defined and applied
* Pre-processing
** Truncate processor
* Post-processing
** Bulk import using native RDBMS bulk loader tools
* Virtual fields - Add a field to the destination data which doesn't exist in the source data
* Built in job and record meta data
* Support for type 1 and type 2 slowly changing dimensions
** Automated effective date and end date time stamping for type 2
** CRC checking

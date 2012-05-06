Work in progress: guides for ActiveWarehouse-ETL.

To run - make sure you have pygments installed, then:

```
bundle
jekyll --server --auto
open http://localhost:4000/docs/installation.html
```

The documentation structure and styling I'm gradually adding is based (with autorisation) on Vagrant docs (except for the homepage).

### Potential sections

- getting started: how to install/setup
- a hello world: transforming a sample csv into another csv
- a more advanced hello world: loading data into activerecord with migrations, upsert etc on 2 tables maybe
- the control file lifecycle explained (what happens when a file is loaded, declarations of sources, transforms, before_read/after_write, screens, error handlers...)
- the engine lifecycle explained (how rows are processed under the hood once the control file is loaded)
- activewarehouse-etl for non rubyists (ie: explanations about ruby, bundler, gems etc)
- extending activewarehouse-etl: how to create custom sources, destinations, transforms...

### Expectations from the mailing list

> I think for the structure and readability of the guides could always use a breakdown in the three key concepts: Extraction, Transformation and Loading, and in the two intermediate steps: E => T and T => L.
> It should become more clear what each component does and what time.
> As the level of detail increases, the details increases and decreases the "magic".
> In particular, as this would help to add documentation for the critical steps

> A general requirement: for each feature or type of that feature include a commented code sample with source, transformations and destination.
> Managing and scheduling jobs, How is this done now? with a gem like delayed job?

> An example of the Decode Transformation table - Column Name requirements, number of columns?
> Multiple input sources but with different input schemas(this might be the built in resolver?).

> The sample is too complex for a beginner, even those who know what ETL 
> is, it has too many files all over the place. Those who do not know 
> anything about ETL might be really confused. It would be much better 
> if there were multiple "levels" of sample, from a sample with up to 
> five lines to such complex. 

> Example of whole ETL samples: 

> Example 1: load file from CSV to a database table (nothing more) 
> Example 2: Ex 1 + do some field transformation 
> Example 3: use two sources, for example CSV + table --> table 
> Example 4: ... 

> It is mostly "how-to" based with separate class reference. I do not 
> need to know all the switches/parameters/methods/whatever, I just want 
> to play to get the idea and then apply it to my data. Best thing is 
> commented examples or commented whole example simple work-flow. 

> I think aw-etl has plenty of resources available, just needs good 
> "quick start" and 3-4 incremental primitive examples. Also think of 
> those who need ETL but do not know what ETL patterns are. "Why I 
> should use this instead of bunch of SQL scripts?" 

> I think some people find activewarehouse-etl and others gens from google, it would be cool if every project at the first page send the user to the website http://www.activewarehouse.info/ that should have a link to the official documentation, so that guys can know if it reallyworks for their problems.

> At the current documentation they can learn about how to install, I think there should have something about how to update gem  from a not realesed gem yet, like at my case that I were using the gem not released 1.0.0rc  and the one released was the 0.9.5.

> Must of my problems were configuring the environment, I think put some links to expected errors that happens with the pre requisits
> As Stefan said before short levels of exemples make it easy to understand...
> Teach how to custom or rack the etl files I mean, what happens like... you can put here some ruby or rails code then you can do whatever you want

> Documentation on installing the gem from the current github master is 
> becoming essential to me. Could you explain it? 


drop table people;
create table people (
  id SERIAL PRIMARY KEY,
  first_name character varying(255) not null,
  /* null below allowed for bulk_import_with_empties.txt test */
  last_name character varying(255) null,
  ssn character varying(64) not null
);

drop table places;
create table places (
  id SERIAL PRIMARY KEY,
	address text,
	city character varying(255),
	state character varying(255),
	country character varying(2)
);

drop table person_dimension;
create table person_dimension (
  id SERIAL PRIMARY KEY,
  first_name character varying(50),
  last_name character varying(50),
  address character varying(100),
  city character varying(50),
  state character varying(50),
  zip_code character varying(20),
  effective_date timestamp without time zone,
  end_date timestamp without time zone,
  latest_version boolean not null
);

drop table truncate_test;
create table truncate_test (
  id SERIAL PRIMARY KEY,
	x character varying(4)
);
insert into truncate_test (x) values ('a');
insert into truncate_test (x) values ('b');
insert into truncate_test (x) values ('c');
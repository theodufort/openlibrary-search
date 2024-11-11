-- -- switch to using the database
\c openlibrary;

-- -- set client encoding
set client_encoding = 'UTF8';

-- -- create tables
\i 'db_scripts_v2/schema_new.sql';

-- Load the data
\i 'db_scripts_v2/load_data.sql';

-- finally remove temp table
drop table fileinfo;

-- vaccuum analyze will remove dead tuples and try to regain some space
-- if you have enough room, you can use vacuum full analyze which will gain the most space back, but it requires enough space on your computer to make a complete second copy of the db
-- if you add verbose it will explain what it is trying to do.  (vacuum verbose analyze)
vacuum analyze;

-- -- switch to using the database
\c openlibrary;

-- -- set client encoding
set client_encoding = 'UTF8';

-- -- create tables
\i 'db_scripts/schema_new.sql';

-- create filenames that can be accessed in lieu of parameters
\i 'db_scripts/tbl_fileinfo.sql';

-- load in data
\i 'db_scripts/load.sql';

-- finally remove temp table
drop table fileinfo;

-- vaccuum analyze will remove dead tuples and try to regain some space
-- if you have enough room, you can use vacuum full analyze which will gain the most space back, but it requires enough space on your computer to make a complete second copy of the db
-- if you add verbose it will explain what it is trying to do.  (vacuum verbose analyze)
vacuum analyze;

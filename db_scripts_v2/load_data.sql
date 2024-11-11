-- Create fileinfo table to track processed files
CREATE TABLE fileinfo (
    filename text PRIMARY KEY,
    processed boolean DEFAULT false,
    record_count integer DEFAULT 0,
    last_modified timestamp DEFAULT current_timestamp
);

-- Load authors data from JSON
CREATE TEMP TABLE temp_authors (data jsonb);
\set authors_file `psql -t -A -c "SELECT filename FROM fileinfo WHERE filename LIKE '%authors%' AND NOT processed LIMIT 1;" openlibrary`
\COPY temp_authors FROM :'authors_file' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO authors (id, name)
SELECT 
    (data->>'key')::uuid,
    data->>'name'
FROM temp_authors;

UPDATE fileinfo 
SET processed = true, 
    record_count = (SELECT count(*) FROM temp_authors),
    last_modified = current_timestamp
WHERE filename = :'authors_file';

-- Load works data from JSON
CREATE TEMP TABLE temp_works (data jsonb);
\set works_file `psql -t -A -c "SELECT filename FROM fileinfo WHERE filename LIKE '%works%' AND NOT processed LIMIT 1;" openlibrary`
\COPY temp_works FROM :'works_file' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO works (id, author_id)
SELECT 
    (data->>'key')::uuid,
    (data->'authors'->0->>'key')::uuid
FROM temp_works;

UPDATE fileinfo 
SET processed = true, 
    record_count = (SELECT count(*) FROM temp_works),
    last_modified = current_timestamp
WHERE filename = :'works_file';

-- Load editions/books data from JSON
CREATE TEMP TABLE temp_editions (data jsonb);
\set editions_file `psql -t -A -c "SELECT filename FROM fileinfo WHERE filename LIKE '%editions%' AND NOT processed LIMIT 1;" openlibrary`
\COPY temp_editions FROM :'editions_file' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO books (id, isbn13, title, published_date)
SELECT 
    (data->>'key')::uuid,
    data->'isbn_13'->0,
    data->>'title',
    TO_DATE(data->>'publish_date', 'YYYY')
FROM temp_editions;

UPDATE fileinfo 
SET processed = true, 
    record_count = (SELECT count(*) FROM temp_editions),
    last_modified = current_timestamp
WHERE filename = :'editions_file';

-- Clean up temp tables
DROP TABLE temp_authors;
DROP TABLE temp_works;
DROP TABLE temp_editions;

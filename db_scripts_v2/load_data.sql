-- Load authors data from JSON
CREATE TEMP TABLE temp_authors (data jsonb);
\COPY temp_authors FROM 'example_processed_data_authors.csv' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO authors (id, name)
SELECT 
    (data->>'key')::uuid,
    data->>'name'
FROM temp_authors;

-- Load works data from JSON
CREATE TEMP TABLE temp_works (data jsonb);
\COPY temp_works FROM 'example_processed_data_works.csv' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO works (id, author_id)
SELECT 
    (data->>'key')::uuid,
    (data->'authors'->0->>'key')::uuid
FROM temp_works;

-- Load editions/books data from JSON
CREATE TEMP TABLE temp_editions (data jsonb);
\COPY temp_editions FROM 'example_processed_data_editions.csv' CSV QUOTE E'\b' DELIMITER '|';

INSERT INTO books (id, isbn13, title, published_date)
SELECT 
    (data->>'key')::uuid,
    data->'isbn_13'->0,
    data->>'title',
    TO_DATE(data->>'publish_date', 'YYYY')
FROM temp_editions;

-- Clean up temp tables
DROP TABLE temp_authors;
DROP TABLE temp_works;
DROP TABLE temp_editions;

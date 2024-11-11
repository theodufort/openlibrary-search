-- Create fileinfo table to track processed files
CREATE TABLE fileinfo (
    id SERIAL PRIMARY KEY,
    name_of_table text NOT NULL,
    filenames text[] NOT NULL,
    loaded boolean DEFAULT false,
    last_modified timestamp DEFAULT current_timestamp
);

-- Insert file tracking info
-- Insert file tracking info for each data type
INSERT INTO fileinfo (name_of_table, filenames, loaded)
VALUES (
    'authors',
    ARRAY(
        SELECT './data/processed/' || unnest(ARRAY[
            'authors_2000000.csv', 'authors_4000000.csv', 'authors_6000000.csv',
            'authors_8000000.csv', 'authors_10000000.csv', 'authors_12000000.csv',
            'authors_14000000.csv'
        ])
    ),
    false
);

INSERT INTO fileinfo (name_of_table, filenames, loaded)
VALUES (
    'works',
    ARRAY(
        SELECT './data/processed/' || unnest(ARRAY[
            'works_2000000.csv', 'works_4000000.csv', 'works_6000000.csv',
            'works_8000000.csv', 'works_10000000.csv', 'works_12000000.csv',
            'works_14000000.csv', 'works_16000000.csv', 'works_18000000.csv',
            'works_20000000.csv', 'works_22000000.csv', 'works_24000000.csv',
            'works_26000000.csv', 'works_28000000.csv', 'works_30000000.csv',
            'works_32000000.csv', 'works_34000000.csv', 'works_36000000.csv'
        ])
    ),
    false
);

INSERT INTO fileinfo (name_of_table, filenames, loaded)
VALUES (
    'books',
    ARRAY(
        SELECT './data/processed/' || unnest(ARRAY[
            'editions_2000000.csv', 'editions_4000000.csv', 'editions_6000000.csv',
            'editions_8000000.csv', 'editions_10000000.csv', 'editions_12000000.csv',
            'editions_14000000.csv', 'editions_16000000.csv', 'editions_18000000.csv',
            'editions_20000000.csv', 'editions_22000000.csv', 'editions_24000000.csv',
            'editions_26000000.csv', 'editions_28000000.csv', 'editions_30000000.csv',
            'editions_32000000.csv', 'editions_34000000.csv', 'editions_36000000.csv',
            'editions_38000000.csv', 'editions_40000000.csv', 'editions_42000000.csv',
            'editions_44000000.csv', 'editions_46000000.csv', 'editions_48000000.csv',
            'editions_50000000.csv'
        ])
    ),
    false
);

-- Create temp tables
CREATE TEMP TABLE temp_authors (data jsonb);
CREATE TEMP TABLE temp_works (data jsonb);
CREATE TEMP TABLE temp_editions (data jsonb);

-- Load authors data
\a
\t
\o copy_commands.sql
SELECT format('\copy temp_authors (data) FROM ''%s'' WITH (FORMAT csv, DELIMITER E''\t'', QUOTE ''|'');', filename) 
FROM fileinfo, unnest(filenames) AS filename
WHERE NOT loaded AND name_of_table = 'authors';
\o
\i copy_commands.sql

INSERT INTO authors (id, name)
SELECT 
    (data->>'key')::uuid,
    data->>'name'
FROM temp_authors;

UPDATE fileinfo SET loaded = true, last_modified = current_timestamp
WHERE name_of_table = 'authors' AND NOT loaded;

-- Load works data
\a
\t
\o copy_commands.sql
SELECT format('\copy temp_works (data) FROM ''%s'' WITH (FORMAT csv, DELIMITER E''\t'', QUOTE ''|'');', filename)
FROM fileinfo, unnest(filenames) AS filename
WHERE NOT loaded AND name_of_table = 'works';
\o
\i copy_commands.sql

INSERT INTO works (id, author_id)
SELECT 
    (data->>'key')::uuid,
    (data->'authors'->0->>'key')::uuid
FROM temp_works;

UPDATE fileinfo SET loaded = true, last_modified = current_timestamp
WHERE name_of_table = 'works' AND NOT loaded;

-- Load editions/books data
\a
\t
\o copy_commands.sql
SELECT format('\copy temp_editions (data) FROM ''%s'' WITH (FORMAT csv, DELIMITER E''\t'', QUOTE ''|'');', filename)
FROM fileinfo, unnest(filenames) AS filename
WHERE NOT loaded AND name_of_table = 'books';
\o
\i copy_commands.sql

INSERT INTO books (id, work_id, isbn10, isbn13, title, description, language, published_date, page_count)
SELECT 
    (data->>'key')::uuid,
    (data->'works'->0->>'key')::uuid,
    data->'isbn_10'->0#>>'{}',
    data->'isbn_13'->0#>>'{}',
    data->>'title',
    data->>'description',
    data->'languages'->0->>'key',
    CASE 
        WHEN data->>'publish_date' ~ '^\d{4}$' THEN TO_DATE(data->>'publish_date', 'YYYY')
        ELSE NULL 
    END,
    (data->>'number_of_pages')::INT
FROM temp_editions;

UPDATE fileinfo SET loaded = true, last_modified = current_timestamp
WHERE name_of_table = 'books' AND NOT loaded;

-- Clean up
DROP TABLE IF EXISTS temp_authors;
DROP TABLE IF EXISTS temp_works;
DROP TABLE IF EXISTS temp_editions;
DROP TABLE IF EXISTS copy_commands;

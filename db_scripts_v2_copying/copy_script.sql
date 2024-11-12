BEGIN;

-- Insert data into new `authors` table with transformation
INSERT INTO authors (id, name)
SELECT 
    ao.key AS id,  -- Generate a UUID for each new row
    COALESCE(data->>'name', 'Unknown') AS name  
FROM 
    authors_old as ao;

-- Re-enable constraints if any were disabled (adjust if needed)
ALTER TABLE authors ENABLE TRIGGER ALL;

COMMIT;

BEGIN;

-- Insert data into new `works` table with transformations
INSERT INTO works (id, cover_id, author_id)
SELECT 
    wo.key AS id,                       
    (data->'covers'->>0)::INTEGER AS cover_id, 
    data->'authors'->0->>'key' AS author_id  
FROM 
    works_old AS wo;      

-- Re-enable constraints if any were disabled (adjust if needed)
ALTER TABLE works ENABLE TRIGGER ALL;

COMMIT;

BEGIN;

-- Assuming `books_source` is a table or view holding the source JSON data
INSERT INTO books (
    id,
    work_id,
    isbn10,
    isbn13,
    title,
    subtitle,
    description,
    language,
    published_date,
    page_count
)
SELECT 
    key AS id,
    work_key AS work_id,
    (data->'isbn_10'->>0) AS isbn10,  
    (data->'isbn_13'->>0) AS isbn13,           
    data->>'title' AS title,           
    data->>'subtitle' AS subtitle,                     
    data->>'description' AS description,                  
    (data->'languages'->0->>'key') AS language,   
    data->>'publish_date' AS published_date,     
    COALESCE(data->>'number_of_pages',data->>'pagination')::INT AS page_count  
FROM 
    editions_old; 


COMMIT;
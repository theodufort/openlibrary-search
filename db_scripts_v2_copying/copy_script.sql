
INSERT INTO authors (id, name)
SELECT 
    ao.key AS id,  -- Generate a UUID for each new row
    COALESCE(data->>'name', 'Unknown') AS name  
FROM 
    authors_old as ao;



INSERT INTO works (id, cover_id, author_id)
SELECT 
    wo.key AS id,                       
    (data->'covers'->>0)::INTEGER AS cover_id, 
    data->'authors'->0->>'key' AS author_id  
FROM 
    works_old AS wo;      



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
    data->>'publish_date' AS publish_date,

    CASE 
        WHEN COALESCE(data->>'number_of_pages', data->>'pagination') ~ '^\d+$'
        THEN (COALESCE(data->>'number_of_pages', data->>'pagination'))::INT
        ELSE NULL
    END AS page_count
FROM 
    editions_old
WHERE 
    data->'isbn_13'->>0 IS NOT NULL
ON CONFLICT (isbn10, isbn13) DO NOTHING;

INSERT INTO subjects (id, name)
SELECT gen_random_uuid(), subject
FROM (
    SELECT jsonb_array_elements_text(data->'subjects') AS subject
    FROM editions_old
    WHERE data->'subjects' IS NOT NULL
) AS all_subjects
GROUP BY subject
HAVING COUNT(*) > 1000
ON CONFLICT (name) DO NOTHING;


INSERT INTO book_subjects (book_id, subject_id)
SELECT 
    e.key AS book_id,
    s.id AS subject_id
FROM 
    editions_old AS e
JOIN 
    subjects AS s ON s.name = ANY(SELECT jsonb_array_elements_text(e.data->'subjects'))
WHERE 
    e.data->'subjects' IS NOT NULL
ON CONFLICT DO NOTHING;

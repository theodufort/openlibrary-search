begin;
-- 1. Alter the editions table to add new columns
ALTER TABLE editions
ADD COLUMN title TEXT,
ADD COLUMN subtitle TEXT,
ADD COLUMN full_title TEXT,
ADD COLUMN author_keys TEXT[],
ADD COLUMN isbn_13 TEXT[],
ADD COLUMN language_keys TEXT[],
ADD COLUMN subjects TEXT[],
ADD COLUMN weight TEXT,
ADD COLUMN pagination TEXT,
ADD COLUMN publish_date TEXT,
ADD COLUMN publishers TEXT[],
ADD COLUMN lc_classifications TEXT[];

-- 2. Update each row to populate the new columns from the JSON data
UPDATE editions
SET
  title = data ->> 'title',
  subtitle = data ->> 'subtitle',
  full_title = data ->> 'full_title',
  author_keys = (
    SELECT array_agg(elem ->> 'key')
    FROM jsonb_array_elements(data -> 'authors') AS elem
  ),
  isbn_13 = (
    SELECT array_agg(elem)
    FROM jsonb_array_elements_text(data -> 'isbn_13') AS elem
  ),
  language_keys = (
    SELECT array_agg(elem ->> 'key')
    FROM jsonb_array_elements(data -> 'languages') AS elem
  ),
  subjects = (
    SELECT array_agg(elem)
    FROM jsonb_array_elements_text(data -> 'subjects') AS elem
  ),
  weight = data ->> 'weight',
  pagination = data ->> 'pagination',
  publish_date = data ->> 'publish_date',
  publishers = (
    SELECT array_agg(elem)
    FROM jsonb_array_elements_text(data -> 'publishers') AS elem
  ),
  lc_classifications = (
    SELECT array_agg(elem)
    FROM jsonb_array_elements_text(data -> 'lc_classifications') AS elem
  );

commit;
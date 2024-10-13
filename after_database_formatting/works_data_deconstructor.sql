BEGIN;

-- 1. Adjust existing columns
ALTER TABLE public.works
ALTER COLUMN last_modified TYPE TIMESTAMP
USING last_modified::TIMESTAMP;

-- 2. Add new columns
ALTER TABLE public.works
ADD COLUMN title TEXT,
ADD COLUMN author_keys TEXT[],
ADD COLUMN subjects TEXT[],
ADD COLUMN created TIMESTAMP,
ADD COLUMN latest_revision INT;

-- 3. Update each row to populate the new columns from the JSON data
UPDATE public.works
SET
  title = data ->> 'title',
  author_keys = (
    SELECT array_agg(author_elem -> 'author' ->> 'key')
    FROM jsonb_array_elements(data -> 'authors') AS author_elem
  ),
  subjects = (
    SELECT array_agg(subject)
    FROM jsonb_array_elements_text(data -> 'subjects') AS subject
  ),
  created = (data -> 'created' ->> 'value')::TIMESTAMP,
  last_modified = (data -> 'last_modified' ->> 'value')::TIMESTAMP,
  latest_revision = (data ->> 'latest_revision')::INT,
  revision = (data ->> 'revision')::INT
WHERE data IS NOT NULL;

-- 4. Create indexes on the new columns
CREATE INDEX idx_works_title ON public.works (title);
CREATE INDEX idx_works_author_keys ON public.works USING GIN (author_keys);
CREATE INDEX idx_works_subjects ON public.works USING GIN (subjects);
CREATE INDEX idx_works_created ON public.works (created);
CREATE INDEX idx_works_last_modified ON public.works (last_modified);

COMMIT;

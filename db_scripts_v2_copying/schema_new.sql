ALTER TABLE works RENAME TO works_old;
ALTER TABLE editions RENAME TO editions_old;
ALTER TABLE author_works RENAME TO author_works_old;
ALTER TABLE authors RENAME TO authors_old;
ALTER TABLE edition_isbns RENAME TO edition_isbns_old;

CREATE TABLE authors (
    id text PRIMARY KEY,
    name TEXT NOT null
);

CREATE TABLE works (
    id text PRIMARY KEY,
    cover_id TEXT,
    author_id TEXT REFERENCES authors(id) ON DELETE CASCADE
);

CREATE TABLE public.books (
	id text NOT NULL,
	work_id text NULL,
	isbn10 text NULL,
	isbn13 text NOT NULL,
	title text NOT NULL,
	subtitle text NULL,
	description text NULL,
	"language" varchar NULL,
	published_date text NULL,
	page_count int4 NULL,
	title_embedding public.vector NULL,
	description_embedding public.vector NULL,
	CONSTRAINT books_pkey PRIMARY KEY (id),
	CONSTRAINT unique_isbn10_isbn13 UNIQUE (isbn10, isbn13)
);

CREATE TABLE subjects (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    subject_embedding vector(1536)
);

CREATE TABLE book_subjects (
    book_id text REFERENCES books(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, subject_id)
);

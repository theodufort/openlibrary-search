DROP TABLE IF EXISTS book_subjects;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS works;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
    id text PRIMARY KEY,
    name TEXT NOT null
);

CREATE TABLE works (
    id text PRIMARY KEY,
    cover_id TEXT,
    author_id TEXT REFERENCES authors(id) ON DELETE CASCADE
);

CREATE TABLE books (
    id text PRIMARY KEY,
    work_id text REFERENCES works(id) ON DELETE cascade,
    isbn10 VARCHAR(10) UNIQUE,
    isbn13 VARCHAR(13) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT,
    description TEXT,
    language VARCHAR,
    published_date DATE,
    page_count INT,
    title_embedding vector(1536),
    description_embedding vector(1536)
);

CREATE TABLE subjects (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    subject_embedding vector(1536)
);

CREATE TABLE book_subjects (
    book_id text REFERENCES books(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES subjects(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, subject_id)
);

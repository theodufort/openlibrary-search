-- Load authors data
COPY authors(id, name)
FROM 'example_processed_data_authors.csv'
WITH (FORMAT csv, DELIMITER ' ');

-- Load works data 
COPY works(id, author_id)
FROM 'example_processed_data_works.csv'
WITH (FORMAT csv, DELIMITER ' ');

-- Load books/editions data
COPY books(id, isbn13, title, published_date)
FROM 'example_processed_data_editions.csv'
WITH (FORMAT csv, DELIMITER ' ');

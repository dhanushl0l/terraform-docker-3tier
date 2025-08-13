CREATE TABLE example (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    email TEXT NOT NULL
);

INSERT INTO example (name) VALUES ('Hello from init.sql!');

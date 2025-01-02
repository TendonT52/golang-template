-- migrate:up
CREATE TABLE test (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

-- migrate:down
DROP TABLE test;


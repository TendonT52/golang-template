-- migrate:up
CREATE TABLE customers (
    id crockford32 PRIMARY KEY DEFAULT generate_id(),
    event_id BIGINT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    status TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

-- migrate:down
DROP TABLE IF EXISTS customers;

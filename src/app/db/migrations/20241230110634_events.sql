-- migrate:up
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,

    -- The type/category of the aggregate (entity)
    -- Examples: 'USER', 'CUSTOMER', 'PRODUCT', 'LOAN'
    aggregate_type TEXT NOT NULL,

    -- The specific instance ID of the aggregate
    -- The ID of the specific entity instance
    -- Example: "X7MN9KH2" (Crockford Base32 ID)
    aggregate_id crockford32 NOT NULL,

    -- The type of event that occurred
    -- Examples: 'USER_CREATE', 'PRODUCT_UPDATE', 'LOAN_DISBURSE'
    event_type TEXT NOT NULL,

    -- The actual event data
    -- Stores the event details in JSON format
    payload JSONB NOT NULL,

    -- Additional contextual information
    -- Optional metadata about the event
    -- Example: {"ip": "192.168.1.1", "user_agent": "Mozilla/5.0"}
    metadata JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS events;


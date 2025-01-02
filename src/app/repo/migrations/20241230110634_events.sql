-- migrate:up
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    aggregate_type VARCHAR(255) NOT NULL, -- users, customer, supplier
    aggregate_id UUID NOT NULL, -- user_id
    event_type VARCHAR(255) NOT NULL, -- create_user, update_user, update_balance
    payload JSONB NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
);

notify

CREATE INDEX idx_events_aggregate ON events(aggregate_type, event_type, entity_id);

CREATE OR REPLACE FUNCTION check_version()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM aggregates 
        WHERE aggregate_id = NEW.aggregate_id 
        AND id >= NEW.id
    ) THEN
        RAISE EXCEPTION 'Concurrency conflict detected';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_version_order
BEFORE INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION check_version();


-- Create a trigger function for notifications
CREATE OR REPLACE FUNCTION notify_event()
RETURNS TRIGGER AS $$
BEGIN
    -- Notify with channel 'events' and payload containing the new event data
    -- You can customize the payload format based on your needs
    PERFORM pg_notify(
        'events',  -- channel name
        json_build_object(
            'id', NEW.version,
            'event_type', NEW.event_type,
            'event_data', NEW.event_data
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER event_notify_trigger
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION notify_event();


-- migrate:down
DROP TABLE IF EXISTS events;


event_id, aggregate_type, event_type,   payload
1        LIMIT local
1        
2       


READ aggregate
isolated readcommit

UPDATE aggregate
isolated readcommit

APPEND EVENT
isolated serializable


begin
    if not check_version
        rollback

    INSERT INTO events (aggregate_type, aggregate_id, event_type, payload)
    INSERT INTO events (aggregate_type, aggregate_id, event_type, payload)
commit


    JSONB -> BINARY
select payload from events;

event sourcing 100%

cqrs 50%

event driven

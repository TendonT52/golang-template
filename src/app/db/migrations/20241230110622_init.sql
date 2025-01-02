-- migrate:up
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Validate Crockford's Base32 format
CREATE OR REPLACE FUNCTION is_valid_crockford32(text) RETURNS boolean AS $$
BEGIN
    -- Check if input is exactly 8 characters and matches Crockford's Base32 pattern
    RETURN $1 ~ '^[0123456789ABCDEFGHJKMNPQRSTVWXYZ]{8}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- Create the domain with validation
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'crockford32') THEN
        CREATE DOMAIN crockford32 AS text
            CONSTRAINT crockford32_length CHECK (length(VALUE) = 8)
            CONSTRAINT crockford32_format CHECK (is_valid_crockford32(VALUE));
    END IF;

    -- Maximum value: 9,999,999,999,999,999,999,999.99999999
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'money_amount') THEN
        CREATE DOMAIN money_amount AS DECIMAL(30,8)
            CONSTRAINT money_amount_positive CHECK (VALUE >= 0);  -- Optional: ensure positive amounts
    END IF;

    --	Maximum: 9999.9999
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'interest_rate') THEN
        CREATE DOMAIN interest_rate AS DECIMAL(8,4)
            CONSTRAINT interest_rate_positive CHECK (VALUE >= 0)
            CONSTRAINT interest_rate_max CHECK (VALUE <= 100);  -- Assuming rate is in percentage
    END IF;
END
$$;

-- human readable ID generator
CREATE OR REPLACE FUNCTION generate_id() RETURNS crockford32 AS $$
DECLARE
    -- Crockford's Base32 alphabet (excluding I, L, O, U)
    encoding text := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    result text := '';
    i int;
BEGIN
    -- Generate 8 random characters
    FOR i IN 1..8 LOOP
        -- random() * 32 gives us a number between 0 and 31
        result := result || substr(encoding, 1 + (random() * 31)::integer, 1);
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- migrate:down
DROP FUNCTION IF EXISTS is_valid_crockford32(text);
DROP DOMAIN IF EXISTS crockford32;
DROP DOMAIN IF EXISTS interest_rate;
DROP DOMAIN IF EXISTS money_amount;
DROP FUNCTION IF EXISTS generate_id();
DROP EXTENSION IF EXISTS pgcrypto;


-- migrate:up
CREATE TABLE loan_products (
    id crockford32 PRIMARY KEY DEFAULT generate_id(),
    event_id BIGINT NOT NULL,

    -- Product name (e.g., "Personal Loan", "Home Loan")
    name TEXT NOT NULL, 

    -- Annual interest rate
    interest_rate interest_rate NOT NULL,

    -- Array of available loan terms in months
    -- Example: ARRAY[12, 24, 36, 48, 60]
    -- Means customers can choose 1-5 year terms
    term_months INT[] NOT NULL,

    -- Minimum loan amount allowed (e.g., 10000.00)
    -- Prevents too small loans
    min_amount money_amount NOT NULL,

    -- Maximum loan amount allowed (e.g., 1000000.00)
    -- Limits exposure per loan
    max_amount money_amount NOT NULL,

    -- Late payment penalty rate (e.g., 2.00 means 2%)
    -- Applied when payments are late
    late_fee_rate interest_rate NOT NULL,

    -- One-time fee rate for loan processing (e.g., 1.00 means 1%)
    -- Charged when loan is disbursed
    processing_fee_rate interest_rate NOT NULL,

    -- Product status (ACTIVE/INACTIVE)
    status TEXT NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL

);

-- migrate:down
DROP TABLE IF EXISTS products;


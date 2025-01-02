-- migrate:up
CREATE TABLE loan_accounts (
    id crockford32 PRIMARY KEY DEFAULT generate_id(),
    event_id BIGINT NOT NULL,

    customer_id TEXT NOT NULL REFERENCES customers(id),
    product_id TEXT NOT NULL REFERENCES loan_products(id),
    
    principal_amount money_amount NOT NULL,
    interest_rate interest_rate NOT NULL,
    term_months INT NOT NULL,
    
    disbursed_amount money_amount NOT NULL,
    outstanding_principal money_amount NOT NULL,
    outstanding_interest money_amount NOT NULL,
    outstanding_fees money_amount NOT NULL,
    
    next_payment_date DATE,
    last_payment_date DATE,
    
    status TEXT NOT NULL,
    
    approved_at TIMESTAMPTZ,
    disbursed_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS loan_accounts;

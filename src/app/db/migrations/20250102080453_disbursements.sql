-- migrate:up
CREATE TABLE disbursements (
    id crockford32 PRIMARY KEY DEFAULT generate_id(),
    loan_account_id TEXT NOT NULL REFERENCES loan_accounts(id),
    amount money_amount NOT NULL,
    disbursement_date DATE NOT NULL,
    disbursed_at TIMESTAMPTZ,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    transaction_reference TEXT,

    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

-- migrate:down
DROP TABLE IF EXISTS disbursements;


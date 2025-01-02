-- migrate:up
CREATE TABLE repayments (
    id crockford32 PRIMARY KEY DEFAULT generate_id(),
    loan_account_id crockford32 NOT NULL REFERENCES loan_accounts(id),
    amount money_amount NOT NULL,
    principal_amount money_amount NOT NULL,
    interest_amount money_amount NOT NULL,
    fees_amount money_amount NOT NULL,

    payment_date DATE NOT NULL,
    payment_method TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

-- migrate:down
DROP TABLE IF EXISTS repayments;

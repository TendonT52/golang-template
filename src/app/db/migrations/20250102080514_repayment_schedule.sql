-- migrate:up
CREATE TABLE repayment_schedule_view (
    loan_account_id crockford32 NOT NULL REFERENCES loan_accounts(id),
    installment_number INT NOT NULL,
    PRIMARY KEY (loan_account_id, installment_number),

    due_date DATE NOT NULL,
    principal_due money_amount NOT NULL,
    interest_due money_amount NOT NULL,
    fees_due money_amount NOT NULL,
    
    repayment_id crockford32  REFERENCES repayments(id)
);

-- migrate:down
DROP TABLE IF EXISTS repayment_schedule_view;


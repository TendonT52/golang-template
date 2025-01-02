SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: is_valid_crockford32(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_valid_crockford32(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
BEGIN
    -- Check if input is exactly 8 characters and matches Crockford's Base32 pattern
    RETURN $1 ~ '^[0123456789ABCDEFGHJKMNPQRSTVWXYZ]{8}$';
END;
$_$;


--
-- Name: crockford32; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.crockford32 AS text
	CONSTRAINT crockford32_format CHECK (public.is_valid_crockford32(VALUE))
	CONSTRAINT crockford32_length CHECK ((length(VALUE) = 8));


--
-- Name: interest_rate; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.interest_rate AS numeric(8,4);


--
-- Name: money_amount; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.money_amount AS numeric(30,8);


--
-- Name: generate_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_id() RETURNS public.crockford32
    LANGUAGE plpgsql
    AS $$
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
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id public.crockford32 DEFAULT public.generate_id() NOT NULL,
    event_id bigint NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    phone text NOT NULL,
    email text,
    status text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: disbursements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disbursements (
    id public.crockford32 DEFAULT public.generate_id() NOT NULL,
    loan_account_id text NOT NULL,
    amount public.money_amount NOT NULL,
    disbursement_date date NOT NULL,
    disbursed_at timestamp with time zone,
    status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    transaction_reference text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id bigint NOT NULL,
    aggregate_type text NOT NULL,
    aggregate_id public.crockford32 NOT NULL,
    event_type text NOT NULL,
    payload jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: loan_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loan_accounts (
    id public.crockford32 DEFAULT public.generate_id() NOT NULL,
    event_id bigint NOT NULL,
    customer_id text NOT NULL,
    product_id text NOT NULL,
    principal_amount public.money_amount NOT NULL,
    interest_rate public.interest_rate NOT NULL,
    term_months integer NOT NULL,
    disbursed_amount public.money_amount NOT NULL,
    outstanding_principal public.money_amount NOT NULL,
    outstanding_interest public.money_amount NOT NULL,
    outstanding_fees public.money_amount NOT NULL,
    next_payment_date date,
    last_payment_date date,
    status text NOT NULL,
    approved_at timestamp with time zone,
    disbursed_at timestamp with time zone,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: loan_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loan_products (
    id public.crockford32 DEFAULT public.generate_id() NOT NULL,
    event_id bigint NOT NULL,
    name text NOT NULL,
    interest_rate public.interest_rate NOT NULL,
    term_months integer[] NOT NULL,
    min_amount public.money_amount NOT NULL,
    max_amount public.money_amount NOT NULL,
    late_fee_rate public.interest_rate NOT NULL,
    processing_fee_rate public.interest_rate NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: repayment_schedule_view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repayment_schedule_view (
    loan_account_id public.crockford32 NOT NULL,
    installment_number integer NOT NULL,
    due_date date NOT NULL,
    principal_due public.money_amount NOT NULL,
    interest_due public.money_amount NOT NULL,
    fees_due public.money_amount NOT NULL,
    repayment_id public.crockford32
);


--
-- Name: repayments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repayments (
    id public.crockford32 DEFAULT public.generate_id() NOT NULL,
    loan_account_id public.crockford32 NOT NULL,
    amount public.money_amount NOT NULL,
    principal_amount public.money_amount NOT NULL,
    interest_amount public.money_amount NOT NULL,
    fees_amount public.money_amount NOT NULL,
    payment_date date NOT NULL,
    payment_method text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(128) NOT NULL
);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: disbursements disbursements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disbursements
    ADD CONSTRAINT disbursements_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: loan_accounts loan_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loan_accounts
    ADD CONSTRAINT loan_accounts_pkey PRIMARY KEY (id);


--
-- Name: loan_products loan_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loan_products
    ADD CONSTRAINT loan_products_pkey PRIMARY KEY (id);


--
-- Name: repayment_schedule_view repayment_schedule_view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repayment_schedule_view
    ADD CONSTRAINT repayment_schedule_view_pkey PRIMARY KEY (loan_account_id, installment_number);


--
-- Name: repayments repayments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repayments
    ADD CONSTRAINT repayments_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: disbursements disbursements_loan_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disbursements
    ADD CONSTRAINT disbursements_loan_account_id_fkey FOREIGN KEY (loan_account_id) REFERENCES public.loan_accounts(id);


--
-- Name: loan_accounts loan_accounts_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loan_accounts
    ADD CONSTRAINT loan_accounts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: loan_accounts loan_accounts_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loan_accounts
    ADD CONSTRAINT loan_accounts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.loan_products(id);


--
-- Name: repayment_schedule_view repayment_schedule_view_loan_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repayment_schedule_view
    ADD CONSTRAINT repayment_schedule_view_loan_account_id_fkey FOREIGN KEY (loan_account_id) REFERENCES public.loan_accounts(id);


--
-- Name: repayment_schedule_view repayment_schedule_view_repayment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repayment_schedule_view
    ADD CONSTRAINT repayment_schedule_view_repayment_id_fkey FOREIGN KEY (repayment_id) REFERENCES public.repayments(id);


--
-- Name: repayments repayments_loan_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repayments
    ADD CONSTRAINT repayments_loan_account_id_fkey FOREIGN KEY (loan_account_id) REFERENCES public.loan_accounts(id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20241230110622'),
    ('20241230110634'),
    ('20241230141316'),
    ('20250102080420'),
    ('20250102080431'),
    ('20250102080453'),
    ('20250102080510'),
    ('20250102080514');

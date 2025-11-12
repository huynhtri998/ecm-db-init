-- Enable CITEXT for case-insensitive email comparison
CREATE EXTENSION IF NOT EXISTS citext;

-- Main customer table
CREATE TABLE IF NOT EXISTS customers (
                                         id          BIGSERIAL PRIMARY KEY,
                                         firstname   TEXT NOT NULL,
                                         lastname    TEXT NOT NULL,
                                         email       CITEXT NOT NULL UNIQUE,
                                         created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
    );

-- Each customer can have one address
CREATE TABLE IF NOT EXISTS addresses (
                                         id            BIGSERIAL PRIMARY KEY,
                                         street        TEXT NOT NULL,
                                         house_number  TEXT NOT NULL,
                                         zip_code      TEXT NOT NULL,
                                         customer_id   BIGINT UNIQUE REFERENCES customers(id) ON DELETE CASCADE
    );

-- Indexes for efficient lookups
CREATE INDEX IF NOT EXISTS idx_customers_lastname        ON customers(lastname);
CREATE INDEX IF NOT EXISTS idx_customers_created_at      ON customers(created_at);
CREATE INDEX IF NOT EXISTS idx_addresses_zip             ON addresses(zip_code);
CREATE INDEX IF NOT EXISTS idx_addresses_customer_zip    ON addresses(customer_id, zip_code);

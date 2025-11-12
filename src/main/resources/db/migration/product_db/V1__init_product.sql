-- Enable CITEXT for case-insensitive category name
CREATE EXTENSION IF NOT EXISTS citext;

-- Product category table
CREATE TABLE IF NOT EXISTS categories (
                                          id          BIGSERIAL PRIMARY KEY,
                                          name        CITEXT NOT NULL UNIQUE,
                                          description TEXT
);

-- Product table
CREATE TABLE IF NOT EXISTS products (
                                        id                 BIGSERIAL PRIMARY KEY,
                                        name               TEXT NOT NULL,
                                        description        TEXT,
                                        available_quantity INTEGER NOT NULL DEFAULT 0,
                                        price              NUMERIC(12,2) NOT NULL,
    category_id        BIGINT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
    );

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_category          ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_price             ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_created_at        ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_products_category_price    ON products(category_id, price);
CREATE INDEX IF NOT EXISTS idx_products_name              ON products(name);

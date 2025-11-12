-- Create payment status type if not exists
DO $$
BEGIN
CREATE TYPE payment_status AS ENUM ('PENDING','PAID','FAILED','REFUNDED','CANCELLED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Payments table partitioned by status (LIST)
CREATE TABLE IF NOT EXISTS payments (
                                        id          BIGSERIAL,
                                        reference   TEXT NOT NULL,
                                        order_id    BIGINT NOT NULL,
                                        amount      NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    status      payment_status NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT payments_pk PRIMARY KEY (id, status),
    CONSTRAINT payments_reference_unique UNIQUE (reference, status)
    ) PARTITION BY LIST (status);

-- Create partitions by status
CREATE TABLE IF NOT EXISTS payments_pending   PARTITION OF payments FOR VALUES IN ('PENDING');
CREATE TABLE IF NOT EXISTS payments_paid      PARTITION OF payments FOR VALUES IN ('PAID');
CREATE TABLE IF NOT EXISTS payments_failed    PARTITION OF payments FOR VALUES IN ('FAILED');
CREATE TABLE IF NOT EXISTS payments_refunded  PARTITION OF payments FOR VALUES IN ('REFUNDED');
CREATE TABLE IF NOT EXISTS payments_cancelled PARTITION OF payments FOR VALUES IN ('CANCELLED');

-- Indexes for query optimization
CREATE INDEX IF NOT EXISTS idx_payments_status        ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_created       ON payments(created_at);
CREATE INDEX IF NOT EXISTS idx_payments_order         ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_order_created ON payments(order_id, created_at);

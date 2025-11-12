-- Orders table partitioned by order_date
CREATE TABLE IF NOT EXISTS orders (
                                      id          BIGSERIAL,
                                      order_date  TIMESTAMPTZ NOT NULL,
                                      reference   TEXT NOT NULL,
                                      customer_id BIGINT NOT NULL,
                                      created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT orders_pk PRIMARY KEY (id, order_date),
    CONSTRAINT orders_reference_unique UNIQUE (reference, order_date)
    ) PARTITION BY RANGE (order_date);

-- Create partitions for each month of current year
DO $$
DECLARE
m INT;
    y INT := EXTRACT(YEAR FROM now())::INT;
    start_date DATE;
    end_date   DATE;
    part_name  TEXT;
BEGIN
FOR m IN 1..12 LOOP
        start_date := make_date(y, m, 1);
        end_date   := (start_date + INTERVAL '1 month')::date;
        part_name  := format('orders_%s_%s', y, lpad(m::text,2,'0'));
EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF orders
         FOR VALUES FROM (%L) TO (%L);',
        part_name, start_date, end_date
        );
END LOOP;
EXECUTE 'CREATE TABLE IF NOT EXISTS orders_default PARTITION OF orders DEFAULT;';
END $$;

-- Indexes for search and reporting
CREATE INDEX IF NOT EXISTS idx_orders_order_date           ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_customer             ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_order_date  ON orders(customer_id, order_date);

-- Order lines table partitioned by created_at
CREATE TABLE IF NOT EXISTS order_lines (
                                           id          BIGSERIAL,
                                           order_id    BIGINT NOT NULL,
                                           product_id  BIGINT NOT NULL,
                                           quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(12,2) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT order_lines_pk PRIMARY KEY (id, created_at)
    ) PARTITION BY RANGE (created_at);

-- Monthly partitions for order_lines
DO $$
DECLARE
m INT;
    y INT := EXTRACT(YEAR FROM now())::INT;
    start_date DATE;
    end_date   DATE;
    part_name  TEXT;
BEGIN
FOR m IN 1..12 LOOP
        start_date := make_date(y, m, 1);
        end_date   := (start_date + INTERVAL '1 month')::date;
        part_name  := format('order_lines_%s_%s', y, lpad(m::text,2,'0'));
EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF order_lines
         FOR VALUES FROM (%L) TO (%L);',
        part_name, start_date, end_date
        );
END LOOP;
EXECUTE 'CREATE TABLE IF NOT EXISTS order_lines_default PARTITION OF order_lines DEFAULT;';
END $$;

-- Indexes for joins and reporting
CREATE INDEX IF NOT EXISTS idx_order_lines_created         ON order_lines(created_at);
CREATE INDEX IF NOT EXISTS idx_order_lines_order           ON order_lines(order_id);
CREATE INDEX IF NOT EXISTS idx_order_lines_product         ON order_lines(product_id);
CREATE INDEX IF NOT EXISTS idx_order_lines_order_product   ON order_lines(order_id, product_id);

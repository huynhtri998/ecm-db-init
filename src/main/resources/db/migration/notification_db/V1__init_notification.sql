-- Notification table partitioned by created_at (monthly)
CREATE TABLE IF NOT EXISTS notifications (
                                             id          BIGSERIAL,
                                             sender      TEXT NOT NULL,
                                             recipient   TEXT NOT NULL,
                                             content     TEXT NOT NULL,
                                             created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    order_id    BIGINT,
    payment_id  BIGINT,
    CONSTRAINT notifications_pk PRIMARY KEY (id, created_at)
    ) PARTITION BY RANGE (created_at);

-- Create monthly partitions dynamically
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
        part_name  := format('notifications_%s_%s', y, lpad(m::text,2,'0'));
EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF notifications
         FOR VALUES FROM (%L) TO (%L);',
        part_name, start_date, end_date
        );
END LOOP;
EXECUTE 'CREATE TABLE IF NOT EXISTS notifications_default PARTITION OF notifications DEFAULT;';
END $$;

-- Useful indexes
CREATE INDEX IF NOT EXISTS idx_notifications_created        ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient      ON notifications(recipient);
CREATE INDEX IF NOT EXISTS idx_notifications_order          ON notifications(order_id);
CREATE INDEX IF NOT EXISTS idx_notifications_payment        ON notifications(payment_id);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_created ON notifications(recipient, created_at);

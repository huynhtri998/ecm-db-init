BEGIN;

WITH cfg AS (
    SELECT 90 AS total_orders
),
     orders_synth AS (
         SELECT
             oid AS order_id,
             make_timestamp(
                     EXTRACT(YEAR FROM now())::int,
                     1 + ((oid) % 12),
      1 + ((oid * 3) % 28),
      10 + ((oid) % 8),
      (oid * 7) % 60,
      0
    ) AT TIME ZONE 'UTC' AS created_at
         FROM cfg, LATERAL generate_series(1, cfg.total_orders) AS t(oid)
    ),

    amounts AS (
SELECT
    o.order_id,
    (20 + (o.order_id % 200) + ((o.order_id * 13) % 50))::numeric(14,2) AS amount,
    o.created_at
FROM orders_synth o
    ),
    with_status AS (
SELECT
    a.order_id,
    a.amount,
    a.created_at,
    CASE a.order_id % 100
    WHEN 0 THEN 'REFUNDED'
    WHEN 1 THEN 'FAILED'
    WHEN 2 THEN 'CANCELLED'
    ELSE CASE WHEN a.order_id % 10 IN (3,7) THEN 'PENDING' ELSE 'PAID' END
    END::payment_status AS status
FROM amounts a
    ),
    rows AS (
SELECT
    format('PMT-%s%s-%s',
    to_char(created_at,'YYYY'),
    to_char(created_at,'MM'),
    lpad(order_id::text,6,'0')) AS reference,
    order_id,
    amount,
    status,
    created_at + interval '15 minutes' AS payment_time
FROM with_status
    )
INSERT INTO payments (reference, order_id, amount, status, created_at)
SELECT reference, order_id, amount, status, payment_time
FROM rows
    ON CONFLICT DO NOTHING;

COMMIT;

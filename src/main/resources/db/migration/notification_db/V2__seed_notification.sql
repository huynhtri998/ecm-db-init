BEGIN;

WITH cfg AS (
    SELECT 30 AS total_customers, 90 AS total_orders
),
     orders_synth AS (
         SELECT
             oid AS order_id,
             1 + ((oid - 1) % (SELECT total_customers FROM cfg)) AS customer_id,
    make_timestamp(
    EXTRACT(YEAR FROM now())::int,
    1 + (oid % 12),
    1 + ((oid * 3) % 28),
    10 + (oid % 8),
    (oid * 7) % 60,
    0
    ) AT TIME ZONE 'UTC' AS order_date,
    format(
    'ORD-%s-%s-%s',
    to_char(now(),'YYYY'),
    lpad((1 + (oid % 12))::text,2,'0'),
    lpad((oid*101)::text,6,'0')
    ) AS reference
FROM cfg, LATERAL generate_series(1, (SELECT total_orders FROM cfg)) AS t(oid)
    ),

    order_notif AS (
SELECT
    'system@shop.local' AS sender,
    format('user+%s@example.com', customer_id) AS recipient,
    format('Your order %s has been placed.', reference) AS content,
    order_date AS created_at,
    order_id,
    NULL::bigint AS payment_id
FROM orders_synth
    ),

    payments_synth AS (
SELECT
    o.order_id,
    o.order_date,
    (20 + (o.order_id % 200) + ((o.order_id * 13) % 50))::numeric(14,2) AS amount,
    CASE o.order_id % 100
    WHEN 0 THEN 'REFUNDED'
    WHEN 1 THEN 'FAILED'
    WHEN 2 THEN 'CANCELLED'
    ELSE CASE WHEN o.order_id % 10 IN (3,7) THEN 'PENDING' ELSE 'PAID' END
    END AS status,
    format(
    'PMT-%s%s-%s',
    to_char(o.order_date,'YYYY'),
    to_char(o.order_date,'MM'),
    lpad(o.order_id::text,6,'0')
    ) AS reference,
    o.customer_id
FROM orders_synth o
    ),
    payment_notif AS (
SELECT
    'billing@shop.local' AS sender,
    format('user+%s@example.com', customer_id) AS recipient,
    CASE status
    WHEN 'PAID' THEN format(
    'Payment %s received for order #%s. Amount: %s',
    reference, order_id, to_char(amount, 'FM999999990.00')
    )
    WHEN 'PENDING' THEN format(
    'Payment %s is pending for order #%s. Amount: %s',
    reference, order_id, to_char(amount, 'FM999999990.00')
    )
    WHEN 'FAILED' THEN format('Payment %s failed for order #%s. Please retry.', reference, order_id)
    WHEN 'REFUNDED' THEN format('Payment %s was refunded for order #%s.', reference, order_id)
    WHEN 'CANCELLED' THEN format('Payment %s was cancelled for order #%s.', reference, order_id)
    END AS content,
    order_date + interval '15 minutes' AS created_at,
    order_id,
    NULL::bigint AS payment_id
FROM payments_synth
    )
INSERT INTO notifications (sender, recipient, content, created_at, order_id, payment_id)
SELECT sender, recipient, content, created_at, order_id, payment_id FROM order_notif
UNION ALL
SELECT sender, recipient, content, created_at, order_id, payment_id FROM payment_notif
    ON CONFLICT DO NOTHING;

COMMIT;

BEGIN;

WITH customers AS (
    SELECT generate_series(1, 30) AS customer_id
),
     per_cust AS (
         SELECT customer_id, (1 + (customer_id % 3))::int AS order_count
         FROM customers
     ),

     expanded AS (
         SELECT customer_id, generate_series(1, order_count) AS seq
         FROM per_cust
     ),

     params AS (
         SELECT EXTRACT(YEAR FROM now())::int AS y
     ),
     order_rows AS (
         SELECT
             e.customer_id,
             make_timestamp(
                     (SELECT y FROM params),
                     1 + ((e.customer_id + e.seq) % 12),
      1 + ((e.customer_id * e.seq) % 28),
      10 + ((e.customer_id + e.seq) % 8),
      (e.customer_id * e.seq) % 60,
      0
    ) AT TIME ZONE 'UTC' AS order_date,
             format(
                     'ORD-%s-%s-%s',
                     (SELECT y FROM params),
                     lpad((1 + ((e.customer_id + e.seq) % 12))::text,2,'0'),
                     lpad((e.customer_id*100 + e.seq)::text,6,'0')
             ) AS reference
         FROM expanded e
     ),

     ins AS (
INSERT INTO orders (order_date, reference, customer_id, created_at)
SELECT order_date, reference, customer_id, order_date + interval '5 minutes'
FROM order_rows
ON CONFLICT DO NOTHING
    RETURNING id, customer_id, order_date, reference
    ),

    seeded AS (
SELECT id, customer_id, order_date, reference FROM ins
UNION ALL
SELECT o.id, o.customer_id, o.order_date, o.reference
FROM orders o
    JOIN order_rows r ON r.reference = o.reference
    ),

    choices AS (
SELECT s.id AS order_id, s.order_date, 1 + (s.id % 5) AS lines
FROM seeded s
    ),
    expanded_lines AS (
SELECT c.order_id, c.order_date, generate_series(1, c.lines) AS rn
FROM choices c
    ),
    picked AS (
SELECT
    e.order_id,
    e.order_date,
    ((e.order_id + e.rn) % 20) + 1 AS product_id,
    1 + ((e.order_id + e.rn) % 3) AS qty,
    (10 + ((e.order_id + e.rn) % 120))::numeric(12,2) AS unit_price
FROM expanded_lines e
    )
INSERT INTO order_lines (order_id, product_id, quantity, unit_price, created_at)
SELECT order_id, product_id, qty, unit_price, order_date
FROM picked
    ON CONFLICT DO NOTHING;

COMMIT;

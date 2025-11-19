BEGIN;

WITH first_names AS (
    SELECT unnest(ARRAY[
                      'Minh','An','Trang','Linh','Huy','Trung','Khanh','Quang','Phuc','Nhi',
                  'Thanh','Thao','Duc','Ngoc','Tuan','Hoa','Binh','Nam','Thu','Lan',
                  'Hoang','Phuong','Yen','Son','Hai','Hanh','Khoa','Ly','Tin','My'
                      ]) AS fn
),
     last_names AS (
         SELECT unnest(ARRAY[
                           'Nguyen','Tran','Le','Pham','Hoang','Phan','Vu','Vo','Dang','Do',
                       'Bui','Ho','Ngo','Duong','Ly','Truong','Mai','Dinh','Cao','Dao',
                       'Luong','Huynh','Trinh','Quach','Dam','Vuong','La','Han','Diep','Hua'
                           ]) AS ln
     ),
     picked AS (
         SELECT row_number() over () AS n, fn, ln
         FROM (
                  SELECT fn, ln
                  FROM first_names
                           CROSS JOIN last_names
                  ORDER BY fn, ln
              ) t
    LIMIT 30
    )
INSERT INTO customers (firstname, lastname, email, created_at)
SELECT initcap(fn),
       initcap(ln),
       (lower(fn) || '.' || lower(ln) || n::text || '@example.com')::citext,
    now() - (n * interval '1 day')
FROM picked
    ON CONFLICT (email) DO NOTHING;

INSERT INTO addresses (street, house_number, zip_code, customer_id)
SELECT
    CASE g.addr_idx
        WHEN 1 THEN 'Nguyen Trai Street'
        WHEN 2 THEN 'Le Loi Street'
        ELSE       'Tran Hung Dao Street'
        END AS street,
    (100 + c.id + (g.addr_idx - 1) * 10)::text AS house_number,
    lpad((70000 + ((c.id + g.addr_idx) % 500))::text, 5, '0') AS zip_code,
    c.id AS customer_id
FROM customers c
         CROSS JOIN generate_series(1, 3) AS g(addr_idx);  -- 3 địa chỉ mỗi customer

COMMIT;

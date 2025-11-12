BEGIN;

-- Categories
INSERT INTO categories (name, description) VALUES
                                               ('Electronics','Phones, laptops, audio, accessories'),
                                               ('Home & Kitchen','Cookware, appliances, home goods'),
                                               ('Books','Fiction, non-fiction, tech'),
                                               ('Fashion','Clothing and accessories'),
                                               ('Sports','Outdoor and fitness gear'),
                                               ('Beauty','Personal care and cosmetics'),
                                               ('Toys','Kids & hobby items'),
                                               ('Groceries','Daily essentials & packaged food')
    ON CONFLICT (name) DO NOTHING;

WITH c AS (SELECT id, name FROM categories)
INSERT INTO products (name, description, available_quantity, price, category_id, created_at)
VALUES
  ('iPhone 15','Apple smartphone 128GB',50, 999.00,(SELECT id FROM c WHERE name='Electronics'), now()-interval '60 days'),
  ('Galaxy S24','Samsung flagship 256GB',40, 899.00,(SELECT id FROM c WHERE name='Electronics'), now()-interval '58 days'),
  ('Noise-cancelling Headphones','Over-ear ANC',120,199.00,(SELECT id FROM c WHERE name='Electronics'), now()-interval '55 days'),
  ('OLED TV 55"','4K HDR Smart TV',20,1199.00,(SELECT id FROM c WHERE name='Electronics'), now()-interval '65 days'),
  ('Mechanical Keyboard','Hot-swap, tactile',100,119.00,(SELECT id FROM c WHERE name='Electronics'), now()-interval '52 days'),
  ('Air Fryer 5L','Healthy cooking at home',80,129.00,(SELECT id FROM c WHERE name='Home & Kitchen'), now()-interval '50 days'),
  ('Non-stick Pan 28cm','Aluminum, PFOA-free',160,24.00,(SELECT id FROM c WHERE name='Home & Kitchen'), now()-interval '44 days'),
  ('Clean Architecture','Robert C. Martin',60,32.00,(SELECT id FROM c WHERE name='Books'), now()-interval '40 days'),
  ('Java Concurrency in Practice','Brian Goetz',40,45.00,(SELECT id FROM c WHERE name='Books'), now()-interval '38 days'),
  ('Data Intensive Applications','Martin Kleppmann',55,49.00,(SELECT id FROM c WHERE name='Books'), now()-interval '36 days'),
  ('Slim Fit T-Shirt','Cotton basic tee',300,12.00,(SELECT id FROM c WHERE name='Fashion'), now()-interval '35 days'),
  ('Hoodie','Fleece-lined',140,35.00,(SELECT id FROM c WHERE name='Fashion'), now()-interval '32 days'),
  ('Running Shoes','Lightweight trainers',150,79.00,(SELECT id FROM c WHERE name='Sports'), now()-interval '34 days'),
  ('Yoga Mat','Non-slip 6mm',180,28.00,(SELECT id FROM c WHERE name='Sports'), now()-interval '33 days'),
  ('Vitamin C Serum','30ml brightening',140,25.00,(SELECT id FROM c WHERE name='Beauty'), now()-interval '30 days'),
  ('Sunscreen SPF50','Water-resistant 50ml',130,18.00,(SELECT id FROM c WHERE name='Beauty'), now()-interval '26 days'),
  ('Building Blocks Set','Creative bricks 500pcs',90,35.00,(SELECT id FROM c WHERE name='Toys'), now()-interval '27 days'),
  ('Gourmet Coffee Beans','Arabica 1kg',110,22.00,(SELECT id FROM c WHERE name='Groceries'), now()-interval '25 days')
ON CONFLICT DO NOTHING;

COMMIT;

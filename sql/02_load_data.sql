-- ============================================================
-- 02_load_data.sql
-- Loads Olist CSVs into the schema created by 01_schema.sql
-- Run this connected to olist_analytics, from psql (uses \copy,
-- which reads from YOUR local machine, not the DB server).
--
-- Adjust the file paths below to wherever you extracted the CSVs.
-- Load order matters: parents before children (FK dependencies).
-- ============================================================

-- 1. Lookup table (no dependencies)
\copy product_category_translation FROM 'data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 2. Geolocation (no dependencies)
\copy geolocation FROM 'data/raw/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 3. Customers (no dependencies)
\copy customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 4. Sellers (no dependencies)
\copy sellers FROM 'data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 5. Products (depends on product_category_translation)
\copy products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 6. Orders (depends on customers)
\copy orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 7. Order items (depends on orders, products, sellers)
\copy order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 8. Order payments (depends on orders)
\copy order_payments FROM 'data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 9. Order reviews (depends on orders)
\copy order_reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- ============================================================
-- NOTES / TROUBLESHOOTING
-- ============================================================
-- 1. Run this script with:  \i 'C:/path/to/02_load_data.sql'
--    from inside psql, while connected to olist_analytics.
--    OR run each \copy line individually if one file fails.
--
-- 2. If you get "duplicate key value violates unique constraint"
--    on products (some product_ids repeat with different category
--    labels in the raw data), you may need to de-duplicate first:
--    load into a staging table, then INSERT ... SELECT DISTINCT.
--
-- 3. If a table already has data and you re-run this, you'll get
--    PK violations. Either TRUNCATE the tables first:
--       TRUNCATE customers, sellers, products, orders, order_items,
--                order_payments, order_reviews, geolocation,
--                product_category_translation RESTART IDENTITY CASCADE;
--    or re-run 01_schema.sql (it DROPs and recreates everything).
--
-- 4. Verify the load:
\echo 'Row counts after load:'
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation;
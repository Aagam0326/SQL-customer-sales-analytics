-- ============================================================
-- 02b_fix_load_errors.sql
-- Run this AFTER 02_load_data.sql if you hit:
--   - FK violation on products.product_category_name
--   - duplicate key violation on order_reviews.review_id
-- ============================================================

-- ------------------------------------------------------------
-- FIX 1: Drop the FK constraint on products.product_category_name
-- Reason: Olist's raw products CSV contains a handful of category
-- names (e.g. 'pc_gamer') that don't appear in the translation
-- CSV. This is a genuine gap in Olist's own data, not a loading
-- mistake. Queries already LEFT JOIN to the translation table,
-- so this is handled gracefully at query time (shows as NULL/
-- falls back to the raw category name via COALESCE).
-- ------------------------------------------------------------

ALTER TABLE products DROP CONSTRAINT IF EXISTS products_product_category_name_fkey;

-- Re-run the products load (adjust path to your actual location)
\copy products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm) FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- Now order_items will succeed (it depends on products existing)
\copy order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- ------------------------------------------------------------
-- FIX 2: order_reviews duplicate review_id
-- Load into a staging table (no constraints), then insert only
-- the most recent version of each duplicated review.
-- ------------------------------------------------------------

CREATE TEMP TABLE order_reviews_staging (
    review_id                 VARCHAR(50),
    order_id                  VARCHAR(50),
    review_score              INT,
    review_comment_title      VARCHAR(255),
    review_comment_message    TEXT,
    review_creation_date      TIMESTAMP,
    review_answer_timestamp   TIMESTAMP
);

\copy order_reviews_staging FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

INSERT INTO order_reviews
SELECT DISTINCT ON (review_id)
    review_id, order_id, review_score, review_comment_title,
    review_comment_message, review_creation_date, review_answer_timestamp
FROM order_reviews_staging
ORDER BY review_id, review_answer_timestamp DESC
ON CONFLICT (review_id) DO NOTHING;

-- ------------------------------------------------------------
-- Verify everything loaded
-- ------------------------------------------------------------
SELECT 'customers' AS tbl, COUNT(*) FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation;
-- ============================================================
-- 01_schema.sql
-- Schema for Olist Brazilian E-Commerce dataset
-- Run this after: CREATE DATABASE olist_analytics; \c olist_analytics
-- ============================================================

-- Drop tables if re-running (order matters due to FK constraints)
DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS product_category_translation CASCADE;

-- ------------------------------------------------------------
-- Reference / lookup tables first
-- ------------------------------------------------------------

CREATE TABLE product_category_translation (
    product_category_name          VARCHAR(100) PRIMARY KEY,
    product_category_name_english  VARCHAR(100)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix    VARCHAR(10),
    geolocation_lat                DECIMAL(10, 7),
    geolocation_lng                DECIMAL(10, 7),
    geolocation_city               VARCHAR(100),
    geolocation_state              VARCHAR(2)
);
-- No single-column PK here: Kaggle's raw file has multiple lat/lng rows per zip prefix.
CREATE INDEX idx_geo_zip ON geolocation(geolocation_zip_code_prefix);

-- ------------------------------------------------------------
-- Core entity tables
-- ------------------------------------------------------------

CREATE TABLE customers (
    customer_id                 VARCHAR(50) PRIMARY KEY,
    customer_unique_id          VARCHAR(50) NOT NULL,
    customer_zip_code_prefix    VARCHAR(10),
    customer_city                VARCHAR(100),
    customer_state               VARCHAR(2)
);
CREATE INDEX idx_customers_unique ON customers(customer_unique_id);

CREATE TABLE sellers (
    seller_id                 VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix    VARCHAR(10),
    seller_city                VARCHAR(100),
    seller_state                VARCHAR(2)
);

CREATE TABLE products (
    product_id                     VARCHAR(50) PRIMARY KEY,
    product_category_name          VARCHAR(100) REFERENCES product_category_translation(product_category_name),
    product_name_length            INT,
    product_description_length     INT,
    product_photos_qty             INT,
    product_weight_g               INT,
    product_length_cm              INT,
    product_height_cm              INT,
    product_width_cm               INT
);

-- ------------------------------------------------------------
-- Transactional tables
-- ------------------------------------------------------------

CREATE TABLE orders (
    order_id                        VARCHAR(50) PRIMARY KEY,
    customer_id                     VARCHAR(50) NOT NULL REFERENCES customers(customer_id),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_purchase_ts ON orders(order_purchase_timestamp);

CREATE TABLE order_items (
    order_id             VARCHAR(50) NOT NULL REFERENCES orders(order_id),
    order_item_id         INT NOT NULL,
    product_id            VARCHAR(50) NOT NULL REFERENCES products(product_id),
    seller_id             VARCHAR(50) NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_date    TIMESTAMP,
    price                  DECIMAL(10, 2),
    freight_value          DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_seller ON order_items(seller_id);

CREATE TABLE order_payments (
    order_id                VARCHAR(50) NOT NULL REFERENCES orders(order_id),
    payment_sequential        INT NOT NULL,
    payment_type               VARCHAR(20),
    payment_installments       INT,
    payment_value               DECIMAL(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id                   VARCHAR(50) PRIMARY KEY,
    order_id                    VARCHAR(50) NOT NULL REFERENCES orders(order_id),
    review_score                 INT,
    review_comment_title          VARCHAR(255),
    review_comment_message         TEXT,
    review_creation_date            TIMESTAMP,
    review_answer_timestamp         TIMESTAMP
);
CREATE INDEX idx_reviews_order ON order_reviews(order_id);

-- ============================================================
-- Sanity check after loading data (run manually):
-- SELECT 'customers' AS tbl, COUNT(*) FROM customers
-- UNION ALL SELECT 'orders', COUNT(*) FROM orders
-- UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
-- UNION ALL SELECT 'products', COUNT(*) FROM products
-- UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
-- UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
-- UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;
-- ============================================================
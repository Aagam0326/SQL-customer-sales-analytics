-- ============================================================
-- Q4: Which product categories generate the most revenue per
--     order, vs. simply having the most orders? (Olist has no
--     cost data, so "margin" here is approximated as average
--     item price minus freight burden — a reasonable proxy
--     for profitability, and worth stating explicitly in your
--     findings writeup as a limitation of the dataset.)
-- Technique: joins across 3 tables, aggregation, ratio ranking
-- ============================================================

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT oi.order_id)               AS total_orders,
    ROUND(SUM(oi.price), 2)                    AS total_revenue,
    ROUND(AVG(oi.price), 2)                     AS avg_item_price,
    ROUND(AVG(oi.freight_value), 2)              AS avg_freight,
    ROUND(AVG(oi.freight_value) / NULLIF(AVG(oi.price), 0) * 100, 1) AS freight_pct_of_price
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_translation t ON t.product_category_name = p.product_category_name
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown')
HAVING COUNT(DISTINCT oi.order_id) >= 20   -- drop categories too small to be meaningful
ORDER BY total_revenue DESC
LIMIT 15;
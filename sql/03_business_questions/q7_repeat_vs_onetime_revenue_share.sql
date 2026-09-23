-- ============================================================
-- Q7: What share of total revenue comes from repeat customers
--     vs. one-time buyers?
-- Technique: CTE, CASE bucketing, share-of-total calculation
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id)         AS order_count,
        SUM(oi.price + oi.freight_value)   AS customer_revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
),
bucketed AS (
    SELECT
        CASE WHEN order_count > 1 THEN 'repeat_customer' ELSE 'one_time_customer' END AS customer_type,
        customer_revenue
    FROM customer_orders
)
SELECT
    customer_type,
    COUNT(*)                                              AS num_customers,
    ROUND(SUM(customer_revenue), 2)                        AS total_revenue,
    ROUND(100.0 * SUM(customer_revenue) / SUM(SUM(customer_revenue)) OVER (), 1) AS pct_of_total_revenue,
    ROUND(AVG(customer_revenue), 2)                        AS avg_revenue_per_customer
FROM bucketed
GROUP BY customer_type;
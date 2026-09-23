-- ============================================================
-- Q2: How can we segment customers by Recency, Frequency, and
--     Monetary value (RFM), and how many customers fall into
--     each segment?
-- Technique: CTEs, NTILE window function, CASE-based labeling
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        oi.price + oi.freight_value AS order_value
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
rfm_base AS (
    SELECT
        customer_unique_id,
        MAX(order_purchase_timestamp)                          AS last_order_date,
        COUNT(DISTINCT order_id)                                AS frequency,
        SUM(order_value)                                        AS monetary,
        (SELECT MAX(order_purchase_timestamp) FROM customer_orders) - MAX(order_purchase_timestamp) AS recency_interval
    FROM customer_orders
    GROUP BY customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        EXTRACT(DAY FROM recency_interval)::INT AS recency_days,
        frequency,
        ROUND(monetary, 2) AS monetary,
        NTILE(4) OVER (ORDER BY EXTRACT(DAY FROM recency_interval) ASC)  AS recency_score,   -- 4 = most recent
        NTILE(4) OVER (ORDER BY frequency DESC)                          AS frequency_score, -- 4 = most frequent
        NTILE(4) OVER (ORDER BY monetary DESC)                           AS monetary_score   -- 4 = highest spend
    FROM rfm_base
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champion'
        WHEN recency_score >= 3 AND frequency_score <= 2                        THEN 'New/Promising'
        WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk (high value)'
        WHEN recency_score <= 2 AND frequency_score <= 2                        THEN 'Lost/Lapsed'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM rfm_scored
ORDER BY monetary_score DESC, frequency_score DESC;

-- Summary rollup: count and revenue share per segment (run separately)
-- WITH segments AS ( ...above query as CTE... )
-- SELECT rfm_segment, COUNT(*) AS customers, SUM(monetary) AS segment_revenue
-- FROM segments GROUP BY rfm_segment ORDER BY segment_revenue DESC;
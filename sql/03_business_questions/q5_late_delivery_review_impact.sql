-- ============================================================
-- Q5: Do orders delivered later than estimated get worse
--     review scores than orders delivered on time or early?
-- Technique: multi-table join, derived CASE column, aggregation
-- ============================================================

WITH delivery_flag AS (
    SELECT
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        CASE
            WHEN o.order_delivered_customer_date IS NULL THEN 'not_delivered'
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late'
            ELSE 'on_time_or_early'
        END AS delivery_status,
        (o.order_delivered_customer_date - o.order_estimated_delivery_date) AS delay_interval
    FROM orders o
    WHERE o.order_status = 'delivered'
)
SELECT
    df.delivery_status,
    COUNT(*)                                    AS num_orders,
    ROUND(AVG(r.review_score), 2)                AS avg_review_score,
    ROUND(AVG(EXTRACT(DAY FROM df.delay_interval)), 1) AS avg_days_late_or_early
FROM delivery_flag df
JOIN order_reviews r ON r.order_id = df.order_id
GROUP BY df.delivery_status
ORDER BY avg_review_score;

-- Follow-up: correlate delay magnitude (not just late/on-time)
-- with review score directly, e.g.:
-- SELECT EXTRACT(DAY FROM delay_interval)::INT AS days_late_bucket,
--        AVG(review_score) FROM ... GROUP BY 1 ORDER BY 1;
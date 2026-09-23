-- ============================================================
-- Q6: How do sellers rank against each other on revenue,
--     order volume, and average review score? Who are the
--     top performers vs. sellers dragging down satisfaction?
-- Technique: joins, window function (RANK), HAVING filter
-- ============================================================

WITH seller_stats AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)     AS total_orders,
        ROUND(SUM(oi.price), 2)          AS total_revenue,
        ROUND(AVG(r.review_score), 2)     AS avg_review_score
    FROM sellers s
    JOIN order_items oi ON oi.seller_id = s.seller_id
    JOIN orders o ON o.order_id = oi.order_id
    LEFT JOIN order_reviews r ON r.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY s.seller_id, s.seller_state
    HAVING COUNT(DISTINCT oi.order_id) >= 10  -- exclude sellers too small to rank meaningfully
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_review_score,
    RANK() OVER (ORDER BY total_revenue DESC)      AS revenue_rank,
    RANK() OVER (ORDER BY avg_review_score DESC)     AS satisfaction_rank
FROM seller_stats
ORDER BY total_revenue DESC
LIMIT 20;
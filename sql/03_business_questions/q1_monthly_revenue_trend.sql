-- ============================================================
-- Q1: What is the monthly revenue trend, and how does each
--     month compare to the previous one (MoM growth)?
-- Technique: window function (LAG), date truncation, CTE
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price + oi.freight_value)                AS total_revenue,
        COUNT(DISTINCT o.order_id)                       AS total_orders
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    order_month,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        total_revenue - LAG(total_revenue) OVER (ORDER BY order_month),
        2
    ) AS revenue_change_vs_prev_month,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0),
        1
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;
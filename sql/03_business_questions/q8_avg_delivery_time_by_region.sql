-- ============================================================
-- Q8: How does average delivery time vary by customer state,
--     and which regions are most prone to delays?
-- Technique: join, date-diff aggregation, ordered ranking
-- ============================================================

SELECT
    c.customer_state,
    COUNT(*)                                                                   AS delivered_orders,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp))), 1) AS avg_delivery_days,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date))), 1) AS avg_days_vs_estimate,
    ROUND(
        100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END)
        / COUNT(*),
        1
    ) AS pct_late
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 30
ORDER BY avg_delivery_days DESC;
-- ============================================================
-- Q3: For customers grouped by the month they first purchased
--     (their "cohort"), what share of each cohort placed
--     another order in each subsequent month?
-- Technique: CTEs, self-join-free cohort logic, date math
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),
cohort_activity AS (
    SELECT
        fp.cohort_month,
        co.order_month,
        -- months elapsed since the customer's first purchase
        (EXTRACT(YEAR FROM co.order_month) - EXTRACT(YEAR FROM fp.cohort_month)) * 12
            + (EXTRACT(MONTH FROM co.order_month) - EXTRACT(MONTH FROM fp.cohort_month)) AS month_index,
        co.customer_unique_id
    FROM customer_orders co
    JOIN first_purchase fp ON fp.customer_unique_id = co.customer_unique_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.month_index,
    COUNT(DISTINCT ca.customer_unique_id)                                   AS active_customers,
    cs.cohort_customers,
    ROUND(100.0 * COUNT(DISTINCT ca.customer_unique_id) / cs.cohort_customers, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON cs.cohort_month = ca.cohort_month
GROUP BY ca.cohort_month, ca.month_index, cs.cohort_customers
ORDER BY ca.cohort_month, ca.month_index;

-- Pivot this in the notebook (pandas.pivot_table) to build the
-- classic cohort retention heatmap: rows = cohort_month,
-- columns = month_index, values = retention_pct.
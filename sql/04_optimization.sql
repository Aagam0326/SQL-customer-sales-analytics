-- ============================================================
-- 04_optimization.sql
-- Demonstrates query optimization: EXPLAIN ANALYZE before and
-- after adding an index, on a query that filters/joins on a
-- column with no existing index.
--
-- Target query: find all orders + review scores for a specific
-- seller_state, a pattern used in Q6/Q8-style analysis.
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Baseline — run EXPLAIN ANALYZE BEFORE adding an index
-- ------------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    s.seller_state,
    COUNT(*) AS num_items,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_state = 'SP'
GROUP BY s.seller_state;

-- Expected baseline plan (varies by data size): a Seq Scan on
-- sellers filtering seller_state, since seller_state has no index.
-- Note the "Execution Time" and whether it says "Seq Scan" vs
-- "Index Scan" in the output — that's your before-metric.

-- ------------------------------------------------------------
-- STEP 2: Add an index on the filtered column
-- ------------------------------------------------------------

CREATE INDEX idx_sellers_state ON sellers(seller_state);

-- ------------------------------------------------------------
-- STEP 3: Re-run the same query with EXPLAIN ANALYZE AFTER
-- ------------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    s.seller_state,
    COUNT(*) AS num_items,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE s.seller_state = 'SP'
GROUP BY s.seller_state;

-- ------------------------------------------------------------
-- STEP 4: Document the comparison
-- ------------------------------------------------------------
-- In your README / findings_summary.md, report:
--   - Plan type before (Seq Scan) vs after (Index Scan / Bitmap
--     Index Scan)
--   - Execution Time before vs after (ms)
--   - One sentence on WHY: an index lets Postgres jump straight
--     to matching rows instead of scanning the whole table, which
--     matters more as the sellers table grows — on ~3K sellers the
--     gain may be small, but the technique is what matters here.
--
-- NOTE: On small tables, Postgres' query planner may sometimes
-- still choose a Seq Scan even with the index present, if it
-- estimates that's cheaper (common on tables under a few thousand
-- rows). If that happens, mention it explicitly in your writeup —
-- explaining WHY the planner made that choice is itself a strong
-- signal of understanding, arguably more impressive than a naive
-- "index made it faster" claim.
-- ============================================================
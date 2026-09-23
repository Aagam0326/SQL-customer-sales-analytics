# Findings Summary

*Fill in each section after running the corresponding query. Keep it plain-English — this is what you'll pull resume bullets and interview talking points from.*

## Q1: Monthly Revenue Trend
**What we asked:** How has revenue grown month over month?
**What we found:** *(e.g., "Revenue grew X% from month A to month B, with a peak in [month] likely tied to...")*
**Why it matters:** *...*

## Q2: RFM Customer Segmentation
**What we asked:** Which customers are our most valuable, and which are at risk of churning?
**What we found:** *(e.g., "X% of customers fall into the 'Champion' segment, contributing Y% of total revenue")*
**Why it matters:** *...*

## Q3: Cohort Retention
**What we asked:** Do customers come back after their first purchase?
**What we found:** *(e.g., "Only X% of customers from the [month] cohort made a second purchase within 3 months")*
**Why it matters:** *...*

## Q4: Top Product Categories
**What we asked:** Which categories drive the most revenue, and how much does freight eat into that?
**What we found:** *...*
**Why it matters:** *...*

## Q5: Late Delivery & Review Scores
**What we asked:** Does late delivery hurt customer satisfaction?
**What we found:** *(e.g., "Late orders averaged X review score vs. Y for on-time orders")*
**Why it matters:** *...*

## Q6: Seller Performance
**What we asked:** Which sellers drive the most revenue, and do high-revenue sellers also have high satisfaction?
**What we found:** *...*
**Why it matters:** *...*

## Q7: Repeat vs. One-Time Customers
**What we asked:** How much of our revenue depends on repeat buyers?
**What we found:** *(e.g., "Repeat customers are only X% of buyers but generate Y% of revenue")*
**Why it matters:** *...*

## Q8: Delivery Time by Region
**What we asked:** Which regions have the slowest/most delayed delivery?
**What we found:** *...*
**Why it matters:** *...*

## Query Optimization
**What we did:** Added an index on `sellers.seller_state` and compared `EXPLAIN ANALYZE` output before/after.
**Result:** *(e.g., "Execution time dropped from Xms to Yms; plan changed from Seq Scan to Index Scan")*
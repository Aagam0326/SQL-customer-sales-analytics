# Customer & Sales Analytics — SQL + Olist E-Commerce

A SQL-driven analysis of ~100K real Brazilian e-commerce orders, built to answer concrete business questions using PostgreSQL — joins, CTEs, window functions, and query optimization — with a lightweight Python layer for visualization.

This project was built to demonstrate practical SQL skills beyond basic `SELECT` statements: relational schema design, multi-table joins, customer segmentation logic, cohort analysis, and query performance tuning.

---

## Key Findings

*(Fill in with your real numbers after running the queries — this section is what recruiters read first)*

- 📈 **Revenue trend:** *[e.g., "Revenue grew X% between [month] and [month], with the strongest month being..."]*
- 👥 **Customer value:** *[e.g., "Repeat customers make up only X% of buyers but drive Y% of total revenue"]*
- 🔁 **Retention:** *[e.g., "Only X% of first-time customers returned within 3 months"]*
- 🚚 **Delivery & satisfaction:** *[e.g., "Late deliveries averaged a review score of X vs. Y for on-time orders"]*

---

## Tech Stack

| Layer | Tools |
|---|---|
| Database | PostgreSQL 18 |
| Analysis | SQL (joins, CTEs, window functions, subqueries) |
| Visualization (optional) | Python — Pandas, SQLAlchemy, Matplotlib, Seaborn |
| Dataset | [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) |

---

## Project Structure

```
sql-customer-sales-analytics/
│
├── sql/
│   ├── 01_schema.sql                 # Table definitions, PK/FK constraints
│   ├── 02_load_data.sql              # CSV import via \copy
│   ├── 02b_fix_load_errors.sql       # Handles known Olist data-quality issues
│   ├── 03_business_questions/        # One query per business question (8 total)
│   └── 04_optimization.sql           # EXPLAIN ANALYZE before/after indexing
│
├── notebooks/
│   └── visualize_findings.ipynb      # Pulls query results, generates 8 charts
│
├── outputs/charts/                   # Exported chart images
├── docs/
│   └── findings_summary.md           # Full write-up of results, per question
│
├── data/raw/                         # Olist CSVs go here (not tracked in git)
├── requirements.txt
└── README.md
```

---

## Business Questions Answered

1. **Monthly revenue trend** — growth and month-over-month change (window functions)
2. **RFM customer segmentation** — Recency/Frequency/Monetary scoring to identify Champions, At-Risk, and Lapsed customers (CTEs, `NTILE`)
3. **Cohort retention analysis** — do customers come back after their first purchase, and when do they drop off? (cohort-indexed date math)
4. **Top product categories** — by revenue, with freight burden as a proxy for margin
5. **Late delivery impact on reviews** — does delivery delay hurt satisfaction scores?
6. **Seller performance ranking** — revenue vs. customer satisfaction, by seller (`RANK`)
7. **Repeat vs. one-time customer revenue share** — how dependent is revenue on repeat buyers?
8. **Delivery time by region** — which states see the slowest, most delayed shipping?

Each query lives in its own file under `sql/03_business_questions/`, with a comment block explaining the business question and the SQL technique it demonstrates.

---

## Query Optimization

`sql/04_optimization.sql` walks through a real before/after example: adding an index to a filtered column and comparing `EXPLAIN ANALYZE` output — plan type and execution time — to show the actual performance impact, not just claim one.

---

## How to Run

1. **Install PostgreSQL** (18+) and create a database:
   ```sql
   CREATE DATABASE olist_analytics;
   ```
2. **Download the dataset** from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place the CSVs in `data/raw/`
3. **Build the schema:**
   ```
   psql -U postgres -d olist_analytics -f sql/01_schema.sql
   ```
4. **Load the data:**
   ```
   psql -U postgres -d olist_analytics -f sql/02_load_data.sql
   psql -U postgres -d olist_analytics -f sql/02b_fix_load_errors.sql
   ```
5. **Run any business question query** directly in `psql` or pgAdmin, e.g.:
   ```
   psql -U postgres -d olist_analytics -f sql/03_business_questions/q2_rfm_segmentation.sql
   ```
6. **(Optional) Generate the charts:**
   ```
   pip install -r requirements.txt
   jupyter notebook notebooks/visualize_findings.ipynb
   ```
   Update the database password in the notebook's connection cell before running.

Full findings write-up: [`docs/findings_summary.md`](docs/findings_summary.md)

---

## Notes on Data Quality

The raw Olist dataset has a couple of known real-world inconsistencies, handled explicitly in this project rather than silently dropped:
- A handful of product categories in `products.csv` don't appear in the category-translation file — handled by not enforcing a foreign key on that column, with queries falling back to the raw category name via `COALESCE`.
- A small number of duplicate `review_id` values exist in the raw reviews CSV — de-duplicated during load by keeping the most recent review per ID.

## Author

**Aagam Shah**
[GitHub](https://github.com/Aagam0326) • [LinkedIn](#)
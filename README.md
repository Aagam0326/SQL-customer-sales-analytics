# SQL Customer Sales Analytics

PostgreSQL analytics project built around the Brazilian Olist e-commerce dataset. It loads the nine CSV files in `data/raw/` and answers eight business questions covering revenue, customer behavior, retention, products, delivery, and sellers.

## Quick start

1. Create a PostgreSQL database. The project is configured for the supplied `olist_*_dataset.csv` files plus `product_category_name_translation.csv`.
2. Run `sql/01_schema.sql`, then `sql/02_load_data.sql` from `psql` (update the absolute path in the load script if needed).
3. Run any query in `sql/03_business_questions/`.
4. Run `sql/04_optimization.sql` after loading data.

The SQL uses the exact public Olist column names—including the source fields `product_name_lenght` and `product_description_lenght`—and PostgreSQL syntax. The notebook is an optional charting companion.

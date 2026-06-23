# 🎮 Tungsten Gaming Store — End-to-End Analytics Pipeline

![AWS S3](https://img.shields.io/badge/AWS_S3-Storage-orange?logo=amazons3&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Data_Warehouse-29B5E8?logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-Transformations-FF694B?logo=dbt&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Visualization-1F77B4?logo=tableau&logoColor=white)

A production-style analytics pipeline built for a fictional gaming retail store. Raw transactional CSV data flows through **AWS S3 → Snowflake → dbt → Tableau**, producing a fully tested, modular data model with an executive-level analytics dashboard.

---

## 📐 Architecture

```
CSV Files
    │
    ▼
AWS S3 (Cloud Storage)
    │
    ▼
Snowflake Raw Tables
    │
    ▼
dbt Staging Models  ──▶  Tests (schema + data quality)
    │
    ▼
Fact & Dimension Tables (Star Schema)
    │
    ▼
Mart Tables (Business-ready aggregates)
    │
    ▼
Tableau Dashboard
```

---

## 📊 Dashboard Preview

> **KPIs:** 30 Total Orders | $3,784.50 Total Revenue | 11 Total Customers

The Tableau dashboard includes:
- 📈 **Monthly Revenue Trend** — Jan 2025 through May 2026
- 🏆 **Top 10 Products by Revenue** — ranked list (Gaming Chair II, Gaming Chair I, External SSD Y, ...)
- 👤 **Customer Lifetime Value** — bar chart across 11 customers (top: Ivy Thomas ~$670)

---

## 🗂️ Project Structure

```
tungsten-analytics/
│
├── data/                        # Raw source CSV files
│   ├── customers.csv
│   ├── orders.csv
│   ├── order_items.csv
│   └── products.csv
│
├── dbt_project/
│   ├── dbt_project.yml
│   ├── profiles.yml
│   │
│   ├── models/
│   │   ├── staging/             # stg_* models: cleaned raw sources
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   └── stg_products.sql
│   │   │
│   │   ├── intermediate/        # Fact & Dimension tables
│   │   │   ├── dim_customers.sql
│   │   │   ├── dim_products.sql
│   │   │   └── fct_orders.sql
│   │   │
│   │   └── marts/               # Business-facing aggregates
│   │       ├── mart_monthly_revenue.sql
│   │       ├── mart_top_products.sql
│   │       └── mart_customer_ltv.sql
│   │
│   └── tests/                   # dbt schema + custom data tests
│       └── schema.yml
│
└── tableau/
    └── tungsten_dashboard.twbx   # Packaged Tableau workbook
```

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Source Data | CSV Files | Raw transactional data |
| Cloud Storage | AWS S3 | Centralized data lake / staging area |
| Data Warehouse | Snowflake | Scalable cloud storage & compute |
| Transformation | dbt (Core) | Modular SQL transformations + testing |
| Visualization | Tableau | Business analytics dashboard |

---

## 🔄 Pipeline Walkthrough

### 1. Source Data (CSV)
Raw CSVs represent transactional data from the Tungsten Gaming Store — customers, products, orders, and order line items.

### 2. Cloud Storage — AWS S3
CSV files are uploaded to an S3 bucket as the centralized raw data source. Snowflake reads directly from S3 using an external stage, eliminating manual file transfers.

### 3. Raw Tables — Snowflake
Snowflake ingests the staged CSV files into raw tables via `COPY INTO`. No transformations are applied at this layer — data is loaded as-is to preserve the source of truth.

```sql
-- Example: Load raw orders from S3
COPY INTO raw.orders
FROM @s3_stage/orders.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);
```

### 4. Staging Models — dbt
Staging models (`stg_*`) sit directly on top of raw tables. Each model:
- Renames columns to consistent snake_case
- Casts data types (dates, numerics, strings)
- Filters out clearly invalid records
- Does **not** join across sources (one staging model per source table)

```sql
-- models/staging/stg_orders.sql
SELECT
    order_id,
    customer_id,
    CAST(order_date AS DATE)    AS order_date,
    CAST(total_amount AS FLOAT) AS total_amount,
    status
FROM {{ source('raw', 'orders') }}
WHERE order_id IS NOT NULL
```

### 5. dbt Tests
Schema tests validate data quality at every layer before downstream models run.

```yaml
# tests/schema.yml (excerpt)
models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: customer_id
        tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_id
```

### 6. Fact & Dimension Tables
The data model follows a **star schema** for clean, query-efficient analytics:

- `dim_customers` — customer attributes (name, email, location)
- `dim_products` — product catalog (name, category, unit price)
- `fct_orders` — grain: one row per order line item, with revenue and quantity measures

### 7. Mart Tables
Business-facing marts pre-aggregate the star schema for Tableau consumption:

| Mart | Description |
|---|---|
| `mart_monthly_revenue` | Total revenue grouped by month |
| `mart_top_products` | Products ranked by total revenue |
| `mart_customer_ltv` | Lifetime value (LTV) per customer |

### 8. Tableau Dashboard
Snowflake mart tables are connected directly to Tableau via the native Snowflake connector. Live or extract connection options are both supported. The dashboard surfaces three core views: monthly revenue trend, product rankings, and customer LTV.

---

## 🚀 Getting Started

### Prerequisites
- AWS account with S3 bucket created
- Snowflake account (free trial works)
- dbt Core installed: `pip install dbt-snowflake`
- Tableau Desktop or Tableau Public

### Setup

**1. Upload source CSVs to S3**
```bash
aws s3 cp data/ s3://your-bucket/tungsten/raw/ --recursive
```

**2. Create Snowflake objects**
```sql
CREATE DATABASE tungsten_db;
CREATE SCHEMA tungsten_db.raw;
CREATE SCHEMA tungsten_db.staging;
CREATE SCHEMA tungsten_db.marts;

-- Create external S3 stage
CREATE STAGE tungsten_db.raw.s3_stage
  URL = 's3://your-bucket/tungsten/raw/'
  CREDENTIALS = (AWS_KEY_ID='...' AWS_SECRET_KEY='...');
```

**3. Configure dbt profile**
```yaml
# ~/.dbt/profiles.yml
tungsten_analytics:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account
      user: your_user
      password: your_password
      role: TRANSFORMER
      database: tungsten_db
      warehouse: COMPUTE_WH
      schema: staging
      threads: 4
```

**4. Run dbt**
```bash
cd dbt_project/

# Install dependencies
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Run models + tests together
dbt build
```

**5. Connect Tableau**
- Open Tableau Desktop → Connect → **Snowflake**
- Enter your Snowflake account credentials
- Select database: `tungsten_db`, schema: `marts`
- Drag mart tables onto the canvas and build views

---

## ✅ dbt Model DAG

```
stg_customers ──┐
stg_orders    ──┼──▶ dim_customers ──┐
stg_order_items─┤    dim_products ───┼──▶ fct_orders ──▶ mart_monthly_revenue
stg_products ───┘                    │                ──▶ mart_top_products
                                     └────────────────▶ mart_customer_ltv
```

---

## 📈 Key Metrics (Sample Data)

| Metric | Value |
|---|---|
| Total Orders | 30 |
| Total Revenue | $3,784.50 |
| Total Customers | 11 |
| Top Product | Gaming Chair II |
| Highest LTV Customer | Ivy Thomas (~$670) |
| Peak Revenue Month | November 2025 (~$600) |

---

## 📁 Data Model

### `fct_orders`
| Column | Type | Description |
|---|---|---|
| order_id | VARCHAR | Primary key |
| customer_id | VARCHAR | FK → dim_customers |
| product_id | VARCHAR | FK → dim_products |
| order_date | DATE | Date of order |
| quantity | INTEGER | Units ordered |
| unit_price | FLOAT | Price per unit at time of sale |
| total_revenue | FLOAT | quantity × unit_price |

### `dim_customers`
| Column | Type | Description |
|---|---|---|
| customer_id | VARCHAR | Primary key |
| customer_name | VARCHAR | Full name |
| email | VARCHAR | Contact email |
| created_at | DATE | Account creation date |

### `dim_products`
| Column | Type | Description |
|---|---|---|
| product_id | VARCHAR | Primary key |
| product_name | VARCHAR | Display name |
| category | VARCHAR | Product category |
| unit_price | FLOAT | List price |

---

## 🔮 Future Enhancements

- [ ] Orchestrate pipeline with **Apache Airflow** or **dbt Cloud** schedules
- [ ] Add **incremental dbt models** for large-volume order history
- [ ] Introduce **data freshness tests** in `schema.yml`
- [ ] Add **revenue forecasting** layer with Python / dbt Python models
- [ ] Push mart tables to **Streamlit** for a self-serve web dashboard

---

## 👩‍💻 Author

**Anusha** | Data Engineer  
M.S. Information Systems — University of Colorado Denver  
[GitHub](https://github.com/Anusha3997) · [LinkedIn](https://linkedin.com/in/your-profile)

---

*Built to demonstrate end-to-end data engineering and analytics skills across cloud storage, warehouse, transformation, testing, and BI layers.*

# NYC Taxi Revenue Analytics — Audit Remediation & Fix Guide



*** 

This guide provides the exact, step-by-step code changes and operational fixes identified in the Senior Staff Data Engineering audit. Every fix includes the target file path, the exact lines to change, a before-and-after comparison, and the engineering rationale.

---

## Priority Action Summary

| Priority | Area | File | Summary of Change |
| :--- | :--- | :--- | :--- |
| 🔴 **1. Critical** | Financial Logic | [`models/intermediate/int_trips_enriched.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/intermediate/int_trips_enriched.sql) | Eliminate tip double-counting; correctly isolate revenue before and with tip. |
| 🟠 **2. High** | Pipeline Cost / Performance | [`models/marts/core/fct_daily_summary.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/fct_daily_summary.sql) | Push incremental date filter into the `base` CTE to prevent full-table history scans. |
| 🟠 **3. High** | CI/CD Automation | [`.github/workflows/dbt_ci.yml`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/.github/workflows/dbt_ci.yml) | Replace `dbt run` with `dbt build` to automatically load seeds before models. |
| 🟡 **4. Medium** | Key Lineage | [`models/marts/core/fct_trips.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/fct_trips.sql) | Remove redundant MD5 re-hashing on the surrogate key (`trip_sk`). |
| 🟡 **5. Medium** | Macro Standard | [`macros/generate_schema_name.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/macros/generate_schema_name.sql) | Align `generate_schema_name` with dbt Core standard parameter signatures. |
| 🟡 **6. Medium** | Date Spine Robustness | [`models/marts/core/dim_date.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/dim_date.sql) | Add realistic date range bounds to prevent dirty source timestamps from breaking the spine. |
| 🟡 **7. Medium** | Documentation Accuracy | [`docs/README.md`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/docs/README.md) & [`README.md`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/README.md) | Synchronize model counts (7 models), test counts (52 tests), and folder navigation paths. |

---

## Fix 1: Correct Tip Revenue Calculation (🔴 Critical)

### Why It Matters
In NYC TLC Yellow Taxi records, `total_amount` is already the sum of all charges (`fare_amount + extra + mta_tax + tip_amount + tolls + surcharges`). Adding `tip_amount` a second time caused `revenue_with_tip` to double-count tips, inflating downstream revenue reporting.

### File to Modify
[`models/intermediate/int_trips_enriched.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/intermediate/int_trips_enriched.sql)

### Changes to Apply (Around Lines 63–64)

#### ❌ Before:
```sql
    total_amount_usd as revenue_before_tip,
    total_amount_usd + coalesce(tip_amount_usd, 0) as revenue_with_tip,
```

#### ✅ After:
```sql
    total_amount_usd - coalesce(tip_amount_usd, 0) as revenue_before_tip,
    total_amount_usd as revenue_with_tip,
```

---

## Fix 2: Optimize Incremental Filter in Daily Summary Fact (🟠 High)

### Why It Matters
In `fct_daily_summary.sql`, the `where aggregated.date_day >= ...` filter was placed in the final CTE **after** the `aggregated` CTE had already scanned and grouped all historical records in `fct_trips`. On large tables (55M+ rows), this processed the full history every incremental run instead of only the rolling 30-day window.

### File to Modify
[`models/marts/core/fct_daily_summary.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/fct_daily_summary.sql)

### Changes to Apply

#### ❌ Before:
```sql
with base as (
    select
        pickup_date as date_day,
        pickup_zone_id as pickup_zone_id,
        payment_code as payment_code,

        revenue_with_tip as revenue_with_tip,
        fare_amount_usd as fare_amount_usd,
        trip_distance_miles as trip_distance_miles
    from {{ ref('fct_trips') }}
),

...

final as (
    select
        {{ generate_surrogate_key(['date_day','pickup_zone_id','payment_code'], prefix='sk_fact_daily_summary_') }} as day_zone_payment_sk,
        aggregated.date_day,
        puzd.taxi_zone_sk as pickup_zone_sk,
        aggregated.pickup_zone_id,
        aggregated.payment_code,

        aggregated.trip_count,
        aggregated.total_revenue,
        aggregated.avg_fare,
        aggregated.avg_distance
    from aggregated
    left join pickup_zone_dim puzd
        on aggregated.pickup_zone_id = puzd.zone_id

    {% if is_incremental() %}
    where aggregated.date_day >= (
        select dateadd(day, -30, max(date_day)) from {{ this }}
    )
    {% endif %}
)
```

#### ✅ After:
```sql
with base as (
    select
        pickup_date as date_day,
        pickup_zone_id as pickup_zone_id,
        payment_code as payment_code,

        revenue_with_tip as revenue_with_tip,
        fare_amount_usd as fare_amount_usd,
        trip_distance_miles as trip_distance_miles
    from {{ ref('fct_trips') }}
    {% if is_incremental() %}
    where pickup_date >= (
        select dateadd(day, -30, max(date_day)) from {{ this }}
    )
    {% endif %}
),

...

final as (
    select
        {{ generate_surrogate_key(['date_day','pickup_zone_id','payment_code'], prefix='sk_fact_daily_summary_') }} as day_zone_payment_sk,
        aggregated.date_day,
        puzd.taxi_zone_sk as pickup_zone_sk,
        aggregated.pickup_zone_id,
        aggregated.payment_code,

        aggregated.trip_count,
        aggregated.total_revenue,
        aggregated.avg_fare,
        aggregated.avg_distance
    from aggregated
    left join pickup_zone_dim puzd
        on aggregated.pickup_zone_id = puzd.zone_id
)
```

---

## Fix 3: Fix CI/CD Workflow with `dbt build` (🟠 High)

### Why It Matters
`.github/workflows/dbt_ci.yml` ran `dbt run` then `dbt test` without running `dbt seed`. On fresh CI test databases, models referencing seed tables (`taxi_zones`, `stg_payment_types`) failed immediately. Switching to `dbt build` executes seeds, models, snapshots, and tests in correct topological order.

### File to Modify
[`.github/workflows/dbt_ci.yml`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/.github/workflows/dbt_ci.yml)

### Changes to Apply (Around Lines 46–54)

#### ❌ Before:
```yaml
      - name: dbt deps
        run: dbt deps

      - name: dbt run
        run: dbt run

      - name: dbt test
        run: dbt test
```

#### ✅ After:
```yaml
      - name: dbt deps
        run: dbt deps

      - name: dbt build
        run: dbt build
```

---

## Fix 4: Remove Redundant Surrogate Key Re-Hashing (🟡 Medium)

### Why It Matters
`stg_trips.sql` already creates a unique, hashed `trip_key`. In `fct_trips.sql`, calling `generate_surrogate_key(['trip_key'])` re-hashes an MD5 hash and prepends a second `sk_` prefix (`sk_sk_...`).

### File to Modify
[`models/marts/core/fct_trips.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/fct_trips.sql)

### Changes to Apply (Line 41)

#### ❌ Before:
```sql
final as (
    select
        {{ generate_surrogate_key(['trip_key']) }} as trip_sk,
```

#### ✅ After:
```sql
final as (
    select
        trips.trip_key as trip_sk,
```

---

## Fix 5: Clean Macro Signature for `generate_schema_name` (🟡 Medium)

### Why It Matters
dbt Core passes two arguments to `generate_schema_name`: `(custom_schema_name, node)`. The existing macro signature `(schema_name, include_target=false)` treated the `node` object passed by dbt as a truthy boolean for `include_target`.

### File to Modify
[`macros/generate_schema_name.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/macros/generate_schema_name.sql)

### Changes to Apply

#### ❌ Before:
```sql
{% macro generate_schema_name(schema_name, include_target=false) %}
  {%- if include_target -%}
    {{ return((target.name ~ '_' ~ schema_name) | upper) }}
  {%- else -%}
    {{ return(schema_name | upper) }}
  {%- endif -%}
{% endmacro %}
```

#### ✅ After:
```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema | upper }}
    {%- else -%}
        {{ custom_schema_name | trim | upper }}
    {%- endif -%}
{%- endmacro %}
```

---

## Fix 6: Guard Date Spine Range in `dim_date.sql` (🟡 Medium)

### Why It Matters
Dirty source records with corrupt future dates (e.g. year 2088) can expand `datediff(day, min_date, max_date)` beyond the 10,000 generator limit, creating gaps in the date spine and causing relationship test failures in marts.

### File to Modify
[`models/marts/core/dim_date.sql`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/models/marts/core/dim_date.sql)

### Changes to Apply (Lines 13–20)

#### ❌ Before:
```sql
with min_max as (
    select
        min(pickup_date) as min_date,
        max(dropoff_date) as max_date
    from {{ ref('stg_trips') }}
    where pickup_date is not null
      and dropoff_date is not null
)
```

#### ✅ After:
```sql
with min_max as (
    select
        coalesce(min(pickup_date), '2009-01-01'::date) as min_date,
        coalesce(least(max(dropoff_date), current_date()), current_date()) as max_date
    from {{ ref('stg_trips') }}
    where pickup_date is not null
      and dropoff_date is not null
      and pickup_date >= '2009-01-01'
      and pickup_date <= current_date()
)
```

---

## Fix 7: Correct Documentation Counts & File Tree (🟡 Medium)

### Why It Matters
Technical recruiters and hiring managers cross-check claims against the repository. Inaccurate test counts or broken directory paths create an impression of careless documentation.

### Files to Modify
1. [`docs/README.md`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/docs/README.md)
2. [`docs/diagrams/README.md`](file:///c:/Users/kheza/Desktop/Data%20Engineering/Project%201%20dbt_Analytics/NYC%20Taxi%20revenue%20analytics/docs/diagrams/README.md)

### Reconciled Figures to Apply:
- **Production Models:** Change `8` → `7` (`stg_trips`, `stg_taxi_zones`, `int_trips_enriched`, `dim_date`, `dim_taxi_zone`, `fct_trips`, `fct_daily_summary`).
- **Seeds:** 2 (`taxi_zones`, `stg_payment_types`).
- **Declared Tests:** Change `86` → `52` (or clarify: "52 user-defined schema tests + dbt_project_evaluator quality checks").
- **Path References:** Replace `first_project/models/` with `models/`.

---

## Verification & Execution Commands

After applying the fixes above, execute the following commands in order to validate the full pipeline:

```bash
# 1. Clean previous build artifacts
dbt clean

# 2. Reinstall dbt packages
dbt deps

# 3. Load seed data
dbt seed

# 4. Build all models, seeds, and tests
dbt build

# 5. Verify incremental logic specifically
dbt run --select fct_trips fct_daily_summary

# 6. Generate and verify documentation
dbt docs generate
dbt docs serve --port 8080
```

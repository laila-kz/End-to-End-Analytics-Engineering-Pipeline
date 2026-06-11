# dbt Analytics Portfolio — NYC Taxi Revenue

## Project overview

This repository demonstrates a production-grade dbt analytics engineering project using the NYC Taxi dataset in Snowflake.

- Warehouse: Snowflake
- Source databases: `RAW`, `STAGING`, `INTERMEDIATE`, `MARTS`
- Source schemas: `RAW.TAXI`, `STAGING.TAXI`, `INTERMEDIATE.TAXI`, `MARTS.CORE`
- Primary business domain: taxi trip revenue, zone analytics, payment type performance

## Architecture

```text
RAW.TAXI
  ├─ TRIPS
  └─ TAXI_ZONES

SEEDS
  └─ payment_types.csv

models/
  ├─ staging/taxi
  │   ├─ stg_trips.sql
  │   ├─ stg_taxi_zones.sql
  │   ├─ stg_payment_types.sql
  │   └─ _taxi__sources.yml
  ├─ intermediate
  │   └─ int_trips_enriched.sql
  └─ marts/core
      ├─ dim_taxi_zone.sql
      ├─ dim_date.sql
      ├─ fct_trips.sql
      └─ fct_daily_summary.sql
```

## Medallion architecture

- `RAW`: raw Snowflake source tables loaded by the upstream ingestion process
- `STAGING`: cleaning, naming, and type-safe staging views for source tables
- `INTERMEDIATE`: enrichment joins, lookup resolution, and business-friendly measures
- `MARTS`: curated dimensional and fact tables for analytics consumption

## Goals

- Provide a clean, documented dbt project for analytics portfolio review
- Establish an auditable lineage from raw taxi trip sources to business-facing marts
- Enable rigorous testing with schema and singular tests
- Support CI/CD with dbt build, test, and docs publication workflows

## Setup

1. Confirm your Snowflake profile is configured for `first_projet` in `~/.dbt/profiles.yml`.
2. Set required environment variables for the workflow or local runtime:
   - `DBT_TARGET_DATABASE` (default: `MARTS`)
   - `DBT_STAGING_DATABASE` (default: `STAGING`)
   - `DBT_INTERMEDIATE_DATABASE` (default: `INTERMEDIATE`)
   - `DBT_MARTS_DATABASE` (default: `MARTS`)
3. Install the Python dependencies:

```bash
pip install -r requirements.txt
```

4. Install dbt package dependencies:

```bash
dbt deps
```

## Common dbt commands

- `dbt build` — compile, run, test, and document models
- `dbt run` — execute models only
- `dbt test` — execute schema and singular tests
- `dbt docs generate` — generate the documentation site
- `dbt source freshness` — validate raw source freshness

## Testing

This project includes:

- schema tests for uniqueness, non-null values, relationships, and accepted values
- singular SQL tests for fare positivity, trip duration validity, and non-negative revenue

Run tests locally:

```bash
dbt test
```

## CI/CD

- `dbt_ci.yml` runs `dbt deps`, `dbt build --state:modified+`, and `dbt test --state:modified+`
- `dbt_docs.yml` generates docs and publishes the compiled site to GitHub Pages

## Lineage

Lineage is managed through dbt references:

- `source('taxi', 'trips')` → `stg_trips`
- `source('taxi', 'taxi_zones')` → `stg_taxi_zones`
- `payment_types.csv` seed → `stg_payment_types`
- `stg_*` models → `int_trips_enriched`
- enrichment → `fct_trips`, `fct_daily_summary`, `dim_taxi_zone`, `dim_date`

## Notes

- All source and model documentation is maintained in YAML schema files.
- This project uses `dbt_utils` and `dbt_expectations` for production-grade testing.

{{ config(materialized='view') }}

-- =============================================================================
-- MODEL: stg_taxi_zones
-- LAYER:  Staging
-- PURPOSE: Standardize the taxi zone lookup table for downstream enrichment.
-- SOURCE: seed/taxi_zones.csv
-- GRAIN: One row per taxi zone
-- MATERIALIZATION: view
-- =============================================================================

select
    location_id,
    borough,
    zone,
    service_zone
from {{ ref('taxi_zones') }}

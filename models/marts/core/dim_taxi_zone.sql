{{ config(
    materialized='view',
    tags=['marts','core','dimensions']
) }}

-- =============================================================================
-- MODEL: dim_taxi_zone
-- LAYER: Marts Core (Dimension)
-- PURPOSE: Taxi zone dimension built from the standardized staging lookup.
-- =============================================================================

with zones as (
    select
        location_id as zone_id,
        zone as zone_name,
        borough,
        service_zone
    from {{ ref('stg_taxi_zones') }}
)

select
    {{ generate_surrogate_key(['zone_id'], prefix='sk_dim_taxi_zone_') }} as taxi_zone_sk,
    zone_id,
    zone_name,
    borough,
    service_zone
from zones

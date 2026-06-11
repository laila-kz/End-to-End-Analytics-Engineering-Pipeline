{{ config(materialized='view') }}

-- =============================================================================
-- MODEL: int_trips_enriched
-- LAYER:  Intermediate
-- PURPOSE: Enrich staged taxi trips with business metrics, time dimensions,
--          zone lookups, and payment descriptions.
-- SOURCE: {{ ref('stg_trips') }}
-- GRAIN: One row per taxi trip
-- MATERIALIZATION: view
-- =============================================================================

with trips as (
    select *
    from {{ ref('stg_trips') }}
),
pickup_zones as (
    select *
    from {{ ref('stg_taxi_zones') }}
),
payment_types as (
    select *
    from {{ ref('stg_payment_types') }}
)

select
    trip_key,
    vendor_id,
    pickup_at,
    dropoff_at,
    pickup_date,
    dropoff_date,
    passenger_count,
    trip_distance_miles,
    rate_code_id,
    store_and_forward_flag,
    pickup_zone_id,
    pz.borough as pickup_borough,
    dropoff_zone_id,
    dz.borough as dropoff_borough,
    trips.payment_code as payment_code,
    coalesce(pt.payment_type_description, 'Other') as payment_type_description,
    fare_amount_usd,
    extra_amount_usd,
    mta_tax_usd,
    tip_amount_usd,
    tolls_amount_usd,
    improvement_surcharge_usd,
    total_amount_usd,
    congestion_surcharge_usd,
    airport_fee_usd,
    date_part(hour, pickup_at) as pickup_hour,
    dayname(pickup_at) as pickup_day_of_week,
    date_part(month, pickup_at) as pickup_month,
    date_part(year, pickup_at) as pickup_year,
    datediff('second', pickup_at, dropoff_at) / 60.0 as trip_duration_minutes,
    datediff('second', pickup_at, dropoff_at) / 3600.0 as trip_duration_hours,
    case
        when datediff('second', pickup_at, dropoff_at) > 0
            then trip_distance_miles / (datediff('second', pickup_at, dropoff_at) / 3600.0)
        else null
    end as average_speed_mph,
    total_amount_usd as revenue_before_tip,
    total_amount_usd + coalesce(tip_amount_usd, 0) as revenue_with_tip,
    case
        when trip_distance_miles < 1 then '< 1'
        when trip_distance_miles < 3 then '1-3'
        when trip_distance_miles < 6 then '3-6'
        when trip_distance_miles < 10 then '6-10'
        else '10+'
    end as trip_distance_bucket
from trips
left join pickup_zones pz on trips.pickup_zone_id = pz.location_id
left join pickup_zones dz on trips.dropoff_zone_id = dz.location_id
left join payment_types pt on trips.payment_code = pt.payment_code

{{ config(
    materialized='incremental',
    unique_key='trip_sk',
    incremental_strategy='delete+insert',
    tags=['marts','core','facts']
) }}

-- ============================================================================
-- MODEL: fct_trips
-- LAYER: Marts Core (Fact)
-- PURPOSE: One row per enriched taxi trip.
-- ============================================================================

with trips as (
    select
        *
    from {{ ref('int_trips_enriched') }}
    {% if is_incremental() %}
    where pickup_date >= (
        select max(pickup_date) from {{ this }}
    )
    {% endif %}
),

pickup_zone_dim as (
    select
        zone_id,
        taxi_zone_sk
    from {{ ref('dim_taxi_zone') }}
),

dropoff_zone_dim as (
    select
        zone_id,
        taxi_zone_sk
    from {{ ref('dim_taxi_zone') }}
),

final as (
    select
        {{ generate_surrogate_key(['trip_key']) }} as trip_sk,

        -- Foreign keys to dimensions
        trips.pickup_date as pickup_date,
        trips.dropoff_date as dropoff_date,
        puzd.taxi_zone_sk as pickup_zone_sk,
        dzd.taxi_zone_sk as dropoff_zone_sk,
        trips.pickup_zone_id as pickup_zone_id,
        trips.dropoff_zone_id as dropoff_zone_id,
        trips.payment_code as payment_code,

        -- Revenue metrics
        trips.revenue_before_tip as revenue_before_tip,
        trips.revenue_with_tip as revenue_with_tip,

        -- Trip metrics
        trips.passenger_count as passenger_count,
        trips.trip_distance_miles as trip_distance_miles,
        trips.trip_duration_minutes as trip_duration_minutes,
        trips.trip_duration_hours as trip_duration_hours,
        trips.average_speed_mph as average_speed_mph,
        trips.trip_distance_bucket as trip_distance_bucket,

        -- Additional trip measures
        trips.fare_amount_usd as fare_amount_usd,
        trips.extra_amount_usd as extra_amount_usd,
        trips.mta_tax_usd as mta_tax_usd,
        trips.tip_amount_usd as tip_amount_usd,
        trips.tolls_amount_usd as tolls_amount_usd,
        trips.improvement_surcharge_usd as improvement_surcharge_usd,
        trips.total_amount_usd as total_amount_usd,
        trips.congestion_surcharge_usd as congestion_surcharge_usd,
        trips.airport_fee_usd as airport_fee_usd,

        -- Dimensional attributes (optional denormalization)
        trips.pickup_at as pickup_at,
        trips.dropoff_at as dropoff_at,
        trips.pickup_hour as pickup_hour,
        trips.pickup_day_of_week as pickup_day_of_week,
        trips.pickup_month as pickup_month,
        trips.pickup_year as pickup_year,
        trips.pickup_borough as pickup_borough,
        trips.dropoff_borough as dropoff_borough,
        trips.payment_type_description as payment_type_description

    from trips
    left join pickup_zone_dim puzd
        on trips.pickup_zone_id = puzd.zone_id
    left join dropoff_zone_dim dzd
        on trips.dropoff_zone_id = dzd.zone_id


)

select * from final


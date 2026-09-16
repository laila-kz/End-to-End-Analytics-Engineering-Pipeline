{{ config(
    materialized='incremental',
    unique_key='day_zone_payment_sk',
    incremental_strategy='delete+insert',
    tags=['marts','core','facts']
) }}

-- ============================================================================
-- MODEL: fct_daily_summary
-- LAYER: Marts Core (Fact)
-- PURPOSE: Aggregated daily performance by zone & payment type.
-- ============================================================================

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

pickup_zone_dim as (
    select
        zone_id,
        taxi_zone_sk
    from {{ ref('dim_taxi_zone') }}
),

aggregated as (
    select
        date_day,
        pickup_zone_id,
        payment_code,

        count(*) as trip_count,
        sum(greatest(coalesce(revenue_with_tip, 0), 0)) as total_revenue,
        coalesce(
            avg(
                case 
                    when fare_amount_usd is null then null 
                    when fare_amount_usd < 0 then null 
                    when fare_amount_usd = 0 then null 
                    else fare_amount_usd
                end
            ),
            0
        ) as avg_fare,
        avg(trip_distance_miles) as avg_distance
    from base
    group by 1, 2, 3
),

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

select * from final


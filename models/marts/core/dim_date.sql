{{ config(
    materialized='view',
    tags=['marts','core','dimensions']
) }}

-- =============================================================================
-- MODEL: dim_date
-- LAYER: Marts Core (Dimension)
-- PURPOSE: Date dimension generated from the available taxi trip date range.
--          Covers the full range automatically.
-- =============================================================================

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
,
date_spine as (
    select
        dateadd(day, seq4(), min_max.min_date) as date_day
    from min_max
    , table(generator(rowcount => 10000))
    where seq4() <= datediff(day, min_max.min_date, min_max.max_date)
)

select
    date_day,
    year(date_day) as year,
    quarter(date_day) as quarter,
    month(date_day) as month,
    week(date_day) as week,
    dayofweek(date_day) as day_of_week,
    case
        when dayofweek(date_day) in (0, 6) then true
        else false
    end as is_weekend,
    {{ fiscal_year('date_day', 1) }} as fiscal_year
from date_spine

{% macro debug_revenue_and_nulls() %}
  {% set sql %}
    with staging as (
      select
        count(*) as staging_rows,
        count_if(fare_amount_usd < 0) as negative_fare,
        count_if(tip_amount_usd < 0) as negative_tip,
        count_if(total_amount_usd < 0) as negative_total,
        count_if(trip_distance_miles < 0) as negative_distance,
        count_if(pickup_at is null) as null_pickup_at,
        count_if(dropoff_at is null) as null_dropoff_at,
        count_if(payment_code is null) as null_payment_code
      from {{ ref('stg_trips') }}
    ),
    enriched as (
      select
        count(*) as enriched_rows,
        count_if(revenue_before_tip < 0) as negative_revenue_before_tip,
        count_if(revenue_with_tip < 0) as negative_revenue_with_tip,
        count_if(pickup_date is null) as null_pickup_date,
        count_if(dropoff_date is null) as null_dropoff_date
      from {{ ref('int_trips_enriched') }}
    )
    select 'staging' as layer, staging_rows as total_rows, negative_fare, negative_tip, negative_total, negative_distance, null_pickup_at, null_dropoff_at, null_payment_code
    from staging
    union all
    select 'enriched' as layer, enriched_rows as total_rows, negative_revenue_before_tip, negative_revenue_with_tip, null, null_pickup_date, null_dropoff_date, null
    from enriched
  {% endset %}
  {{ return(run_query(sql)) }}
{% endmacro %}

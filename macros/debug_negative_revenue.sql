{% macro debug_negative_revenue() %}
  {% set sql %}
    with source_negatives as (
      select
        count(*) as source_total_rows,
        count_if(try_to_decimal(VARIANT_COL:"fare_amount") < 0) as source_negative_fare,
        count_if(try_to_decimal(VARIANT_COL:"tip_amount") < 0) as source_negative_tip,
        count_if(try_to_decimal(VARIANT_COL:"total_amount") < 0) as source_negative_total,
        count_if(try_to_decimal(VARIANT_COL:"trip_distance") < 0) as source_negative_distance
      from RAW.TAXI.TRIPS
    ),
    staging_negatives as (
      select
        count(*) as staging_total_rows,
        count_if(fare_amount_usd < 0) as staging_negative_fare,
        count_if(tip_amount_usd < 0) as staging_negative_tip,
        count_if(total_amount_usd < 0) as staging_negative_total,
        count_if(trip_distance_miles < 0) as staging_negative_distance
      from {{ ref('stg_trips') }}
    ),
    enriched_negatives as (
      select
        count(*) as enriched_total_rows,
        count_if(revenue_before_tip < 0) as enriched_negative_before_tip,
        count_if(revenue_with_tip < 0) as enriched_negative_with_tip
      from {{ ref('int_trips_enriched') }}
    )
    select 'source' as layer, source_total_rows as total_rows, source_negative_fare as negative_fare, source_negative_tip as negative_tip, source_negative_total as negative_total, source_negative_distance as negative_distance
    from source_negatives
    union all
    select 'staging', staging_total_rows, staging_negative_fare, staging_negative_tip, staging_negative_total, staging_negative_distance
    from staging_negatives
    union all
    select 'enriched', enriched_total_rows, enriched_negative_before_tip, enriched_negative_with_tip, null, null
    from enriched_negatives
  {% endset %}
  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log(row | join(' | '), info=True) }}
    {% endfor %}
  {% endif %}
  {{ return(results) }}
{% endmacro %}

{% macro debug_freshness_and_revenue() %}
  {% set sql %}
    with source_info as (
      select
        column_name,
        data_type
      from RAW.information_schema.columns
      where table_schema = 'TAXI'
        and table_name = 'TRIPS'
      order by ordinal_position
    ),
    negative_revenue as (
      select
        count(*) as total_rows,
        count_if(total_amount < 0) as negative_total_amount,
        count_if(tip_amount < 0) as negative_tip_amount,
        count_if(fare_amount < 0) as negative_fare_amount,
        count_if(trip_distance < 0) as negative_distance
      from RAW.TAXI.TRIPS
    )
    select * from source_info
    union all
    select '---', '---'
    union all
    select 'negative_total_amount', to_varchar(negative_total_amount)
    from negative_revenue
    union all
    select 'negative_tip_amount', to_varchar(negative_tip_amount)
    from negative_revenue
    union all
    select 'negative_fare_amount', to_varchar(negative_fare_amount)
    from negative_revenue
    union all
    select 'negative_distance', to_varchar(negative_distance)
    from negative_revenue
  {% endset %}
  {{ return(run_query(sql)) }}
{% endmacro %}

{% macro debug_taxi_trip_variant_values() %}
  {% set sql %}
    select
      count(*) as total_rows,
      count_if(VARIANT_COL:"fare_amount"::float < 0) as negative_fare,
      count_if(VARIANT_COL:"tip_amount"::float < 0) as negative_tip,
      count_if(VARIANT_COL:"total_amount"::float < 0) as negative_total,
      count_if(VARIANT_COL:"trip_distance"::float < 0) as negative_distance,
      min(VARIANT_COL:"tpep_pickup_datetime"::bigint) as min_pickup_ts,
      max(VARIANT_COL:"tpep_pickup_datetime"::bigint) as max_pickup_ts,
      count_if(VARIANT_COL:"_LOADED_AT" is not null) as loaded_at_count
    from RAW.TAXI.TRIPS
  {% endset %}
  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log('TOTAL: ' ~ row[0] ~ ', NEG_FARE: ' ~ row[1] ~ ', NEG_TIP: ' ~ row[2] ~ ', NEG_TOTAL: ' ~ row[3] ~ ', NEG_DISTANCE: ' ~ row[4] ~ ', MIN_PICKUP_TS: ' ~ row[5] ~ ', MAX_PICKUP_TS: ' ~ row[6] ~ ', LOADED_AT_COUNT: ' ~ row[7], info=True) }}
    {% endfor %}
  {% endif %}
  {{ return(results) }}
{% endmacro %}

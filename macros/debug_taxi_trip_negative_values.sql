{% macro debug_taxi_trip_negative_values() %}
  {% set sql %}
    select
      count(*) as total_rows,
      count_if(VARIANT_COL:'total_amount' < 0) as negative_total_amount,
      count_if(VARIANT_COL:'tip_amount' < 0) as negative_tip_amount,
      count_if(VARIANT_COL:'fare_amount' < 0) as negative_fare_amount,
      count_if(VARIANT_COL:'trip_distance' < 0) as negative_distance,
      count_if(VARIANT_COL:'_LOADED_AT' is not null) as loaded_at_count
    from RAW.TAXI.TRIPS
  {% endset %}
  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log('TOTAL: ' ~ row[0] ~ ', NEG_TOTAL: ' ~ row[1] ~ ', NEG_TIP: ' ~ row[2] ~ ', NEG_FARE: ' ~ row[3] ~ ', NEG_DISTANCE: ' ~ row[4] ~ ', LOADED_AT_COUNT: ' ~ row[5], info=True) }}
    {% endfor %}
  {% endif %}
  {{ return(results) }}
{% endmacro %}

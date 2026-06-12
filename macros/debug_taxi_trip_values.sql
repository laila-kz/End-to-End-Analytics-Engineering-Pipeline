{% macro debug_taxi_trip_values() %}
  {% set sql %}
    select column_name, data_type
    from RAW.information_schema.columns
    where table_schema = 'TAXI'
      and table_name = 'TRIPS'
    order by ordinal_position
  {% endset %}

  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log('COLUMN: ' ~ row[0] ~ ' | TYPE: ' ~ row[1], info=True) }}
    {% endfor %}
  {% endif %}

  {% set sql2 %}
    select
      count(*) as total_rows,
      count_if(to_number(VARIANT_COL:'"total_amount"') < 0) as negative_total_amount,
      count_if(to_number(VARIANT_COL:'"tip_amount"') < 0) as negative_tip_amount,
      count_if(to_number(VARIANT_COL:'"fare_amount"') < 0) as negative_fare_amount,
      count_if(to_number(VARIANT_COL:'"trip_distance"') < 0) as negative_distance
    from RAW.TAXI.TRIPS
  {% endset %}
  {% set results2 = run_query(sql2) %}
  {% if execute %}
    {% for row in results2.rows %}
      {{ log('TOTAL ROWS: ' ~ row[0] ~ ', NEGATIVE_TOTAL: ' ~ row[1] ~ ', NEGATIVE_TIP: ' ~ row[2] ~ ', NEGATIVE_FARE: ' ~ row[3] ~ ', NEGATIVE_DISTANCE: ' ~ row[4], info=True) }}
    {% endfor %}
  {% endif %}

  {{ return(results2) }}
{% endmacro %}

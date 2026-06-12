{% macro debug_taxi_trip_columns_no_args() %}
  {% set sql %}
    select column_name, data_type, ordinal_position
    from RAW.information_schema.columns
    where table_schema = 'TAXI'
      and table_name = 'TRIPS'
    order by ordinal_position
  {% endset %}

  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log('COLUMN: ' ~ row[0] ~ ' | TYPE: ' ~ row[1] ~ ' | ORDINAL: ' ~ row[2], info=True) }}
    {% endfor %}
  {% endif %}
  {{ return(results) }}
{% endmacro %}

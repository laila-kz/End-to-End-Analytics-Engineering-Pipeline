{% macro debug_raw_taxi_trips_columns() %}
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
      {{ log('COLUMN: ' ~ row[0] ~ ' | TYPE: ' ~ row[1], warning=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}

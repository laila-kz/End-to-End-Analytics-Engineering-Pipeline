{% macro inspect_columns_like(database, schema, pattern) %}
  {% set sql %}
    select table_name, column_name, data_type
    from {{ database }}.information_schema.columns
    where table_schema = upper('{{ schema }}')
      and column_name ilike '{{ pattern }}'
    order by table_name, ordinal_position
  {% endset %}

  {% set results = run_query(sql) %}

  {% if execute %}
    {% for row in results.rows %}
      {{ log('TABLE: ' ~ row[0] ~ ' | COLUMN: ' ~ row[1] ~ ' | TYPE: ' ~ row[2], info=True) }}
    {% endfor %}
  {% endif %}

  {{ return(results) }}
{% endmacro %}

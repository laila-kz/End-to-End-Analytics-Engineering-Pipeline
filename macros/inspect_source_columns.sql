{% macro inspect_source_columns(database, schema, table) %}
  {% set sql %}
    select column_name, data_type
    from {{ database }}.information_schema.columns
    where table_catalog = upper('{{ database }}')
      and table_schema = upper('{{ schema }}')
      and table_name = upper('{{ table }}')
    order by ordinal_position
  {% endset %}

  {% set results = run_query(sql) %}

  {% if execute %}
    {% for row in results.rows %}
      {{ log('COLUMN: ' ~ row[0] ~ ' | TYPE: ' ~ row[1], info=True) }}
    {% endfor %}
  {% endif %}

  {{ return(results) }}
{% endmacro %}

{% macro inspect_variant_keys(database, schema, table, variant_col) %}
  {% set sql %}
    select distinct key
    from {{ database }}.{{ schema }}.{{ table }},
         lateral flatten(input => {{ variant_col }})
    order by key
    limit 100
  {% endset %}

  {% set results = run_query(sql) %}

  {% if execute %}
    {% for row in results.rows %}
      {{ log('VARIANT KEY: ' ~ row[0], info=True) }}
    {% endfor %}
  {% endif %}

  {{ return(results) }}
{% endmacro %}

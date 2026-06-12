{% macro query_operation(sql) %}
  {% set results = run_query(sql) %}
  {% if execute %}
    {% for row in results.rows %}
      {{ log(row | join(', '), info=True) }}
    {% endfor %}
  {% endif %}
  {{ return(results) }}
{% endmacro %}

{% macro generate_schema_name(schema_name, include_target=false) %}
  {%- if include_target -%}
    {{ return((target.name ~ '_' ~ schema_name) | upper) }}
  {%- else -%}
    {{ return(schema_name | upper) }}
  {%- endif -%}
{% endmacro %}

{% macro debug_source_freshness(database, schema, table, variant_col) %}
  {% set sql %}
    select
      count(*) as total_rows,
      count(*) filter (where {{ variant_col }}:"_LOADED_AT" is not null) as loaded_at_count,
      max({{ variant_col }}:"_LOADED_AT"::timestamp_ntz) as max_loaded_at
    from {{ database }}.{{ schema }}.{{ table }}
  {% endset %}
  {{ return(run_query(sql)) }}
{% endmacro %}

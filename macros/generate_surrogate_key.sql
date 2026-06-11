{% macro generate_surrogate_key(key_columns, prefix='sk_') %}
  {#
  Generates a deterministic surrogate key from one or more source columns.

  Args:
    key_columns: A list of expressions that define the natural key.
    prefix: Optional string prefix for the generated surrogate key value.

  Returns:
    A Snowflake SQL expression that produces a stable hashed surrogate key.

  Usage:
    {{ generate_surrogate_key(["id", "email"], prefix='sk_') }}
  #}

  {%- if key_columns is none or key_columns | length == 0 -%}
    {{ exceptions.raise_compiler_error("generate_surrogate_key requires a non-empty list of key columns") }}
  {%- endif -%}

  {%- set normalized_columns = [] -%}
  {%- for key in key_columns -%}
    {%- do normalized_columns.append("coalesce(to_varchar(" ~ key ~ "), '')") -%}
  {%- endfor -%}

  {%- set hash_expression = "lower(md5(concat_ws('||', " ~ normalized_columns | join(", ") ~ ")))" -%}
  {{ return("'" ~ prefix ~ "' || " ~ hash_expression) }}
{% endmacro %}

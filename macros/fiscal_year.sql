{% macro fiscal_year(date_value, fiscal_year_start_month=1) %}
  {#
  Returns the fiscal year integer for a given date or timestamp expression.

  Args:
    date_value: A date or timestamp expression in Snowflake SQL.
    fiscal_year_start_month: Integer month when the fiscal year begins (1-12).

  Returns:
    A SQL expression that evaluates to the fiscal year.
  #}

  {%- set month_start = fiscal_year_start_month | int -%}
  {%- if month_start < 1 or month_start > 12 -%}
    {{ exceptions.raise_compiler_error("fiscal_year_start_month must be between 1 and 12") }}
  {%- endif -%}

  {%- set year_expr = "year(" ~ date_value ~ ")" -%}
  {%- set month_expr = "month(" ~ date_value ~ ")" -%}

  {%- if month_start == 1 -%}
    {{ return(year_expr) }}
  {%- else -%}
    {{ return("case when " ~ month_expr ~ " >= " ~ month_start ~ " then " ~ year_expr ~ " else " ~ year_expr ~ " - 1 end") }}
  {%- endif -%}
{% endmacro %}

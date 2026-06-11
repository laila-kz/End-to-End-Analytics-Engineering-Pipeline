{% macro convert_currency(amount, exchange_rate, scale=2, numeric_precision=38, numeric_scale=12) %}
  {#
  Converts a monetary amount using a given exchange rate.

  Args:
    amount: A numeric or numeric-compatible expression representing the source amount.
    exchange_rate: A numeric or numeric-compatible expression representing the conversion rate.
    scale: The number of decimal places to round the converted amount to.
    numeric_precision: Precision used when casting intermediate values.
    numeric_scale: Scale used when casting intermediate values.

  Returns:
    A Snowflake SQL expression that performs safe currency conversion and rounding.
  #}

  {%- set scale_int = scale | int -%}
  {%- if scale_int < 0 -%}
    {{ exceptions.raise_compiler_error("convert_currency scale must be a non-negative integer") }}
  {%- endif -%}

  {{ return("round(cast(" ~ amount ~ " as numeric(" ~ numeric_precision ~ ", " ~ numeric_scale ~ ")) * cast(" ~ exchange_rate ~ " as numeric(" ~ numeric_precision ~ ", " ~ numeric_scale ~ ")), " ~ scale_int ~ ")") }}
{% endmacro %}

{% macro clean_phone_number(phone_number, default_country_code='1') %}
  {#
  Normalizes a phone number string to digits only and optionally enforces a country code.

  Args:
    phone_number: A string expression containing the phone number.
    default_country_code: The country code to apply for 10-digit phone numbers.

  Returns:
    A Snowflake SQL expression that returns a normalized phone number string,
    or NULL if the value cannot be normalized.
  #}

  {%- set cleaned = "regexp_replace(" ~ phone_number ~ ", '[^0-9]+', '')" -%}
  {%- set country = default_country_code | string -%}

  {{ return(
    "case \
      when length(" ~ cleaned ~ ") = 11 and left(" ~ cleaned ~ ", 1) = '" ~ country ~ "' then " ~ cleaned ~ " \
      when length(" ~ cleaned ~ ") = 10 then '" ~ country ~ "' || " ~ cleaned ~ " \
      else null \
    end"
  ) }}
{% endmacro %}

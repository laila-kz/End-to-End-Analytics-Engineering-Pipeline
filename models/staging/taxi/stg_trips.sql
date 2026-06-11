-- =============================================================================
-- MODEL: stg_trips
-- LAYER:  Staging
-- PURPOSE: One row per raw taxi trip with standardized column names and types.
--          This layer performs only renaming, casting, and lightweight cleaning.
-- SOURCE: RAW.TAXI.TRIPS
-- GRAIN: One row per taxi trip
-- MATERIALIZATION: view
-- =============================================================================

with source_data as (
    select
        VARIANT_COL:"VendorID"::integer as vendorid,
        VARIANT_COL:"tpep_pickup_datetime"::bigint as tpep_pickup_datetime,
        VARIANT_COL:"tpep_dropoff_datetime"::bigint as tpep_dropoff_datetime,
        VARIANT_COL:"passenger_count"::integer as passenger_count,
        VARIANT_COL:"trip_distance"::float as trip_distance,
        VARIANT_COL:"RatecodeID"::integer as ratecodeid,
        VARIANT_COL:"store_and_fwd_flag"::varchar(1) as store_and_fwd_flag,
        VARIANT_COL:"PULocationID"::integer as pulocationid,
        VARIANT_COL:"DOLocationID"::integer as dolocationid,
        VARIANT_COL:"payment_type"::integer as payment_type,
        VARIANT_COL:"fare_amount"::numeric(10, 2) as fare_amount,
        VARIANT_COL:"extra"::numeric(10, 2) as extra,
        VARIANT_COL:"mta_tax"::numeric(10, 2) as mta_tax,
        VARIANT_COL:"tip_amount"::numeric(10, 2) as tip_amount,
        VARIANT_COL:"tolls_amount"::numeric(10, 2) as tolls_amount,
        VARIANT_COL:"improvement_surcharge"::numeric(10, 2) as improvement_surcharge,
        VARIANT_COL:"total_amount"::numeric(10, 2) as total_amount,
        VARIANT_COL:"congestion_surcharge"::numeric(10, 2) as congestion_surcharge,
        VARIANT_COL:"Airport_fee"::numeric(10, 2) as airport_fee,
        row_number() over (
          order by
            VARIANT_COL:"VendorID",
            VARIANT_COL:"tpep_pickup_datetime",
            VARIANT_COL:"tpep_dropoff_datetime",
            VARIANT_COL:"PULocationID",
            VARIANT_COL:"DOLocationID",
            VARIANT_COL:"fare_amount",
            VARIANT_COL:"tip_amount",
            VARIANT_COL:"total_amount"
        ) as row_num
    from {{ source('taxi', 'trips') }}
)

select
    concat('trip_', to_varchar(row_num)) as trip_key,
    vendorid as vendor_id,
    to_timestamp_ntz(tpep_pickup_datetime / 1000000) as pickup_at,
    to_timestamp_ntz(tpep_dropoff_datetime / 1000000) as dropoff_at,
    passenger_count as passenger_count,
    trip_distance as trip_distance_miles,
    ratecodeid as rate_code_id,
    store_and_fwd_flag as store_and_forward_flag,
    pulocationid as pickup_zone_id,
    dolocationid as dropoff_zone_id,
    payment_type as payment_code,
    fare_amount as fare_amount_usd,
    extra as extra_amount_usd,
    mta_tax as mta_tax_usd,
    tip_amount as tip_amount_usd,
    tolls_amount as tolls_amount_usd,
    improvement_surcharge as improvement_surcharge_usd,
    total_amount as total_amount_usd,
    congestion_surcharge as congestion_surcharge_usd,
    airport_fee as airport_fee_usd,
    cast(date_trunc('day', to_timestamp_ntz(tpep_pickup_datetime / 1000000)) as date) as pickup_date,
    cast(date_trunc('day', to_timestamp_ntz(tpep_dropoff_datetime / 1000000)) as date) as dropoff_date
from source_data
where tpep_pickup_datetime is not null
  and tpep_dropoff_datetime is not null
  and pulocationid is not null
  and dolocationid is not null

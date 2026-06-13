## dbt Project Data Model

### Entity Relationship Diagram (ASCII)

```
┌─────────────────────────┐
│       DIM_DATE          │
├─────────────────────────┤
│ PK  date_day            │
│     year                │
│     quarter             │
│     month               │
│     week                │
│     day_of_week         │
│     is_weekend          │
│     fiscal_year         │
└────────────┬────────────┘
             │
             │ pickup_date
             ▼
┌─────────────────────────────────────┐
│         FCT_TRIPS                   │
├─────────────────────────────────────┤
│ PK  trip_sk                         │
│ FK  pickup_date ──────► DIM_DATE    │
│ FK  pickup_zone_sk ┐                │
│ FK  dropoff_zone_sk├─► DIM_TAXI_ZONE
│     fare_amount_usd │                │
│     total_amount_usd │               │
│     tip_amount_usd   │               │
│     pickup_at        │               │
│     dropoff_at       │               │
│     passenger_count  │               │
│     trip_distance... │               │
└────────────┬─────────┘                │
             └─────────────────────────┘
             pickup_zone / dropoff_zone
             
┌─────────────────────────┐
│   DIM_TAXI_ZONE         │
├─────────────────────────┤
│ PK  taxi_zone_sk        │
│ UK  zone_id             │
│     zone_name           │
│     borough             │
│     service_zone        │
└─────────────────────────┘
```

### Model Hierarchy

| Layer | Model | Type | Purpose |
|-------|-------|------|---------|
| Staging | stg_trips | View | Raw taxi trip data cleaned & standardized |
| Staging | stg_taxi_zones | View | Zone reference data |
| Intermediate | int_trips_enriched | Table | Trips with zone & date lookups |
| Marts | fct_trips | Table | Fact table for trip analytics |
| Marts | dim_date | Table | Date dimension for temporal queries |
| Marts | dim_taxi_zone | Table | Location dimension for geographic analysis |


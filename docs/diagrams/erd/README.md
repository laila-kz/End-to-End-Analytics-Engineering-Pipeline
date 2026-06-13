# dbt Analytics Project - Entity Relationship Diagram

```mermaid
erDiagram
    DIM_DATE ||--o{ FCT_TRIPS : "fk_pickup_date"
    DIM_TAXI_ZONE ||--o{ FCT_TRIPS : "fk_pickup_zone"
    DIM_TAXI_ZONE ||--o{ FCT_TRIPS : "fk_dropoff_zone"

    DIM_DATE {
        date date_day PK
        int year
        int quarter
        int month
        int week
        int day_of_week
        boolean is_weekend
        int fiscal_year
    }

    FCT_TRIPS {
        string trip_sk PK
        date pickup_date FK
        int pickup_zone_sk FK
        int dropoff_zone_sk FK
        decimal fare_amount_usd
        decimal total_amount_usd
        decimal tip_amount_usd
        timestamp pickup_at
        timestamp dropoff_at
        int passenger_count
        float trip_distance_miles
    }

    DIM_TAXI_ZONE {
        int taxi_zone_sk PK
        int zone_id UK
        string zone_name
        string borough
        string service_zone
    }
```

## Diagram Description

**Three-Layer Star Schema:**

- **DIM_DATE** (Top) - Temporal dimension providing calendar attributes
- **FCT_TRIPS** (Center) - Fact table capturing taxi trip transactions
- **DIM_TAXI_ZONE** (Bottom) - Location dimension for pickup and dropoff zones

**Key Relationships:**
- One date can have many trips (pickup_date)
- One zone can be many pickup locations
- One zone can be many dropoff locations
- Each trip has exactly one pickup and dropoff zone


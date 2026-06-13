# Data Architecture Diagram

```mermaid
graph TD
    A["🗺️ NYC Taxi Data<br/>Parquet Files"] -->|Daily Load| B["📦 Raw Layer<br/>RAW.TAXI.TRIPS<br/>RAW.TAXI.ZONES"]
    
    B -->|dbt compile| C["🧹 Staging Layer<br/>stg_trips<br/>stg_taxi_zones<br/>stg_payment_types"]
    
    C -->|Data Enrichment| D["⚙️ Intermediate Layer<br/>int_trips_enriched<br/>Daily Aggregations"]
    
    D -->|Star Schema| E["⭐ Mart Layer"]
    
    E -->|Dimension Tables| F["📊 Dimensions<br/>dim_date<br/>dim_taxi_zone"]
    
    E -->|Fact Tables| G["💰 Facts<br/>fct_trips<br/>fct_daily_summary"]
    
    F -->|Analytics Ready| H["📈 Metabase Dashboard<br/>KPIs & Visualizations"]
    
    G -->|Analytics Ready| H

    style A fill:#e1f5ff,stroke:#01579b,stroke-width:2px,color:#000
    style B fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000
    style C fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000
    style D fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px,color:#000
    style E fill:#fce4ec,stroke:#880e4f,stroke-width:2px,color:#000
    style F fill:#f1f8e9,stroke:#33691e,stroke-width:2px,color:#000
    style G fill:#fff8e1,stroke:#f57f17,stroke-width:2px,color:#000
    style H fill:#e0f2f1,stroke:#004d40,stroke-width:2px,color:#000
```

## Architecture Details

### Source Layer
- **NYC Taxi Data** - External Parquet files (daily updates from TLC dataset)

### Raw Layer
- **RAW.TAXI.TRIPS** - 55M+ records, VARIANT column structure
- **RAW.TAXI.ZONES** - 263 lookup records, reference data

### Staging Layer (View)
- `stg_trips` - Standardized trip records with consistent naming
- `stg_taxi_zones` - Cleaned zone reference data
- `stg_payment_types` - Payment type lookup

### Intermediate Layer (Table)
- `int_trips_enriched` - Trips with zone and date lookups pre-joined
- Business logic and enrichment applied
- Single source of truth for trip facts

### Mart Layer (Star Schema)
**Dimensions:**
- `dim_date` - 10+ years of calendar data with fiscal year logic
- `dim_taxi_zone` - 263 zones with surrogate keys

**Facts:**
- `fct_trips` - 55M+ trip transactions with revenue metrics
- `fct_daily_summary` - Daily aggregated metrics by zone and payment type

### Analytics Layer
- **Metabase** - Business intelligence dashboards
- KPIs, trends, geographic analysis
- Real-time query capability


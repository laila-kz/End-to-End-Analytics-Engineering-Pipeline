# Data Architecture & Schema Documentation

This folder contains all architectural and schema diagrams for the NYC Taxi Analytics dbt project.

## 📋 Contents

### 1. [Data Architecture](./architecture/)
**File:** `architecture.png`

Vertical flow diagram showing the complete data pipeline:
- **Source:** NYC Taxi Data (Parquet files)
- **Raw Layer:** RAW.TAXI.TRIPS, RAW.TAXI.ZONES
- **Staging Layer:** Data cleaning and standardization
- **Intermediate Layer:** Business logic and enrichment
- **Mart Layer:** Star schema with dimensions and facts
- **Analytics:** Metabase dashboard

**Best for:** Presentations, README, technical documentation

---

### 2. [Entity Relationship Diagram (ERD)](./erd/)
**File:** `erd.png`

Star schema design showing table relationships:
- **DIM_DATE** - Calendar dimension (10+ years)
- **DIM_TAXI_ZONE** - Geographic dimension (263 zones)
- **FCT_TRIPS** - Core fact table (55M+ transactions)

Includes primary keys (PK), foreign keys (FK), and key attributes.

**Best for:** Database design review, stakeholder meetings, portfolio

---

### 3. [Data Model Overview](./data-model/)
**File:** `README.md`

Text-based documentation including:
- ASCII ERD diagram
- Layer hierarchy table
- Model descriptions
- Column definitions

**Best for:** Quick reference, README, documentation

---

## 🎯 Usage

**For GitHub README:**
```markdown
## Data Architecture

![Architecture Diagram](./docs/diagrams/architecture/architecture.png)

![Entity Relationship Diagram](./docs/diagrams/erd/erd.png)
```

**For Presentations:**
- Use `architecture.png` for end-to-end pipeline overview
- Use `erd.png` for technical deep-dives

**For Portfolio:**
- Include all three diagrams
- Link from main README
- Demonstrates analytical engineering best practices

---

## 📊 Model Statistics

| Layer | Model / Asset Count | Purpose |
|---|---|---|
| Seeds | 2 | Static lookup tables (zones, payment types) |
| Staging | 2 | Data cleaning & standardization |
| Intermediate | 1 | Enrichment & join logic |
| Marts | 4 | Dimensional & fact tables |
| **Total** | **7 Models + 2 Seeds** | **Analytics-ready tables** |

---

## 🔗 Related Documentation

- [`README.md`](../../README.md) - Project overview
- [`dbt_project.yml`](../../dbt_project.yml) - dbt configuration
- [`models/`](../../models/) - Model source code
- [`tests/`](../../tests/) - dbt tests


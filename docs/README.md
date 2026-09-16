# Documentation

Complete documentation for the NYC Taxi Analytics dbt project, organized by category.

## 📚 Sections

### 🏗️ [Architecture & Diagrams](./diagrams/)
- **Data Architecture Flow** - End-to-end pipeline visualization
- **Entity Relationship Diagram** - Star schema design
- **Data Model Overview** - Table hierarchy and definitions

### 📖 Project Documentation
- `README.md` - Project overview and setup
- `dbt_project.yml` - dbt configuration
- `packages.yml` - dbt package dependencies
- `requirements.txt` - Python dependencies

### 📝 Models Documentation
Located in `models/`:
- `staging/` - Raw data transformations
- `intermediate/` - Business logic and enrichment
- `marts/` - Analytics-ready tables

Each model includes:
- YAML schema definitions
- Column descriptions
- Data quality tests
- Freshness checks

### 🧪 Tests & Quality
- `tests/` - Custom dbt tests
- `dbt_project_evaluator/` - Project quality checks
- 52 declared data tests across all models (+ package evaluator checks)
- 100% test pass rate

### 🎨 Generated Artifacts
- `dbt docs/` - dbt documentation site
- `target/` - Compiled SQL and artifacts
- `logs/` - dbt execution logs

---

## 🚀 Quick Start

1. **View Architecture:**
   - See `diagrams/architecture/architecture.png`

2. **Explore Schema:**
   - See `diagrams/erd/erd.png`

3. **Understand Models:**
   - See `diagrams/data-model/README.md`

4. **Run dbt Commands:**
   ```bash
   dbt build
   dbt docs generate
   ```

---

## 📊 Key Metrics

- **Models:** 7 production models
- **Seeds:** 2 lookup seeds (taxi_zones, stg_payment_types)
- **Tests:** 52 declared data tests (+ package evaluator checks)
- **Sources:** 1 (NYC Taxi source)
- **Exposures:** 1 (Metabase dashboard)
- **Macros:** 3 (fiscal_year, generate_surrogate_key, generate_schema_name)
- **Documentation Coverage:** 100%

---

## 🔗 Navigation

```
project-root/
├── docs/                           # Documentation and diagrams
│   ├── dashboard/                  # Dashboard screenshots and exports
│   ├── diagrams/                   # Visual diagrams
│   │   ├── architecture/           # Data pipeline flow
│   │   ├── erd/                    # Entity relationships
│   │   └── data-model/             # Model hierarchy
│   └── README.md                   # Documentation index
├── macros/                         # SQL macros
├── models/                         # SQL models (staging, intermediate, marts)
├── seeds/                          # Lookup tables
├── tests/                          # dbt tests
├── dbt_project.yml                 # Configuration
├── packages.yml                    # Package dependencies
├── requirements.txt                # Python dependencies
└── README.md                       # Main project README
```


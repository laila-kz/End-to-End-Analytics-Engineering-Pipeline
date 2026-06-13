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
Located in `first_project/models/`:
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
- 86 data tests across all models
- 100% test pass rate

### 🎨 Generated Artifacts
- `dbt docs/` - dbt documentation site
- `target/` - Compiled SQL and artifacts
- `logs/` - dbt execution logs

---

## 🚀 Quick Start

1. **View Architecture:**
   - See `diagrams/architecture/ARCHITECTURE.png`

2. **Explore Schema:**
   - See `diagrams/erd/ERD.png`

3. **Understand Models:**
   - See `diagrams/data-model/README.md`

4. **Run dbt Commands:**
   ```bash
   cd first_project
   dbt run
   dbt test
   dbt docs generate
   ```

---

## 📊 Key Metrics

- **Models:** 8 production + 47 evaluator models
- **Tests:** 86 total tests with 100% pass rate
- **Sources:** 1 (NYC Taxi source)
- **Exposures:** 1 (Metabase dashboard)
- **Macros:** 3 (fiscal_year, generate_surrogate_key, generate_schema_name)
- **Documentation Coverage:** 100%

---

## 🔗 Navigation

```
project-root/
├── docs/                           # This folder
│   ├── diagrams/                   # Visual diagrams
│   │   ├── architecture/           # Data pipeline flow
│   │   ├── erd/                    # Entity relationships
│   │   └── data-model/             # Model hierarchy
│   └── README.md                   # Documentation index
├── first_project/                  # dbt project
│   ├── models/                     # SQL models
│   ├── tests/                      # dbt tests
│   ├── macros/                     # SQL macros
│   ├── seeds/                      # Lookup tables
│   └── dbt_project.yml             # Configuration
├── README.md                       # Main project README
└── [other files]
```


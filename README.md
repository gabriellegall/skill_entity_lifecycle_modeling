A dbt-core demonstration repository showcasing **lifecycle event modeling** approaches using DuckDB.

This project implements strategies for modeling entity lifecycles—tracking how users transition between states (active/inactive) over time—with perfectly reconciled metrics for business reporting.

## Quick Start

### Prerequisites

- Python 3.10+
- dbt-core (~1.10+)
- DuckDB (via dbt-duckdb)

### Setup

1. **Activate the virtual environment:**
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the project:**
   ```bash
   dbt build
   ```

## Two Approaches

This project implements **two different strategies** for modeling entity lifecycles:

1. **Daily events** (`approach_daily_events/`) — Classifies movements at daily granularity; ideal for operational dashboards and real-time event tracking.
2. **Period snapshots** (`approach_period_snapshots/`) — Defines movements between snapshot periods (day/week/month/quarter/year) with perfectly reconciled metrics; ideal for executive reporting and financial reconciliation.

Both solve the same core challenge: ensuring that acquisition, churn, and resurrection metrics sum to a valid ledger. See the companion article for the full methodology.

## Skill

A reusable skill is available at `.skill/lifecycle_modeling.skill.md` so any LLM can apply the same lifecycle modeling methodology across projects.
This skill is based on the **Period snapshots** methodology, which is more reliable when aggregating movements for business monitoring needs and should generally be preferred.

## Project Structure

```
models/
├── staging/
│   └── stg_seed__subscription_status.sql     
├── intermediate/
│   ├── approach_daily_events/                # Approach 1: Simple daily-grain event tracking
│   │   ├── int_user_status_movements_daily.sql
│   │   └── int_user_status_metrics_daily.sql
│   └── approach_period_snapshots/            # Approach 2: Multi-grain snapshots (week/month/quarter/year)
│       ├── int_user_status_snapshots_period.sql
│       ├── int_user_status_snapshots_period_agg_movements.sql
│       └── int_user_status_snapshots_period_agg_metrics.sql
seeds/
└── raw_seed__subscription_status.csv         # Sample data
tests/
└── approach_period_snapshots/                # Custom reconciliation tests
```

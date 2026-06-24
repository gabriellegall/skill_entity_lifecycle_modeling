---
applyTo: "models/**/*.sql"
description: "dbt SQL style for this repo"
---

- Write SQL keywords and column names in UPPERCASE.
  - This includes: column aliases (AS COLUMN_NAME), all column references in SELECT/WHERE/ORDER BY/PARTITION BY clauses, and all CTE column selections.
  - Example: `SELECT user_id AS USER_ID, status AS STATUS` (raw columns lowercase, aliases UPPERCASE).
- Keep CTE names lowercase (e.g., `WITH source AS (...)`, `, churned AS (...)`).
- Use leading commas before each CTE after the first, for example `WITH source AS (...)` then `, periodized AS (...)`.
- Always have 1 line of code per column (no line break) except for CASE WHEN statements.
- Preserve the existing dbt Jinja style and avoid changing model semantics when formatting only.

{{ config(materialized='view') }}

WITH weekly AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period__weekly') }}
)

, monthly AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period__monthly') }}
)

, quarterly AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period__quarterly') }}
)

, yearly AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period__yearly') }}
)

SELECT * FROM weekly
UNION ALL
SELECT * FROM monthly
UNION ALL
SELECT * FROM quarterly
UNION ALL
SELECT * FROM yearly

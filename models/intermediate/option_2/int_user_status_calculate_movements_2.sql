{{ config(materialized='view') }}

WITH period_snapshot AS (
    SELECT * FROM {{ ref('int_user_status_build_snapshots') }}
)

, status_change AS (
    SELECT
        USER_ID,
        TIME_PERIOD_END,
        TIME_GRAIN,
        IS_ACTIVE,
        FIRST_ACQUISITION_DATE_INFO,
        FIRST_CHURN_DATE_INFO,
        FIRST_RESURRECTION_DATE_INFO,
        LAG(IS_ACTIVE) OVER (PARTITION BY USER_ID, TIME_GRAIN ORDER BY TIME_PERIOD_END) AS PREVIOUS_IS_ACTIVE
    FROM period_snapshot
)

, events AS (
    SELECT
        *,
        CASE 
            WHEN FIRST_ACQUISITION_DATE_INFO IS NOT NULL AND IS_ACTIVE = TRUE THEN 'acquisition'
            WHEN PREVIOUS_IS_ACTIVE = TRUE  AND IS_ACTIVE = FALSE THEN 'churn'
            WHEN PREVIOUS_IS_ACTIVE = FALSE AND IS_ACTIVE = TRUE  THEN 'resurrection'
        END AS EVENT_TYPE,
        EVENT_TYPE = 'acquisition'  AS IS_ACQUIRED,
        EVENT_TYPE = 'churn'        AS IS_CHURNED,
        EVENT_TYPE = 'resurrection' AS IS_RESURRECTED
    FROM status_change
)

SELECT
    USER_ID,
    TIME_PERIOD_END,
    TIME_GRAIN,
    EVENT_TYPE,
    FIRST_ACQUISITION_DATE_INFO,
    FIRST_CHURN_DATE_INFO,
    FIRST_RESURRECTION_DATE_INFO,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM events
WHERE EVENT_TYPE IS NOT NULL
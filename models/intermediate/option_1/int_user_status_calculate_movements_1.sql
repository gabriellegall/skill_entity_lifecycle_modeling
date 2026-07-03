{{ config(materialized='view') }}

WITH status_change AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE,
        PREVIOUS_IS_ACTIVE,
        IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM {{ ref('stg_seed__subscription_status') }}
)

, events AS (
    SELECT
        *,
        CASE 
            WHEN IS_FIRST_USER_ACTIVE_DATE_INFO = TRUE THEN 'acquisition'
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
    DATE_INFO,
    EVENT_TYPE,
    IS_ACTIVE,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM events
WHERE EVENT_TYPE IS NOT NULL -- Only keep movements
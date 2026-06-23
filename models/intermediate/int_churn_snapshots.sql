{{ config(materialized='view') }}

{% set time_grains = ['week', 'month', 'quarter', 'year'] %}

WITH source AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE
    FROM {{ ref('stg_seed__subscription_status') }}
)
, periodized AS (
    {% for grain in time_grains %}
        SELECT
            USER_ID,
            CAST(DATE_TRUNC('{{ grain }}', DATE_INFO) AS DATE) AS TIME_PERIOD,
            '{{ grain }}' AS TIME_GRAIN,
            IS_ACTIVE
        FROM source
        WHERE DATE_INFO = TIME_PERIOD
        {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
)
, status_change AS (
    SELECT
        *,
        LAG(IS_ACTIVE) OVER (
            PARTITION BY USER_ID, TIME_GRAIN
            ORDER BY TIME_PERIOD
        ) AS PREVIOUS_IS_ACTIVE
    FROM periodized
)
, events AS (
    SELECT
        *,
        CASE 
            WHEN PREVIOUS_IS_ACTIVE = TRUE AND IS_ACTIVE = FALSE THEN 'churn'
            WHEN PREVIOUS_IS_ACTIVE IS NULL AND IS_ACTIVE = TRUE THEN 'acquisition'
            WHEN PREVIOUS_IS_ACTIVE = FALSE AND IS_ACTIVE = TRUE THEN 'resurrection'
        END AS EVENT_TYPE,
        EVENT_TYPE = 'churn' AS IS_CHURNED,
        EVENT_TYPE = 'resurrection' AS IS_RESURRECTED,
        EVENT_TYPE = 'acquisition' AS IS_ACQUIRED
    FROM status_change
)

SELECT
    USER_ID,
    TIME_PERIOD,
    TIME_GRAIN,
    EVENT_TYPE,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM events
WHERE EVENT_TYPE IS NOT NULL
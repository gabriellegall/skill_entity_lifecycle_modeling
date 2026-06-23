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
        WHERE DATE_INFO = CAST(DATE_TRUNC('{{ grain }}', DATE_INFO) AS DATE)
        {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
)
, status_change AS (
    SELECT
        USER_ID,
        TIME_PERIOD,
        TIME_GRAIN,
        IS_ACTIVE,
        LAG(IS_ACTIVE) OVER (
            PARTITION BY USER_ID, TIME_GRAIN
            ORDER BY TIME_PERIOD
        ) AS PREVIOUS_IS_ACTIVE
    FROM periodized
)
, churn_events AS (
    SELECT
        USER_ID,
        TIME_PERIOD,
        TIME_GRAIN,
        'churn' AS EVENT_TYPE,
        TRUE AS IS_CHURNED,
        FALSE AS IS_RESURRECTED,
        FALSE AS IS_ACQUIRED
    FROM status_change
    WHERE
        PREVIOUS_IS_ACTIVE = TRUE
        AND IS_ACTIVE = FALSE
)
, acquisition_events AS (
    SELECT
        USER_ID,
        TIME_PERIOD,
        TIME_GRAIN,
        'acquisition' AS EVENT_TYPE,
        FALSE AS IS_CHURNED,
        FALSE AS IS_RESURRECTED,
        TRUE AS IS_ACQUIRED
    FROM status_change
    WHERE
        PREVIOUS_IS_ACTIVE IS NULL
        AND IS_ACTIVE = TRUE
)
, resurrection_events AS (
    SELECT
        USER_ID,
        TIME_PERIOD,
        TIME_GRAIN,
        'resurrection' AS EVENT_TYPE,
        FALSE AS IS_CHURNED,
        TRUE AS IS_RESURRECTED,
        FALSE AS IS_ACQUIRED
    FROM status_change
    WHERE
        PREVIOUS_IS_ACTIVE = FALSE
        AND IS_ACTIVE = TRUE
)

SELECT
    USER_ID,
    TIME_PERIOD,
    TIME_GRAIN,
    EVENT_TYPE,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM churn_events

UNION ALL

SELECT
    USER_ID,
    TIME_PERIOD,
    TIME_GRAIN,
    EVENT_TYPE,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM acquisition_events

UNION ALL

SELECT
    USER_ID,
    TIME_PERIOD,
    TIME_GRAIN,
    EVENT_TYPE,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM resurrection_events
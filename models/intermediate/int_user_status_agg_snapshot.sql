{{ config(materialized='table') }}

{% set time_grains = ['week', 'month', 'quarter', 'year'] %}

WITH source AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE
    FROM {{ ref('stg_seed__subscription_status') }}
)
, period_snapshot AS (
    {% for grain in time_grains %}
        SELECT
            USER_ID,
            CAST(DATE_TRUNC('{{ grain }}', DATE_INFO) AS DATE) AS TIME_PERIOD,
            '{{ grain }}' AS TIME_GRAIN,
            IS_ACTIVE
        FROM source
        WHERE DATE_INFO = TIME_PERIOD -- Keep each period snapshot date only
        {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
)
, period_snapshot_with_previous AS (
    SELECT
        USER_ID,
        TIME_PERIOD,
        TIME_GRAIN,
        IS_ACTIVE,
        CASE
            WHEN TIME_GRAIN = 'week'    THEN TIME_PERIOD - INTERVAL 7 DAY
            WHEN TIME_GRAIN = 'month'   THEN TIME_PERIOD - INTERVAL 1 MONTH
            WHEN TIME_GRAIN = 'quarter' THEN TIME_PERIOD - INTERVAL 3 MONTH
            WHEN TIME_GRAIN = 'year'    THEN TIME_PERIOD - INTERVAL 1 YEAR
        END AS PREVIOUS_TIME_PERIOD
    FROM period_snapshot
)

SELECT * FROM period_snapshot_with_previous

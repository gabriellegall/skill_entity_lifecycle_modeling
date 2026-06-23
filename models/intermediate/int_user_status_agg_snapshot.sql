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
        WHERE DATE_INFO = TIME_PERIOD
        {% if not loop.last %}UNION ALL{% endif %}
    {% endfor %}
)

SELECT * FROM period_snapshot

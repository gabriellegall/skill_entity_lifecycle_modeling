-- Test to ensure each user has continuous snapshot dates with no gaps
-- For each time grain (week, month, quarter, year), each user should have a consecutive sequence
-- Compare actual previous period with expected previous period based on grain

WITH period_snapshot AS (
    SELECT * FROM {{ ref('int_user_status_agg_snapshot') }}
)
, periods_with_lag AS (
    SELECT
        USER_ID,
        TIME_GRAIN,
        TIME_PERIOD,
        LAG(TIME_PERIOD) OVER (PARTITION BY USER_ID, TIME_GRAIN ORDER BY TIME_PERIOD) AS actual_prev_period,
        CASE
            WHEN TIME_GRAIN = 'week'    THEN TIME_PERIOD - INTERVAL 7 DAY
            WHEN TIME_GRAIN = 'month'   THEN TIME_PERIOD - INTERVAL 1 MONTH
            WHEN TIME_GRAIN = 'quarter' THEN TIME_PERIOD - INTERVAL 3 MONTH
            WHEN TIME_GRAIN = 'year'    THEN TIME_PERIOD - INTERVAL 1 YEAR
        END AS expected_prev_period
    FROM period_snapshot
)

SELECT
    USER_ID,
    TIME_GRAIN,
    TIME_PERIOD,
    actual_prev_period,
    expected_prev_period
FROM periods_with_lag
WHERE actual_prev_period IS NOT NULL
    AND actual_prev_period != expected_prev_period

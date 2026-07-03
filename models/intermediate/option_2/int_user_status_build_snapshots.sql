{{ config(materialized='table') }}

WITH source AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE,
        PREVIOUS_IS_ACTIVE,
        IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM {{ ref('stg_seed__subscription_status') }}
)

, data_cutoff AS (
    SELECT
        MAX(DATE_INFO) AS MAX_AVAILABLE_DATE_INFO
    FROM source
)

-- Define each time grain
, transition_periods AS (
    SELECT
        S.USER_ID,
        CAST(DATE_TRUNC(G.TIME_GRAIN, S.DATE_INFO) AS DATE) AS TIME_PERIOD_START,
        CAST(CASE
            WHEN G.TIME_GRAIN = 'week'    THEN CAST(DATE_TRUNC('week', S.DATE_INFO) AS DATE) + INTERVAL 6 DAY
            WHEN G.TIME_GRAIN = 'month'   THEN LAST_DAY(S.DATE_INFO)
            WHEN G.TIME_GRAIN = 'quarter' THEN CAST(DATE_TRUNC('quarter', S.DATE_INFO) AS DATE) + INTERVAL 3 MONTH - INTERVAL 1 DAY
            WHEN G.TIME_GRAIN = 'year'    THEN MAKE_DATE(YEAR(S.DATE_INFO), 12, 31)
        END AS DATE) AS TIME_PERIOD_END,
        G.TIME_GRAIN,
        S.DATE_INFO,
        S.PREVIOUS_IS_ACTIVE,
        S.IS_ACTIVE,
        S.IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM source S
    CROSS JOIN (VALUES
        ('week'),
        ('month'),
        ('quarter'),
        ('year')
    ) AS G(TIME_GRAIN)
    CROSS JOIN data_cutoff C
    WHERE TIME_PERIOD_END <= C.MAX_AVAILABLE_DATE_INFO -- Only keep full periods for each time grain
)

-- For each time grain, find the first event or each kind, at get the end of the period status
, period_lifecycle_date_arrays AS (
    SELECT
        USER_ID,
        TIME_PERIOD_START,
        TIME_PERIOD_END,
        CAST(TIME_PERIOD_START - INTERVAL 1 DAY AS DATE) AS PREVIOUS_TIME_PERIOD_END, -- Useful for data quality tests
        TIME_GRAIN,
        MAX(CASE WHEN DATE_INFO = TIME_PERIOD_END THEN IS_ACTIVE ELSE NULL END)                                                                      AS IS_ACTIVE_PERIOD_END, 
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE IS_FIRST_USER_ACTIVE_DATE_INFO = TRUE)                                                  AS ALL_ACQUISITION_DATE_INFO,
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE PREVIOUS_IS_ACTIVE = TRUE AND IS_ACTIVE = FALSE)                                        AS ALL_CHURN_DATE_INFO,
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE PREVIOUS_IS_ACTIVE = FALSE AND IS_ACTIVE = TRUE AND IS_FIRST_USER_ACTIVE_DATE_INFO = FALSE) AS ALL_RESURRECTION_DATE_INFO
    FROM transition_periods
    GROUP BY USER_ID, TIME_PERIOD_START, TIME_PERIOD_END, TIME_GRAIN
)

SELECT
    USER_ID,
    TIME_PERIOD_START,
    TIME_PERIOD_END,
    PREVIOUS_TIME_PERIOD_END,
    TIME_GRAIN,
    IS_ACTIVE_PERIOD_END,
    -- Acquisition
    ALL_ACQUISITION_DATE_INFO,
    LIST_COUNT(ALL_ACQUISITION_DATE_INFO)       AS NB_ACQUISITION_DATE_INFO,
    LIST_EXTRACT(ALL_ACQUISITION_DATE_INFO, 1)  AS FIRST_ACQUISITION_DATE_INFO,
    -- Churn
    ALL_CHURN_DATE_INFO,
    -LIST_COUNT(ALL_CHURN_DATE_INFO)            AS NB_CHURN_DATE_INFO,
    LIST_EXTRACT(ALL_CHURN_DATE_INFO, 1)        AS FIRST_CHURN_DATE_INFO,
    -- Resurrection
    ALL_RESURRECTION_DATE_INFO,
    LIST_COUNT(ALL_RESURRECTION_DATE_INFO)      AS NB_RESURRECTION_DATE_INFO,
    LIST_EXTRACT(ALL_RESURRECTION_DATE_INFO, 1) AS FIRST_RESURRECTION_DATE_INFO
FROM period_lifecycle_date_arrays
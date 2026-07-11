{{ config(materialized='view') }}

WITH period_movements AS (
    SELECT
        TIME_PERIOD_END,
        TIME_GRAIN,
        COUNT_IF(EVENT_TYPE = 'acquisition')  AS NB_ACQUIRED_USERS,
        -COUNT_IF(EVENT_TYPE = 'churn')       AS NB_CHURNED_USERS,
        COUNT_IF(EVENT_TYPE = 'resurrection') AS NB_RESURRECTED_USERS
    FROM {{ ref('int_user_status_snapshots_period_agg_movements') }}
    GROUP BY 1, 2
)

, period_active_base AS (
    SELECT
        TIME_PERIOD_END,
        TIME_GRAIN,
        COUNT_IF(IS_ACTIVE_PERIOD_END) AS NB_ACTIVE_USERS_PERIOD_END
    FROM {{ ref('int_user_status_snapshots_period') }}
    GROUP BY 1, 2
)

, period_metrics AS (
    SELECT
        BASE.TIME_PERIOD_END,
        BASE.TIME_GRAIN,
        COALESCE(LAG(BASE.NB_ACTIVE_USERS_PERIOD_END) OVER (PARTITION BY BASE.TIME_GRAIN ORDER BY BASE.TIME_PERIOD_END), 0) AS NB_ACTIVE_USERS_PREVIOUS_PERIOD_END,
        COALESCE(MV.NB_ACQUIRED_USERS, 0)                                                                                    AS NB_ACQUIRED_USERS,
        COALESCE(MV.NB_CHURNED_USERS, 0)                                                                                     AS NB_CHURNED_USERS,
        COALESCE(MV.NB_RESURRECTED_USERS, 0)                                                                                 AS NB_RESURRECTED_USERS,
        BASE.NB_ACTIVE_USERS_PERIOD_END
    FROM period_active_base AS BASE
    LEFT JOIN period_movements AS MV
        ON MV.TIME_PERIOD_END = BASE.TIME_PERIOD_END AND MV.TIME_GRAIN = BASE.TIME_GRAIN
)

SELECT
    TIME_PERIOD_END,
    TIME_GRAIN,
    NB_ACTIVE_USERS_PREVIOUS_PERIOD_END,
    NB_ACQUIRED_USERS,
    NB_CHURNED_USERS,
    NB_RESURRECTED_USERS,
    NB_ACTIVE_USERS_PERIOD_END
FROM period_metrics
ORDER BY TIME_GRAIN, TIME_PERIOD_END ASC

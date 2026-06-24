WITH period_snapshot AS (
    SELECT * FROM {{ ref('int_user_status_build_snapshots') }}
)

, active_users_by_period AS (
    SELECT
        TIME_GRAIN,
        TIME_PERIOD_END,
        PREVIOUS_TIME_PERIOD_END,
        COUNT_IF(IS_ACTIVE) AS NB_ACTIVE_USERS_END_PERIOD
    FROM period_snapshot
    GROUP BY 1, 2, 3
)

, movement_by_period AS (
    SELECT
        TIME_GRAIN,
        TIME_PERIOD_END,
        COUNT_IF(EVENT_TYPE = 'acquisition')  AS NB_ACQUIRED_USERS,
        COUNT_IF(EVENT_TYPE = 'churn')        AS NB_CHURNED_USERS,
        COUNT_IF(EVENT_TYPE = 'resurrection') AS NB_RESURRECTED_USERS
    FROM {{ ref('int_user_status_calculate_movements') }}
    GROUP BY 1, 2
)

, current_with_previous AS (
    SELECT
        cur.TIME_GRAIN,
        cur.TIME_PERIOD_END,
        -- Total users
        cur.NB_ACTIVE_USERS_END_PERIOD,
        COALESCE(prev.NB_ACTIVE_USERS_END_PERIOD, 0) AS NB_ACTIVE_USERS_BEGINNING_PERIOD,
        -- Movements
        COALESCE(mv.NB_ACQUIRED_USERS, 0)            AS NB_ACQUIRED_USERS,
        COALESCE(mv.NB_CHURNED_USERS, 0)             AS NB_CHURNED_USERS,
        COALESCE(mv.NB_RESURRECTED_USERS, 0)         AS NB_RESURRECTED_USERS
    FROM active_users_by_period AS cur
    LEFT JOIN active_users_by_period AS prev
        ON prev.TIME_GRAIN = cur.TIME_GRAIN
        AND prev.TIME_PERIOD_END = cur.PREVIOUS_TIME_PERIOD_END
    LEFT JOIN movement_by_period AS mv
        ON mv.TIME_GRAIN = cur.TIME_GRAIN
        AND mv.TIME_PERIOD_END = cur.TIME_PERIOD_END
)

SELECT
    TIME_GRAIN,
    TIME_PERIOD_END,
    NB_ACTIVE_USERS_BEGINNING_PERIOD,
    NB_ACQUIRED_USERS,
    NB_CHURNED_USERS,
    NB_RESURRECTED_USERS,
    NB_ACTIVE_USERS_END_PERIOD
FROM current_with_previous
-- Equation expected to hold true for all periods and grains, if not, return the rows that violate the identity
WHERE NOT NB_ACTIVE_USERS_BEGINNING_PERIOD + NB_ACQUIRED_USERS - NB_CHURNED_USERS + NB_RESURRECTED_USERS = NB_ACTIVE_USERS_END_PERIOD
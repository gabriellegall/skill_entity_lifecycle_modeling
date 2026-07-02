WITH current_with_previous AS (
    SELECT
        TIME_GRAIN,
        TIME_PERIOD_END,
        NB_ACTIVE_USERS_PREVIOUS_END_PERIOD,
        NB_ACQUIRED_USERS,
        NB_CHURNED_USERS,
        NB_RESURRECTED_USERS,
        NB_ACTIVE_USERS_END_PERIOD
    FROM {{ ref('int_user_status_period_metrics') }}
)

SELECT
    TIME_GRAIN,
    TIME_PERIOD_END,
    NB_ACTIVE_USERS_PREVIOUS_END_PERIOD,
    NB_ACQUIRED_USERS,
    NB_CHURNED_USERS,
    NB_RESURRECTED_USERS,
    NB_ACTIVE_USERS_END_PERIOD
FROM current_with_previous
-- Equation expected to hold true for all periods and grains, if not, return the rows that violate the identity
WHERE NOT NB_ACTIVE_USERS_PREVIOUS_END_PERIOD + NB_ACQUIRED_USERS + NB_CHURNED_USERS + NB_RESURRECTED_USERS = NB_ACTIVE_USERS_END_PERIOD
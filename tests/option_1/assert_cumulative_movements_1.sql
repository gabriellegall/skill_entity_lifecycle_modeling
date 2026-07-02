WITH current_with_previous AS (
    SELECT
        DATE_INFO,
        NB_ACTIVE_USERS_PREVIOUS_DATE_INFO,
        NB_ACQUIRED_USERS,
        NB_CHURNED_USERS,
        NB_RESURRECTED_USERS,
        NB_ACTIVE_USERS_DATE_INFO
    FROM {{ ref('int_user_status_daily_metrics') }}
)

SELECT
    DATE_INFO,
    NB_ACTIVE_USERS_PREVIOUS_DATE_INFO,
    NB_ACQUIRED_USERS,
    NB_CHURNED_USERS,
    NB_RESURRECTED_USERS,
    NB_ACTIVE_USERS_DATE_INFO
FROM current_with_previous
-- If cumulative movements are consistent, this identity should hold for every day.
WHERE NOT NB_ACTIVE_USERS_PREVIOUS_DATE_INFO + NB_ACQUIRED_USERS + NB_CHURNED_USERS + NB_RESURRECTED_USERS = NB_ACTIVE_USERS_DATE_INFO

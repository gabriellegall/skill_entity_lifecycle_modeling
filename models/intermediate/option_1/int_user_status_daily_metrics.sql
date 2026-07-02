{{ config(materialized='view') }}

WITH period_snapshot AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE
    FROM {{ ref('stg_seed__subscription_status') }}
)

, daily_user_base AS (
    SELECT
        DATE_INFO,
        COUNT(*)            AS NB_USERS_END_DAY,
        COUNT_IF(IS_ACTIVE) AS NB_ACTIVE_USERS_END_DAY
    FROM period_snapshot
    GROUP BY 1
)

, daily_movements AS (
    SELECT
        DATE_INFO,
        COUNT_IF(EVENT_TYPE = 'acquisition')  AS NB_ACQUIRED_USERS,
        -COUNT_IF(EVENT_TYPE = 'churn')       AS NB_CHURNED_USERS,
        COUNT_IF(EVENT_TYPE = 'resurrection') AS NB_RESURRECTED_USERS
    FROM {{ ref('int_user_status_calculate_movements_1') }}
    GROUP BY 1
)

, daily_metrics AS (
    SELECT
        BASE.DATE_INFO,
        BASE.NB_USERS_END_DAY,
        BASE.NB_ACTIVE_USERS_END_DAY,
        COALESCE(LAG(BASE.NB_ACTIVE_USERS_END_DAY) OVER (ORDER BY BASE.DATE_INFO), 0) AS NB_ACTIVE_USERS_PREVIOUS_DAY,
        COALESCE(MV.NB_ACQUIRED_USERS, 0)                                             AS NB_ACQUIRED_USERS,
        COALESCE(MV.NB_CHURNED_USERS, 0)                                              AS NB_CHURNED_USERS,
        COALESCE(MV.NB_RESURRECTED_USERS, 0)                                          AS NB_RESURRECTED_USERS
    FROM daily_user_base AS BASE
    LEFT JOIN daily_movements AS MV
        ON MV.DATE_INFO = BASE.DATE_INFO
)

SELECT
    DATE_INFO,
    NB_USERS_END_DAY,
    NB_ACTIVE_USERS_PREVIOUS_DAY,
    NB_ACQUIRED_USERS,
    NB_CHURNED_USERS,
    NB_RESURRECTED_USERS,
    NB_ACTIVE_USERS_END_DAY
FROM daily_metrics
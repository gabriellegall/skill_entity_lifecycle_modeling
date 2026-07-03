{{ config(materialized='view') }}

SELECT
    CAST(USER_ID AS INTEGER)                                      AS USER_ID,
    CAST(DATE_INFO AS DATE)                                       AS DATE_INFO,
    CAST(STATUS AS VARCHAR)                                       AS STATUS,
    STATUS = 'active'                                             AS IS_ACTIVE,
    LAG(IS_ACTIVE) OVER (PARTITION BY USER_ID ORDER BY DATE_INFO) AS PREVIOUS_IS_ACTIVE,
    CASE
        -- Return TRUE for the first IS_ACTIVE = TRUE at USER_ID level:
        WHEN MIN(CASE WHEN IS_ACTIVE THEN DATE_INFO ELSE NULL END) OVER (PARTITION BY USER_ID) = DATE_INFO THEN TRUE
        ELSE FALSE
    END AS IS_FIRST_USER_ACTIVE_DATE_INFO
FROM {{ ref('raw_seed__subscription_status') }}
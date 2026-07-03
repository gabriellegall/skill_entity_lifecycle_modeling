WITH source AS (
    SELECT * FROM {{ ref('raw_seed__subscription_status') }}
)

, staged AS (
    SELECT
        CAST(USER_ID AS INTEGER)                                                                 AS USER_ID,
        CAST(DATE_INFO AS DATE)                                                                  AS DATE_INFO,
        CAST(STATUS AS VARCHAR)                                                                  AS STATUS,
        STATUS = 'active'                                                                        AS IS_ACTIVE,
        LAG(IS_ACTIVE) OVER (PARTITION BY USER_ID ORDER BY DATE_INFO)                            AS PREVIOUS_IS_ACTIVE,
        MIN(CASE WHEN IS_ACTIVE = TRUE THEN DATE_INFO ELSE NULL END) OVER (PARTITION BY USER_ID) AS FIRST_ACTIVE_DATE_INFO,
        CASE WHEN DATE_INFO = FIRST_ACTIVE_DATE_INFO THEN DATE_INFO END                          AS FIRST_ACQUISITION_DATE_INFO,
    FROM source
)

SELECT * FROM staged
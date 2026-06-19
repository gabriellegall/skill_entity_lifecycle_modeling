WITH source AS (
    SELECT * FROM {{ ref('raw_seed__subscription_status') }}
)

, staged AS (
    SELECT
        CAST(USER_ID AS INTEGER)  AS USER_ID,
        CAST(DATE AS DATE)        AS DATE,
        CAST(STATUS AS VARCHAR)   AS STATUS,
        STATUS = 'active'         AS IS_ACTIVE
    FROM source
)

SELECT * FROM staged
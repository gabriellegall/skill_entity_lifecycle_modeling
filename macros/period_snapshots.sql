{% macro get_incremental_scan_start_expr(time_grain, date_expression) -%}
    {%- if time_grain == 'week' -%}
        CAST(DATE_TRUNC('week', {{ date_expression }}) AS DATE) - INTERVAL 1 WEEK
    {%- elif time_grain == 'month' -%}
        CAST(DATE_TRUNC('month', {{ date_expression }}) AS DATE) - INTERVAL 1 MONTH
    {%- elif time_grain == 'quarter' -%}
        CAST(DATE_TRUNC('quarter', {{ date_expression }}) AS DATE) - INTERVAL 1 QUARTER
    {%- elif time_grain == 'year' -%}
        CAST(DATE_TRUNC('year', {{ date_expression }}) AS DATE) - INTERVAL 1 YEAR
    {%- else -%}
        {{ exceptions.raise_compiler_error('Unsupported time_grain: ' ~ time_grain) }}
    {%- endif -%}
{%- endmacro %}

{% macro build_period_snapshots_for_grain(time_grain) -%}
{%- if time_grain not in ['week', 'month', 'quarter', 'year'] -%}
    {{ exceptions.raise_compiler_error('Unsupported time_grain: ' ~ time_grain) }}
{%- endif -%}
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

, source_window AS (
    SELECT
        S.USER_ID,
        S.DATE_INFO,
        S.IS_ACTIVE,
        S.PREVIOUS_IS_ACTIVE,
        S.IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM source AS S
    CROSS JOIN data_cutoff AS C
    {% if is_incremental() %}
    -- Incremental scan: current period and previous period only for the selected grain
    WHERE S.DATE_INFO >= {{ get_incremental_scan_start_expr(time_grain, 'C.MAX_AVAILABLE_DATE_INFO') }}
    {% endif %}
)

-- Define the selected time grain period boundaries
, transition_periods AS (
    SELECT
        S.USER_ID,
        CAST(DATE_TRUNC('{{ time_grain }}', S.DATE_INFO) AS DATE) AS TIME_PERIOD_START,
        CAST(
            CASE
                WHEN '{{ time_grain }}' = 'week' THEN CAST(DATE_TRUNC('week', S.DATE_INFO) AS DATE) + INTERVAL 6 DAY
                WHEN '{{ time_grain }}' = 'month' THEN LAST_DAY(S.DATE_INFO)
                WHEN '{{ time_grain }}' = 'quarter' THEN CAST(DATE_TRUNC('quarter', S.DATE_INFO) AS DATE) + INTERVAL 3 MONTH - INTERVAL 1 DAY
                WHEN '{{ time_grain }}' = 'year' THEN MAKE_DATE(YEAR(S.DATE_INFO), 12, 31)
            END AS DATE
        ) AS TIME_PERIOD_END,
        '{{ time_grain }}' AS TIME_GRAIN,
        S.DATE_INFO,
        S.PREVIOUS_IS_ACTIVE,
        S.IS_ACTIVE,
        S.IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM source_window AS S
    CROSS JOIN data_cutoff AS C
    -- Only keep full periods for each time grain
    WHERE TIME_PERIOD_END <= C.MAX_AVAILABLE_DATE_INFO
)

-- For each period, collect lifecycle event dates and period-end activity state
, period_lifecycle_date_arrays AS (
    SELECT
        USER_ID,
        TIME_PERIOD_START,
        TIME_PERIOD_END,
        CAST(TIME_PERIOD_START - INTERVAL 1 DAY AS DATE)                                                                               AS PREVIOUS_TIME_PERIOD_END, -- Useful for data quality tests
        TIME_GRAIN,
        MAX(CASE WHEN DATE_INFO = TIME_PERIOD_END THEN IS_ACTIVE ELSE NULL END)                                                       AS IS_ACTIVE_PERIOD_END,
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE IS_FIRST_USER_ACTIVE_DATE_INFO = TRUE)                                   AS ALL_ACQUISITION_DATE_INFO,
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE PREVIOUS_IS_ACTIVE = TRUE AND IS_ACTIVE = FALSE)                         AS ALL_CHURN_DATE_INFO,
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
{%- endmacro %}
# Skill: Lifecycle Modeling from Snapshot Status Tables (Demo-Quoted Edition)

## Business Context
Lifecycle modeling is a universal analytics challenge across industries. Teams need to measure how entities move between states over time, usually to monitor retention, acquisition efficiency, and resurrection performance.

Examples where this methodology applies (non-exhaustive list):
- B2B SaaS: active workspace seats, expansion, contraction, and account resurrection after cancellation.
- Consumer subscriptions: active subscribers, churned subscribers, and reactivated subscribers by billing cycle.
- Banking: active cardholders, dormant accounts, and reactivated users after inactivity periods.
- Insurance: policy lifecycle transitions such as active, lapsed, renewed, and reinstated.
- Telecom: SIM or plan activity transitions, including temporary disconnections and reactivations.
- E-commerce: customer activity lifecycle based on purchase recency windows and return-to-purchase behavior.
- Marketplaces: buyer or seller activation, inactivity, and return cohorts by region or segment.
- Gaming: monthly active players, churned players, and resurrected players after content releases.
- Media and streaming: subscriber and viewer engagement states across weekly or monthly snapshots.
- Mobility and travel: rider or traveler lifecycle transitions tied to booking behavior.
- Food delivery: customer ordering lifecycle, lapses, and comeback patterns after CRM campaigns.
- Healthcare apps: patient engagement status, drop-off, and re-engagement after outreach.
- Education platforms: learner activity lifecycle, course dropout, and reactivation by term.
- HR tech: candidate pipeline or employee status lifecycle across hiring and retention funnels.
- IoT and connected devices: active device fleet, offline churn, and reconnect events.
- Fintech lending: borrower activity states, repayment dropout, and reactivation in collection programs.
- Nonprofit and fundraising: donor active status, lapses, and reactivation after campaigns.
- Utilities: account usage lifecycle with inactive periods and resumed service.
- Logistics: shipper activity lifecycle and reactivation of dormant accounts.
- Hospitality: guest lifecycle by stay frequency, inactivity, and return behavior.

## Positioning
This skill is intentionally educational. The quoted files below are a demo to showcase the idea and communicate the framework. They are a means, not an end.

Use this as a transferable reference for methodology, not as a rigid implementation template. Adapt naming, status mapping, materialization strategy, and warehouse-specific SQL to your context.

## End Goal
Produce a lifecycle ledger that is decision-ready for business reporting and remains mathematically reconciled at every selected time grain:

base_previous + acquisition - churn + resurrection = base_current

This allows stakeholders to read movements as an accounting system, not as disconnected metrics.

A practical end-goal is to generate a model like int_user_status_snapshots_period_agg_movements, which captures churn at the entity level for each period and time grain.

## Minimal Input Contract
At minimum, the source data should provide:
- an entity identifier (for example: USER_ID),
- a snapshot date (for example: DATE_INFO),
- a status/state signal (for example: STATUS) from which active/inactive logic can be derived.

## Expected Output Contract
The target output is akin to int_user_status_snapshots_period_agg_movements.

At minimum, it should expose fields equivalent to:
- USER_ID (entity ID),
- TIME_PERIOD_END,
- TIME_GRAIN,
- EVENT_TYPE,
- EVENT_DATE.

Column names may vary depending on the project where this is implemented.

## Included Demo Artifacts (verbatim except noted excerpts)
- seeds/raw_seed__subscription_status.csv (excerpt limited to USER_ID = 2 in this skill)
- models/staging/stg_seed__subscription_status.sql
- models/intermediate/approach_period_snapshots/int_user_status_snapshots_period.sql
- models/intermediate/approach_period_snapshots/int_user_status_snapshots_period_agg_movements.sql
- models/intermediate/approach_period_snapshots/int_user_status_snapshots_period_agg_metrics.sql
- tests/approach_period_snapshots/assert_continuous_dates_per_user.sql
- models/intermediate/approach_period_snapshots/_period_snapshots__models.yml

---

## 1) Demo Seed CSV Excerpt (USER_ID = 2, not full verbatim)

```csv
USER_ID,DATE_INFO,STATUS
"2","2026-01-01","active"
"2","2026-01-02","active"
"2","2026-01-03","active"
"2","2026-01-04","active"
"2","2026-01-05","active"
"2","2026-01-06","inactive"
"2","2026-01-07","inactive"
"2","2026-01-08","inactive"
"2","2026-01-09","inactive"
"2","2026-01-10","inactive"
"2","2026-01-11","active"
"2","2026-01-12","active"
"2","2026-01-13","active"
"2","2026-01-14","active"
"2","2026-01-15","active"
"2","2026-01-16","inactive"
"2","2026-01-17","inactive"
"2","2026-01-18","inactive"
"2","2026-01-19","inactive"
"2","2026-01-20","inactive"
"2","2026-01-21","active"
"2","2026-01-22","active"
"2","2026-01-23","active"
"2","2026-01-24","active"
"2","2026-01-25","active"
"2","2026-01-26","inactive"
"2","2026-01-27","inactive"
"2","2026-01-28","inactive"
"2","2026-01-29","inactive"
"2","2026-01-30","inactive"
"2","2026-01-31","active"
"2","2026-02-01","active"
"2","2026-02-02","active"
"2","2026-02-03","active"
"2","2026-02-04","active"
"2","2026-02-05","inactive"
"2","2026-02-06","inactive"
"2","2026-02-07","inactive"
"2","2026-02-08","inactive"
"2","2026-02-09","inactive"
"2","2026-02-10","active"
"2","2026-02-11","active"
"2","2026-02-12","active"
"2","2026-02-13","active"
"2","2026-02-14","active"
"2","2026-02-15","inactive"
"2","2026-02-16","inactive"
"2","2026-02-17","inactive"
"2","2026-02-18","inactive"
"2","2026-02-19","inactive"
"2","2026-02-20","active"
"2","2026-02-21","active"
"2","2026-02-22","active"
"2","2026-02-23","active"
"2","2026-02-24","active"
"2","2026-02-25","inactive"
"2","2026-02-26","inactive"
"2","2026-02-27","inactive"
"2","2026-02-28","inactive"
"2","2026-03-01","inactive"
"2","2026-03-02","active"
"2","2026-03-03","active"
"2","2026-03-04","active"
"2","2026-03-05","active"
"2","2026-03-06","active"
"2","2026-03-07","inactive"
"2","2026-03-08","inactive"
"2","2026-03-09","inactive"
"2","2026-03-10","inactive"
"2","2026-03-11","inactive"
"2","2026-03-12","active"
"2","2026-03-13","active"
"2","2026-03-14","active"
"2","2026-03-15","active"
"2","2026-03-16","active"
"2","2026-03-17","inactive"
"2","2026-03-18","inactive"
"2","2026-03-19","inactive"
"2","2026-03-20","inactive"
"2","2026-03-21","inactive"
"2","2026-03-22","active"
"2","2026-03-23","active"
"2","2026-03-24","active"
"2","2026-03-25","active"
"2","2026-03-26","active"
"2","2026-03-27","inactive"
"2","2026-03-28","inactive"
"2","2026-03-29","inactive"
"2","2026-03-30","inactive"
"2","2026-03-31","inactive"
"2","2026-04-01","active"
"2","2026-04-02","active"
"2","2026-04-03","active"
"2","2026-04-04","active"
"2","2026-04-05","active"
"2","2026-04-06","inactive"
"2","2026-04-07","inactive"
"2","2026-04-08","inactive"
"2","2026-04-09","inactive"
"2","2026-04-10","inactive"
"2","2026-04-11","active"
"2","2026-04-12","active"
"2","2026-04-13","active"
"2","2026-04-14","active"
"2","2026-04-15","active"
"2","2026-04-16","inactive"
"2","2026-04-17","inactive"
"2","2026-04-18","inactive"
"2","2026-04-19","inactive"
"2","2026-04-20","inactive"
"2","2026-04-21","active"
"2","2026-04-22","active"
"2","2026-04-23","active"
"2","2026-04-24","active"
"2","2026-04-25","active"
"2","2026-04-26","inactive"
"2","2026-04-27","inactive"
"2","2026-04-28","inactive"
"2","2026-04-29","inactive"
"2","2026-04-30","inactive"
"2","2026-05-01","active"
"2","2026-05-02","active"
"2","2026-05-03","active"
"2","2026-05-04","active"
"2","2026-05-05","active"
"2","2026-05-06","inactive"
"2","2026-05-07","inactive"
"2","2026-05-08","inactive"
"2","2026-05-09","inactive"
"2","2026-05-10","inactive"
"2","2026-05-11","active"
"2","2026-05-12","active"
"2","2026-05-13","active"
"2","2026-05-14","active"
"2","2026-05-15","active"
"2","2026-05-16","inactive"
"2","2026-05-17","inactive"
"2","2026-05-18","inactive"
"2","2026-05-19","inactive"
"2","2026-05-20","inactive"
"2","2026-05-21","active"
"2","2026-05-22","active"
"2","2026-05-23","active"
"2","2026-05-24","active"
"2","2026-05-25","active"
"2","2026-05-26","inactive"
"2","2026-05-27","inactive"
"2","2026-05-28","inactive"
"2","2026-05-29","inactive"
"2","2026-05-30","inactive"
"2","2026-05-31","active"
"2","2026-06-01","active"
"2","2026-06-02","active"
"2","2026-06-03","active"
"2","2026-06-04","active"
"2","2026-06-05","inactive"
"2","2026-06-06","inactive"
"2","2026-06-07","inactive"
"2","2026-06-08","inactive"
"2","2026-06-09","inactive"
"2","2026-06-10","active"
"2","2026-06-11","active"
"2","2026-06-12","active"
"2","2026-06-13","active"
"2","2026-06-14","active"
"2","2026-06-15","inactive"
"2","2026-06-16","inactive"
"2","2026-06-17","inactive"
"2","2026-06-18","inactive"
"2","2026-06-19","inactive"
```

## 2) Staging SQL (100% verbatim)

Source: models/staging/stg_seed__subscription_status.sql

```sql
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
```

## 3) Period Snapshot SQL (100% verbatim)

Source: models/intermediate/approach_period_snapshots/int_user_status_snapshots_period.sql

```sql
{{ config(materialized='table') }}

WITH source AS (
    SELECT
        USER_ID,
        DATE_INFO,
        IS_ACTIVE,
        PREVIOUS_IS_ACTIVE,
        IS_FIRST_USER_ACTIVE_DATE_INFO,
        DATE_INFO = CAST(CAST(DATE_TRUNC('week', DATE_INFO) AS DATE) + INTERVAL 6 DAY AS DATE) AS IS_WEEK_PERIOD_END,
        DATE_INFO = LAST_DAY(DATE_INFO) AS IS_MONTH_PERIOD_END,
        DATE_INFO = CAST(CAST(DATE_TRUNC('quarter', DATE_INFO) AS DATE) + INTERVAL 3 MONTH - INTERVAL 1 DAY AS DATE) AS IS_QUARTER_PERIOD_END,
        DATE_INFO = MAKE_DATE(YEAR(DATE_INFO), 12, 31) AS IS_YEAR_PERIOD_END
    FROM {{ ref('stg_seed__subscription_status') }}
    WHERE 
        -- Performance optimization:
            -- Movement filters (i.e. "something happened")
        IS_FIRST_USER_ACTIVE_DATE_INFO = TRUE
        OR (PREVIOUS_IS_ACTIVE = TRUE AND IS_ACTIVE = FALSE)
        OR (PREVIOUS_IS_ACTIVE = FALSE AND IS_ACTIVE = TRUE AND IS_FIRST_USER_ACTIVE_DATE_INFO = FALSE)
            -- Time boundary filters (i.e. "the period snapshot is relevant")
        OR IS_WEEK_PERIOD_END = TRUE
        OR IS_MONTH_PERIOD_END = TRUE
        OR IS_QUARTER_PERIOD_END = TRUE
        OR IS_YEAR_PERIOD_END = TRUE
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
        MAX(CASE WHEN DATE_INFO = TIME_PERIOD_END THEN IS_ACTIVE ELSE NULL END)                                                                          AS IS_ACTIVE_PERIOD_END, 
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE IS_FIRST_USER_ACTIVE_DATE_INFO = TRUE)                                                      AS ALL_ACQUISITION_DATE_INFO,
        LIST(DATE_INFO ORDER BY DATE_INFO ASC) FILTER (WHERE PREVIOUS_IS_ACTIVE = TRUE AND IS_ACTIVE = FALSE)                                            AS ALL_CHURN_DATE_INFO,
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
```

## 4) Period Movements SQL (100% verbatim)

Source: models/intermediate/approach_period_snapshots/int_user_status_snapshots_period_agg_movements.sql

```sql
{{ config(materialized='view') }}

WITH period_snapshot AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period') }}
)

, status_change AS (
    SELECT
        USER_ID,
        TIME_PERIOD_END,
        TIME_GRAIN,
        IS_ACTIVE_PERIOD_END,
        FIRST_ACQUISITION_DATE_INFO,
        FIRST_CHURN_DATE_INFO,
        FIRST_RESURRECTION_DATE_INFO,
        LAG(IS_ACTIVE_PERIOD_END) OVER (PARTITION BY USER_ID, TIME_GRAIN ORDER BY TIME_PERIOD_END) AS PREVIOUS_IS_ACTIVE_PERIOD_END
    FROM period_snapshot
)

, events AS (
    SELECT
        *,
        CASE 
            WHEN FIRST_ACQUISITION_DATE_INFO IS NOT NULL AND IS_ACTIVE_PERIOD_END = TRUE THEN 'acquisition'
            WHEN PREVIOUS_IS_ACTIVE_PERIOD_END = TRUE  AND IS_ACTIVE_PERIOD_END = FALSE  THEN 'churn'
            WHEN PREVIOUS_IS_ACTIVE_PERIOD_END = FALSE AND IS_ACTIVE_PERIOD_END = TRUE   THEN 'resurrection'
        END AS EVENT_TYPE,
        CASE
            WHEN EVENT_TYPE = 'acquisition'  THEN FIRST_ACQUISITION_DATE_INFO
            WHEN EVENT_TYPE = 'churn'        THEN FIRST_CHURN_DATE_INFO
            WHEN EVENT_TYPE = 'resurrection' THEN FIRST_RESURRECTION_DATE_INFO
        END AS EVENT_DATE,
        EVENT_TYPE = 'acquisition'  AS IS_ACQUIRED,
        EVENT_TYPE = 'churn'        AS IS_CHURNED,
        EVENT_TYPE = 'resurrection' AS IS_RESURRECTED
    FROM status_change
)

SELECT
    USER_ID,
    TIME_PERIOD_END,
    TIME_GRAIN,
    EVENT_TYPE,
    EVENT_DATE,
    FIRST_ACQUISITION_DATE_INFO,
    FIRST_CHURN_DATE_INFO,
    FIRST_RESURRECTION_DATE_INFO,
    IS_CHURNED,
    IS_RESURRECTED,
    IS_ACQUIRED
FROM events
WHERE EVENT_TYPE IS NOT NULL -- Only keep movements
```

## 5) Period Metrics SQL (100% verbatim)

Source: models/intermediate/approach_period_snapshots/int_user_status_snapshots_period_agg_metrics.sql

```sql
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
```

## 6) Continuity Test SQL (100% verbatim)

Note: model references in this demo SQL are project-specific and may need renaming when implemented elsewhere.

Source: tests/approach_period_snapshots/assert_continuous_dates_per_user.sql

```sql
WITH period_snapshot AS (
    SELECT * FROM {{ ref('int_user_status_snapshots_period') }}
)

, periods_with_lag AS (
    SELECT
        USER_ID,
        TIME_GRAIN,
        TIME_PERIOD_END,
        LAG(TIME_PERIOD_END) OVER (PARTITION BY USER_ID, TIME_GRAIN ORDER BY TIME_PERIOD_END) AS ACTUAL_PREVIOUS_PERIOD,
        PREVIOUS_TIME_PERIOD_END                                                              AS EXPECTED_PREVIOUS_PERIOD
    FROM period_snapshot
)

SELECT
    USER_ID,
    TIME_GRAIN,
    TIME_PERIOD_END,
    ACTUAL_PREVIOUS_PERIOD,
    EXPECTED_PREVIOUS_PERIOD        
FROM periods_with_lag
WHERE ACTUAL_PREVIOUS_PERIOD IS NOT NULL
    AND ACTUAL_PREVIOUS_PERIOD IS DISTINCT FROM EXPECTED_PREVIOUS_PERIOD
```

## 7) Verification Tests YAML (100% verbatim)

Source: models/intermediate/approach_period_snapshots/_period_snapshots__models.yml

```yaml
version: 2

models:
  - name: int_user_status_snapshots_period
    description: "This model builds snapshots periods for each [user_id] and [time_grain] keeping only start and end dates for each period."

  - name: int_user_status_snapshots_period_agg_movements
    description: "This model calculates the number of users that have been acquired, churned, or resurrected for each [user_id] and [time_grain], built on period snapshots."
    columns:
      - name: FIRST_CHURN_DATE_INFO
        data_tests:
          - dbt_utils.expression_is_true:
              arguments:
                expression: IS NOT NULL
              config:
                where: IS_CHURNED = TRUE
      - name: FIRST_RESURRECTION_DATE_INFO
        data_tests:
          - dbt_utils.expression_is_true:
              arguments:
                expression: IS NOT NULL
              config:
                where: IS_RESURRECTED = TRUE
      - name: FIRST_ACQUISITION_DATE_INFO
        data_tests:
          - dbt_utils.expression_is_true:
              arguments:
                expression: IS NOT NULL
              config:
                where: IS_ACQUIRED = TRUE

  - name: int_user_status_snapshots_period_agg_metrics
    description: "This model aggregates user movements at the period level for each [time_grain]. It can be useful for high-level reporting or data consistency checks."
    data_tests:
      - dbt_utils.expression_is_true:
          arguments:
            expression: NB_ACTIVE_USERS_PREVIOUS_PERIOD_END + NB_ACQUIRED_USERS + NB_CHURNED_USERS + NB_RESURRECTED_USERS = NB_ACTIVE_USERS_PERIOD_END
```

---

## Performance Optimization (Scaling Beyond Demo Volumes)

The period snapshot approach shown in this demo uses a cross join between daily snapshots and a time grain list (`week`, `month`, `quarter`, `year`).

At small scale this is acceptable, but at larger scale this pattern can become expensive because:
- row count expansion grows with both entity count and date range,
- each additional time grain multiplies intermediate rows,
- full-history recomputation increases run time and cost over time.

An incremental time window strategy is often the first optimization. However, this can be tricky to design correctly for yearly grain because a yearly close can require lookback semantics that differ from shorter grains.

A robust pattern is to:
- implement one incremental model per time grain,
- use macros to centralize period-end and incremental window logic,
- run each grain in its own DAG,
- union the grain outputs into a single consolidated period snapshot model.

This preserves a single downstream contract while reducing unnecessary scans and avoiding a large all-grain cross join in one model.

Example macro pattern (`get_incremental_scan_start_expr` returning the 1st day of the previous period):

```sql
{% macro get_time_period_end_expr(time_grain, date_expression) -%}
    {%- if time_grain == 'week' -%}
        CAST(DATE_TRUNC('week', {{ date_expression }}) AS DATE) + INTERVAL 6 DAY
    {%- elif time_grain == 'month' -%}
        LAST_DAY({{ date_expression }})
    {%- elif time_grain == 'quarter' -%}
        CAST(DATE_TRUNC('quarter', {{ date_expression }}) AS DATE) + INTERVAL 3 MONTH - INTERVAL 1 DAY
    {%- elif time_grain == 'year' -%}
        MAKE_DATE(YEAR({{ date_expression }}), 12, 31)
    {%- else -%}
        {{ exceptions.raise_compiler_error('Unsupported time_grain: ' ~ time_grain) }}
    {%- endif -%}
{%- endmacro %}

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
        CAST(DATE_TRUNC('{{ time_grain }}', S.DATE_INFO) AS DATE)                     AS TIME_PERIOD_START,
        CAST({{ get_time_period_end_expr(time_grain, 'S.DATE_INFO') }} AS DATE)       AS TIME_PERIOD_END,
        '{{ time_grain }}'                                                            AS TIME_GRAIN,
        S.DATE_INFO,
        S.PREVIOUS_IS_ACTIVE,
        S.IS_ACTIVE,
        S.IS_FIRST_USER_ACTIVE_DATE_INFO
    FROM source_window AS S
    CROSS JOIN data_cutoff AS C
    -- Only keep full periods for each time grain
    WHERE CAST({{ get_time_period_end_expr(time_grain, 'S.DATE_INFO') }} AS DATE) <= C.MAX_AVAILABLE_DATE_INFO
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
```

Suggested orchestration pattern:
- `int_user_status_snapshots_period__weekly` as an incremental model (weekly DAG),
- `int_user_status_snapshots_period__monthly` as an incremental model (monthly DAG),
- `int_user_status_snapshots_period__quarterly` as an incremental model (quarterly DAG),
- `int_user_status_snapshots_period__yearly` as an incremental model (yearly DAG),
- `int_user_status_snapshots_period` as a union model over all grain-specific outputs.

This architecture keeps each run focused on the minimum useful window while preserving one consolidated output for downstream movement and metric models.

## How To Use This Skill
Treat the quoted SQL and CSV as reference patterns that demonstrate:
- status normalization and lag-based state transitions,
- period boundary logic and closed-period filtering,
- period-level movement classification,
- reconciled aggregate metrics,
- continuity checks.

Then re-generate equivalent models for a new source table by replacing:
- entity identifier semantics,
- snapshot date column,
- status-to-active mapping,
- adapter-specific functions,
- naming and materialization strategy.

This demo is a means to communicate the method, not the final target architecture for every project.

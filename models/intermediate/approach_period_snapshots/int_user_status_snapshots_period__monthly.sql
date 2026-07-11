{{ config(
    materialized='incremental',
    tags=['monthly_dag'],
    unique_key=['USER_ID', 'TIME_PERIOD_START', 'TIME_GRAIN'],
    incremental_strategy='delete+insert',
    on_schema_change='sync_all_columns'
) }}

{{ build_period_snapshots_for_grain('month') }}
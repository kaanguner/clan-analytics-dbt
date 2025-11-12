{{ 
    config(
        materialized='incremental',
        unique_key='activity_id'
    )
}}

with stg as (
    select * from {{ ref('stg_user_daily_metrics') }}
),
dim_date as (
    select * from {{ ref('dim_date') }}
),
dim_platform as (
    select * from {{ ref('dim_platform') }}
),
dim_country as (
    select * from {{ ref('dim_country') }}
),
dim_user as (
    select * from {{ ref('dim_user') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['stg.user_id', 'stg.event_date']) }} as activity_id,
    du.user_key,
    dd.date_key,
    dp.platform_key,
    dc.country_key,
    stg.total_session_count as session_count,
    stg.total_session_duration as session_duration_seconds,
    stg.match_start_count as matches_started,
    stg.match_end_count as matches_ended,
    stg.victory_count as victories,
    stg.defeat_count as defeats,
    stg.iap_revenue,
    stg.ad_revenue,
    stg.server_connection_error as server_errors,
    stg.event_date as created_at

from stg
join dim_date dd on stg.event_date = dd.date
join dim_platform dp on stg.platform = dp.platform_name
join dim_country dc on stg.country = dc.country_code
join dim_user du on stg.user_id = du.user_id and stg.event_date >= du.valid_from and (stg.event_date < du.valid_to or du.valid_to is null)

{% if is_incremental() %}

  where stg.event_date > (select coalesce(max(created_at), '1900-01-01') from {{ this }})

{% endif %}
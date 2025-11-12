with fact_data as (
    select
        f.*,
        d.date as event_date,
        p.platform_name as platform,
        c.country_code as country
    from {{ ref('fact_daily_user_activity') }} f
    join {{ ref('dim_date') }} d on f.date_key = d.date_key
    join {{ ref('dim_platform') }} p on f.platform_key = p.platform_key
    join {{ ref('dim_country') }} c on f.country_key = c.country_key
),
aggregated as (
    select
        event_date,
        country,
        platform,
        count(distinct user_key) as dau,
        sum(iap_revenue) as total_iap_revenue,
        sum(ad_revenue) as total_ad_revenue,
        sum(matches_started) as matches_started,
        sum(matches_ended) as total_matches_ended,
        sum(victories) as total_victories,
        sum(defeats) as total_defeats,
        sum(server_errors) as total_server_errors
    from fact_data
    group by 1, 2, 3
)
select
    event_date,
    country,
    platform,
    dau,
    total_iap_revenue,
    total_ad_revenue,
    round(
        (total_iap_revenue + total_ad_revenue) / nullif(dau, 0),
        2
    ) as arpdau,
    matches_started,
    round(
        matches_started / nullif(dau, 0),
        2
    ) as match_per_dau,
    round(
        total_victories / nullif(total_matches_ended, 0),
        4
    ) as win_ratio,
    round(
        total_defeats / nullif(total_matches_ended, 0),
        4
    ) as defeat_ratio,
    round(
        total_server_errors / nullif(dau, 0),
        4
    ) as server_error_per_dau
from aggregated
order by event_date desc, country, platform

with platform_values as (
    select distinct platform from {{ ref('stg_user_daily_metrics') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['platform']) }} as platform_key,
    platform as platform_name,
    case
        when platform = 'ANDROID' then 'Mobile'
        when platform = 'IOS' then 'Mobile'
        else 'Other'
    end as platform_category
from platform_values
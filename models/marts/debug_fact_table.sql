select
    count(*) as total_rows,
    count(case when user_key is null then 1 end) as null_user_keys,
    count(case when date_key is null then 1 end) as null_date_keys,
    count(case when platform_key is null then 1 end) as null_platform_keys,
    count(case when country_key is null then 1 end) as null_country_keys
from {{ ref('fact_daily_user_activity') }}
with country_values as (
    select distinct country from {{ ref('stg_user_daily_metrics') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['country']) }} as country_key,
    country as country_code
from country_values
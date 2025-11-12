with user_snapshot as (
    select * from {{ ref('user_snapshot') }}
),
ranked_values as (
    select
        user_id,
        platform,
        country,
        row_number() over (partition by user_id order by dbt_valid_from) as rn
    from user_snapshot
),
first_values as (
    select
        user_id,
        platform as first_platform,
        country as first_country
    from ranked_values
    where rn = 1
)
select
    {{ dbt_utils.generate_surrogate_key(['s.user_id', 's.dbt_valid_from']) }} as user_key,
    s.user_id,
    s.install_date,
    fv.first_platform,
    fv.first_country,
    s.dbt_valid_from as valid_from,
    s.dbt_valid_to as valid_to,
    case when s.dbt_valid_to is null then true else false end as is_current
from user_snapshot s
join first_values fv on s.user_id = fv.user_id
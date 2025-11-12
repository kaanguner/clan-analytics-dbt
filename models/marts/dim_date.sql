with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-01-01' as date)",
        end_date="cast('2024-03-31' as date)"
    ) }}
)
select
    format_date('%Y%m%d', date_day) as date_key,
    date(date_day) as date,
    extract(year from date_day) as year,
    extract(quarter from date_day) as quarter,
    extract(month from date_day) as month,
    extract(week from date_day) as week,
    extract(dayofweek from date_day) as day_of_week,
    case when extract(dayofweek from date_day) in (1, 7) then true else false end as is_weekend
from date_spine

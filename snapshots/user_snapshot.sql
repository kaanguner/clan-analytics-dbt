{% snapshot user_snapshot %}

{{ 
    config(
      target_schema='analytics',
      unique_key='user_id',
      strategy='check',
      check_cols=['platform', 'country'],
      updated_at='event_date',
    )
}}

select
    user_id,
    platform,
    country,
    install_date,
    event_date
from {{ ref('stg_user_daily_metrics') }}

{% endsnapshot %}

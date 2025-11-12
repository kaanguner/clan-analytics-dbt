SELECT
    user_id,
    event_date,
    platform,
    install_date,
    country,
    total_session_count,
    total_session_duration,
    match_start_count,
    match_end_count,
    victory_count,
    defeat_count,
    server_connection_error,
    iap_revenue,
    ad_revenue
FROM
    {{ source('game_analytics', 'raw_user_metrics') }}
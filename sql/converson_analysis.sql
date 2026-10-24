-- are activated users more likely to eventually convert to paid, comapred to non-activated users

WITH activation_check AS (
    SELECT
        u.user_id,
        u.signup_date,
        CASE
            WHEN COUNT(e.event_name) > 0 THEN 1
            ELSE 0
        END AS is_activated
    FROM users u
    LEFT JOIN events e
        ON u.user_id = e.user_id
        AND e.event_name IN ('project_created', 'task_created', 'teammate_invited',
                             'file_uploaded', 'integration_connected',
                             'time_tracking_used', 'custom_field_created')
        AND e.event_timestamp BETWEEN u.signup_date AND DATEADD(day, 7, u.signup_date)
    WHERE u.plan_at_signup = 'Free'
    GROUP BY u.user_id, u.signup_date
),

Conversion AS (
    SELECT
        ac.user_id,
        ac.is_activated,
        MAX(CASE
                WHEN s.[plan] NOT IN ('Free') THEN 1
                ELSE 0
            END) AS is_converted
    FROM activation_check ac
    JOIN subscriptions s
        ON ac.user_id = s.user_id
    GROUP BY ac.user_id, ac.is_activated
)

SELECT
    is_activated,
    COUNT(*) AS total_users,
    SUM(is_converted) AS converted_users,
    CAST(SUM(is_converted) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS Conversion_rate
FROM Conversion
GROUP BY is_activated
ORDER BY is_activated;

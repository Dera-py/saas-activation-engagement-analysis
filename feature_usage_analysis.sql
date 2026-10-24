-- which features are most/least used among activated users
WITH activation_check AS (
    SELECT 
        u.user_id,
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
    GROUP BY u.user_id
),
activated_feature_usage AS (
    SELECT
        ac.user_id,
        e.feature_name,
        COUNT(*) AS usage_count
    FROM activation_check ac
    JOIN events e
        ON ac.user_id = e.user_id
    WHERE ac.is_activated = 1
      AND e.feature_name IS NOT NULL
    GROUP BY ac.user_id, e.feature_name
)
SELECT
    afu.feature_name,
    fc.is_core_feature,
    COUNT(DISTINCT afu.user_id) AS users_who_used_it,
    SUM(afu.usage_count) AS total_usage
FROM activated_feature_usage afu
JOIN feature_catalog fc
    ON afu.feature_name = fc.feature_name
GROUP BY afu.feature_name, fc.is_core_feature
ORDER BY users_who_used_it DESC

SELECT
    e.feature_name,
    e.event_name,
    COUNT(*) AS usage_count
FROM events e
WHERE e.feature_name IS NOT NULL
GROUP BY e.feature_name, e.event_name
ORDER BY e.feature_name, usage_count DESC
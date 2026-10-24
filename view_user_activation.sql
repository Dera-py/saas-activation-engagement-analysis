-- are activated users more likley to convert to paid, compared to non-activated users

GO
CREATE VIEW vw_user_activation AS
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
    AND e.event_name IN ('project_created', 'task_created', 'teammate_invited', 'file_uploaded', 
                   'integration_connected', 'time_tracking_used', 'custom_field_created')
AND e.event_timestamp BETWEEN u.signup_date AND DATEADD(day, 7, u.signup_date)
GROUP BY u.user_id, u.signup_date
),

Conversion AS(
SELECT
ac.user_id,
ac.is_activated,
MAX (CASE 
  WHEN s.[plan] NOT IN ('Free') 
  THEN 1
  ELSE 0
END ) AS is_converted
FROM activation_check ac
JOIN subscriptions s
ON ac.user_id = s.user_id
GROUP BY ac.user_id, ac.is_activated
)
SELECT co.user_id,
       co.is_activated,
       CASE WHEN u.plan_at_signup = 'Free' THEN co.is_converted
            ELSE NULL
       END AS is_converted
FROM Conversion co
JOIN users u ON co.user_id = u.user_id


SELECT COUNT(*) AS total_rows,
       COUNT(is_converted) AS free_signups,
       CAST(AVG(CAST(is_converted AS DECIMAL(5,2))) * 100 AS DECIMAL(5,2)) AS conversion_rate
FROM vw_user_activation;
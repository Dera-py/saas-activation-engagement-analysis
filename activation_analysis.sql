-- overall activation
WITH activation_check AS (
SELECT 
u.user_id,
u.role,
u.company_size,
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
GROUP BY u.user_id, u.role, u.company_size
)
SELECT
CAST(AVG(CAST(is_activated AS DECIMAL(5,2))) * 100 AS DECIMAL(5,2)) AS activation_rate
FROM activation_check


-- activation by role
WITH activation_check AS (
SELECT 
u.user_id,
u.role,
u.company_size,
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
GROUP BY u.user_id, u.role, u.company_size
)
SELECT
role,
COUNT(role) AS users_per_role,
CAST(AVG(CAST(is_activated AS DECIMAL(5,2))) * 100 AS DECIMAL(5,2)) AS activation_rate
FROM activation_check
GROUP BY role

-- activation by company size
WITH activation_check AS (
SELECT 
u.user_id,
u.role,
u.company_size,
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
GROUP BY u.user_id, u.role, u.company_size
)
SELECT
company_size,
COUNT(company_size) AS company_size_per_role,
CAST(AVG(CAST(is_activated AS DECIMAL(5,2))) * 100 AS DECIMAL(5,2)) AS activation_rate
FROM activation_check
GROUP BY company_size


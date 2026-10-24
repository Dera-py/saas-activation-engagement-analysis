GO
CREATE VIEW vw_user_weekly_sessions AS
WITH engagement AS 
(
SELECT 
u.user_id,
e.session_id,
DATEDIFF (day, u.signup_date, e.event_timestamp) AS day_since_signup,
(DATEDIFF (day, u.signup_date, e.event_timestamp) /7) +1 AS week_number
FROM users u
JOIN events e
ON u.user_id = e.user_id
AND e.event_name IN ('session_started')
) 

SELECT
e.user_id,
week_number,
COUNT(e.session_id) AS session_count
FROM engagement e
GROUP BY user_id, week_number

SELECT COUNT(*) AS total_rows,
       SUM(session_count) AS total_sessions,
       MAX(week_number) AS last_week
FROM vw_user_weekly_sessions;




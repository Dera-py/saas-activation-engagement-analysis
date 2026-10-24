-- how engaged are users over time

WITH engagement AS (
    SELECT
        u.user_id,
        e.session_id,
        DATEDIFF(day, u.signup_date, e.event_timestamp) AS day_since_signup,
        (DATEDIFF(day, u.signup_date, e.event_timestamp) / 7) + 1 AS week_number
    FROM users u
    JOIN events e
        ON u.user_id = e.user_id
        AND e.event_name IN ('session_started')
),

User_Weekly_Session AS (
    SELECT
        e.user_id,
        week_number,
        COUNT(e.session_id) AS NoOfSession_PerUser_PerWeek
    FROM engagement e
    GROUP BY e.user_id, week_number
)

SELECT
    week_number,
    COUNT(DISTINCT user_id) AS Active_Users,
    CAST(AVG(CAST(NoOfSession_PerUser_PerWeek AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_weekly_session
FROM User_Weekly_Session
GROUP BY week_number;

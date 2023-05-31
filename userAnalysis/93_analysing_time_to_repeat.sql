/*
TASK: Calculate the minimum, maximum, and average time between the first and second session for customers who do come back.
Analyse between 1st Jan 2014 and 1st Nov 2014
*/

CREATE TEMPORARY TABLE sessions_w_repeats_date -- similar to previous query, but this time pull in the data on datestamps along with the ids
AS
  SELECT
    new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    new_sessions.created_at AS new_session_date,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_date
  FROM
    (
      SELECT
        user_id,
        website_session_id,
        created_at
      FROM
        website_sessions
      WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-01'
        AND is_repeat_session = 0
    ) AS new_sessions
    LEFT JOIN website_sessions ON website_sessions.user_id = new_sessions.user_id
      AND website_sessions.is_repeat_session = 1
      AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-01';

CREATE TEMPORARY TABLE users_first_to_second -- temp table to show the date difference in days using DATE DIFF, then will aggregate for min, max, avg from this
AS
  SELECT
    user_id,
    DATEDIFF(second_session_date, new_session_date) AS days_first_to_second_session
  FROM
    (
      SELECT
        user_id,
        new_session_id,
        new_session_date,
        MIN(repeat_session_id) AS second_session_id, -- the first session that isn't the new session, i.e. the first repeat session (and excluding latter repeat sessions)
        MIN(repeat_session_date) AS second_session_date
      FROM
        sessions_w_repeats_date
      WHERE
        repeat_session_id IS NOT NULL
      GROUP BY
        1,
        2,
        3
    ) AS first_second;

-- Solution required by task
SELECT
  AVG(days_first_to_second_session) AS avg_days_first_to_second_session,
  MIN(days_first_to_second_session) AS min_days_first_to_second_session,
  MAX(days_first_to_second_session) AS max_days_first_to_second_session
FROM
  users_first_to_second;

-- Also experimenting with window functions to display the same data within the table users_first_to_second:
SELECT
  user_id,
  days_first_to_second_session,
  AVG(days_first_to_second_session) OVER () AS avg_days,
  MIN(days_first_to_second_session) OVER () AS min_days_first_to_second_session,
  MAX(days_first_to_second_session) OVER () AS max_days_first_to_second_session
FROM
  users_first_to_second;

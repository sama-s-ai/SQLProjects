/* TASK: Pull data on how many of our website visitors come back for another session, from 1st Jan 2014 until 1st. Nov 2014. 
We've so far thought about customer value based on their first session conversion rate and revenue, but repeat sessions may be more valuable. 

STEPS:

1: identify relevant new sessions
2: get user_id from step 1 to get any repeat sessions those users had
3: analyse the data at the user level (how many sessions did each user have?)
4: aggregate the user-level analysis to generate your behavioral analysis

*/
-- Our first query to be used as a sub-query

SELECT
user_id,
website_session_id

FROM
website_sessions
WHERE
created_at BETWEEN '2014-01-01' AND '2014-11-01'
AND is_repeat_session = 0; -- New sessions only

-- Join the sub-query to website sessions where is_repeat_session = 1 i.e. repeat sessions, and create a temp table with user ids, new session ids, and repeat session ids (if they exist)
CREATE TEMPORARY TABLE sessions_w_repeats AS
SELECT
new_sessions.user_id,
new_sessions.website_session_id AS new_session_id,
website_sessions.website_session_id AS repeat_session_id
FROM
(
SELECT
user_id,
website_session_id
FROM
website_sessions
WHERE
created_at BETWEEN '2014-01-01' AND '2014-11-01'
AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions
ON website_sessions.user_id = new_sessions.user_id
AND website_sessions.is_repeat_session = 1
AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-01';

-- Count the no. of repeat sessions for each distinct user
SELECT
repeat_sessions,
COUNT(DISTINCT user_id) AS users
FROM
(

-- Count the no. of new sessions and repeat sessions for each user
SELECT
user_id,
COUNT(DISTINCT new_session_id) AS new_sessions,
COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM
sessions_w_repeats
GROUP BY
1
) AS user_level
GROUP BY
1;


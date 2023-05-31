-- TASK: Comparison of conversion rates and revenue per session for repeat sessions vs. new sessions.

SELECT
  is_repeat_session,

  COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,

  COUNT(DISTINCT ws.website_session_id) as sessions,

  SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) as rev_per_session

FROM website_sessions ws
LEFT JOIN orders o
USING(website_session_id)
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1

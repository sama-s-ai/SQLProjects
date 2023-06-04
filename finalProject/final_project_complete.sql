/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
you can decide how to handle it.
*/ 

SELECT
	YEAR(website_sessions.created_at) as yr,
	QUARTER(website_sessions.created_at) as qtr,
	COUNT(DISTINCT website_sessions.website_session_id) as sessions_volume,
	COUNT(DISTINCT orders.order_id) as order_vol

FROM website_sessions
	LEFT JOIN orders
		USING (website_session_id)
			WHERE website_sessions.created_at < '2015-01-01' -- decided to remove the 2015 quarter since it's incomplete
GROUP BY 1,2
ORDER BY 1,2;

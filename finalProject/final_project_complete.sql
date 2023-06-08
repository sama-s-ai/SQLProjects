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

/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

*/

SELECT
	YEAR(website_sessions.created_at) as yr,
	QUARTER(website_sessions.created_at) as qtr,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate, 
    SUM(orders.price_usd) / COUNT(DISTINCT order_id) as revenue_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) as rev_per_session

FROM website_sessions
	LEFT JOIN orders
		USING (website_session_id)
			WHERE website_sessions.created_at < '2015-01-01' -- decided to remove the 2015 quarter since it's incomplete
GROUP BY 1,2
ORDER BY 1,2;

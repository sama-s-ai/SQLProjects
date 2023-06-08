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

/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

SELECT
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions
    LEFT JOIN orders
        USING (website_session_id)
WHERE website_sessions.created_at < '2015-01-01' -- Decided to remove the 2015 quarter since it's incomplete
GROUP BY 1, 2
ORDER BY 1, 2;

/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT
    YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt,
    
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END)  AS bsearch_nonbrand_conv_rt,
    
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END)  AS organic_search_conv_rt,
    
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) as direct_type_in_conv_rt
FROM website_sessions
    LEFT JOIN orders
        USING (website_session_id)
WHERE website_sessions.created_at < '2015-01-01' -- Decided to remove the 2015 quarter since it's incomplete
GROUP BY 1, 2
ORDER BY 1, 2;





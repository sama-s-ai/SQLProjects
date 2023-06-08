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


/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/

SELECT

	YEAR(created_at) as yr,
    MONTH(created_at) as mo,
	SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS original_mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS original_mrfuzzy_marg,
    
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS forever_lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS forever_lovebear_marg,
    
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthday_sugar_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthday_sugar_marg,
    
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS hudson_river_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS hudson_river_marg,
    
    SUM(price_usd) as total_revenue,
    SUM(price_usd - cogs_usd) as total_margin
    
FROM order_items

GROUP BY 1,2
ORDER BY 1,2;

/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/

-- IDENTIFY all views of the products page, and bring in date

CREATE TEMPORARY TABLE product_pageviews

SELECT
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
    
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT
	YEAR(saw_product_page_at) as yr,
    MONTH(saw_product_page_at) as mo,
	COUNT(DISTINCT product_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT product_pageviews.website_session_id) as clickthrough_rt,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT product_pageviews.website_session_id) as products_to_order_rt

FROM product_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = product_pageviews.website_session_id
		AND website_pageviews.website_pageview_id > product_pageviews.website_pageview_id -- to make sure you only see the pageviews AFTER the products page, i.e. greater than.

	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id

GROUP BY 1,2;



USE mavenfuzzyfactory;

/*

TASK: The company has launched a third product (Birthday Bear), you need to run a pre-post analysis comparing the month before to the month after, 
in terms of session-to-order conversion rate, AOV, products per order, and revenue per session.

PLAN:

1. Create a temp table and bucket the time periods of 'pre-product' and 'post-product'
2. Then create a query that you will use as the sub-query, where you will join to the relevant tables,
and pull in data at a non-aggregated level.
3. Use the query from step 2. as a sub-query, and pull in the data, aggregating as per the requirements. 

*/

create temporary table time_period

SELECT
	website_session_id,
CASE 
	WHEN created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear' 
    WHEN created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear' 
    ELSE 'Uh oh...check logic'
END AS time_period

FROM website_sessions

WHERE created_at BETWEEN '2013-11-12' AND '2014-01-12';

SELECT * from time_period;

-- This is the query that I'll use as a sub-query once happy with the data pulled in.

SELECT 
	time_period.time_period,
	time_period.website_session_id,
	orders.order_id,
	orders.items_purchased,
	orders.price_usd

FROM time_period
	LEFT JOIN orders
		ON time_period.website_session_id = orders.website_session_id;

-- Finally, aggregate the data to the level required by the task and pull in data from the sub-query.

SELECT 
	time_period, 
	COUNT(DISTINCT order_id) as orders,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) as conv_rate,
	SUM(price_usd) / COUNT(DISTINCT order_id) as aov,
	SUM(items_purchased) / COUNT(DISTINCT order_id) as products_per_order,
	SUM(price_usd) / COUNT(DISTINCT website_session_id) as revenue_per_session

FROM
(	-- sub query
	SELECT 
	time_period.time_period,
	time_period.website_session_id,
	orders.order_id,
	orders.items_purchased,
	orders.price_usd

	FROM time_period
		LEFT JOIN website_sessions
			ON time_period.website_session_id = website_sessions.website_session_id

	LEFT JOIN orders
	ON time_period.website_session_id = orders.website_session_id

) as my_sub

GROUP BY 1

/*
ISSUE: Our supplier had some quality issues which weren't corrected until Sept. 2013. Then they had a major problem where the bears' arms were falling off in Aug/Sep 2014,
As a result, we replaced them with a new supplier on Sept. 16 2014.

Pull in monthly product refund rates, by product, to confirm the quality issues are now fixed.
*/


SELECT 

year(order_date) as yr,
month(order_date) as mo,
COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_id ELSE NULL END) as p1_orders,
COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refund_id ELSE NULL END)
/ COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_id ELSE NULL END) as p1_refund_rt,



COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_id ELSE NULL END) as p2_orders,
COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refund_id ELSE NULL END)
/ COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_id ELSE NULL END) as p2_refund_rt,



COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_id ELSE NULL END) as p3_orders,
COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refund_id ELSE NULL END)
/ COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_id ELSE NULL END) as p3_refund_rt,



COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_id ELSE NULL END) as p4_orders,
COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refund_id ELSE NULL END)
/ COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_id ELSE NULL END) as p4_refund_rt


FROM
	(
	SELECT
		order_items.order_id,
		order_items.order_item_id,
		order_items.created_at as order_date,
		order_items.product_id as product_id,
		order_item_refunds.order_item_refund_id

	FROM order_items
		LEFT JOIN order_item_refunds
			USING(order_item_id)

	GROUP BY 1,2,3,4,5
	) as my_sub
    
WHERE year(order_date) <= 2014
and month(order_date) <= 10

GROUP BY 1,2;

-- We can see from the results that product 1 refunds shot up to around 13-14% in Aug/Sept. 2014 as per the situation mentioned in the brief.

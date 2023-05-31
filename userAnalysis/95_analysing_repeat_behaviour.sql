-- Compare new vs. repeat sessions by channel. 

SELECT
	CASE -- group together the various channels as a channel group 
    WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
    WHEN utm_source = 'socialbook' THEN 'paid_social'
	END AS channel_group,
	
  COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) as new_sessions,
	COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) as repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1 -- group by the case statements ie. channel group
ORDER BY 3 DESC; -- order by repeat_sessions descending

/*

Assume you're given the tables below about Facebook Page and Page likes (as in "Like a Facebook Page").

Write a query to return the IDs of the Facebook pages which do not possess any likes. The output should be sorted in ascending order.

*/

SELECT page_id FROM pages
LEFT JOIN page_likes
USING (page_id)
WHERE liked_date IS NULL
ORDER BY page_id ASC;

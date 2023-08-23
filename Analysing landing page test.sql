-- 50/50 test for 'home' and 'lander-1' landing page test
-- step 0: determine first landing page and first website_pageview_id
SELECT MIN(created_at) AS first_created_at, MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1' AND created_at IS NOT NULL;

-- first_created_at = '2012-06-19 00:35:54'
-- first_pageview_id = 23504

-- finding the first pageview_id for the web-session -- 
CREATE TEMPORARY TABLE  IF NOT EXISTS first_test_pageviews
SELECT a.website_session_id, MIN(a.website_pageview_id) AS min_pageview_id
FROM website_pageviews a
INNER JOIN website_sessions b
   ON a.website_session_id = b.website_session_id 
   AND b.created_at < '2012-07-28' AND a.website_pageview_id > 23504
   AND b.utm_campaign = 'nonbrand' AND b.utm_source = 'gsearch'
GROUP BY a.website_session_id;

-- find total total web-session for certain url & nonbrand gsearch-- 
CREATE TEMPORARY TABLE  IF NOT EXISTS nonbrand_test_sessions_w_landing_page
SELECT c.website_session_id, a.pageview_url AS landing_page
FROM first_test_pageviews c
LEFT JOIN website_pageviews a
 ON a.website_pageview_id = c.min_pageview_id
 WHERE a.pageview_url IN('/home','/lander-1');

 -- find bounce web-session (pageview_id = 1) for certain url and nonbrand gsearch -- 
CREATE TEMPORARY TABLE  IF NOT EXISTS  nonbrand_test_bounced_sessions
SELECT d.website_session_id, d.landing_page, COUNT(a.website_pageview_id) AS count_of_pages_viewd
 FROM nonbrand_test_sessions_w_landing_page d
 LEFT JOIN website_pageviews a
  ON d.website_session_id = a.website_session_id
GROUP BY d.website_session_id, d.landing_page
HAVING COUNT(a.website_pageview_id) =1;

-- link total web-session table and bounce session table , count total session and bounce session and calculate cvr-- 
SELECT d.landing_page,
       COUNT(DISTINCT d.website_session_id) AS sessions,
	   COUNT(DISTINCT e.website_session_id) AS bounced_sessions,
       COUNT(DISTINCT e.website_session_id) / COUNT(DISTINCT d.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page d
LEFT JOIN nonbrand_test_bounced_sessions e
ON d.website_session_id = e.website_session_id
GROUP By d.landing_page
-- SIMULATING THE NEW STP_MANAGER - WITH ONLY REMAINDER CALLS
SET SQL_SAFE_UPDATES = 0;
-- CHECKING THE WSR AND WSRL VOLUMES FOR 1/USA

SELECT SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 30 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1, 2 DESC ; -- 0 ON 1/USA

SELECT SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 30 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1, 2 DESC ; -- 473 ON 1/USA

SELECT * FROM WEB_SCRAPE_RAW_L wsr WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' ;

-- KILLING THE OLD DATA

DELETE FROM WEB_SCRAPE_RAW where SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND SCRAPE_DATE < CURRENT_DATE() - INTERVAL 3 DAY ;

-- LET'S CHECK THE DATE DATA QUALITY

SELECT COUNT(1) FROM WEB_SCRAPE_RAW where SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;
SELECT COUNT(1) FROM WEB_SCRAPE_RAW where SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND SCRAPE_DATE < CURRENT_DATE() - INTERVAL 3 DAY ;

-- VISUAL INSPECTION SHOWS SATISFACTORY DQ OF NEWS_DATE

-- LETS DEDUPE NOW

CALL WSR_DEDUPE_ALL() ;
CALL WSRL_DEDUPE_ALL() ;

SELECT COUNT(1) FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ; -- 579

SET DISCCOUNT = SCRCOUNT DIV 2 ;
SET POSTCOUNT = SCRCOUNT - DISCCOUNT ;

/* calculate the numbers that will be converted to GGG/USA, 5/10 and DISC/POST combos   */

SELECT P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'Y' THEN 1 ELSE 0 END)  POSTCNT
, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'N' THEN 1 ELSE 0 END)  DISCCNT
, SUM(CASE WHEN U.BOT_FLAG <> 'Y' THEN 1 ELSE 0 END) REALPOSTS
FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID 
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 10 DAY GROUP BY P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE
ORDER BY 2, 3;

SELECT P.TOPICID, P.POSTOR_COUNTRY_CODE, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'Y' THEN 1 ELSE 0 END)  POSTCNT
, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'N' THEN 1 ELSE 0 END)  DISCCNT
, SUM(CASE WHEN U.BOT_FLAG <> 'Y' THEN 1 ELSE 0 END) REALPOSTS
FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID 
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 10 DAY GROUP BY P.TOPICID, P.POSTOR_COUNTRY_CODE
ORDER BY 1, 2;



SELECT 308 DIV 4 DIV 2 ; -- GENT = 38
SELECT * FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ORDER BY RAND() LIMIT 38 ;
UPDATE WEB_SCRAPE_RAW_L SET SCRAPE_TOPIC = 'ENT', COUNTRY_CODE = 'GGG' WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ORDER BY RAND() LIMIT 38 ;
UPDATE WEB_SCRAPE_RAW_L SET SCRAPE_TOPIC = 'CELEB', COUNTRY_CODE = 'GGG' WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ORDER BY RAND() LIMIT 38 ;
UPDATE WEB_SCRAPE_RAW_L SET SCRAPE_TOPIC = 'ENT' WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ORDER BY RAND() LIMIT UENT ;
CALL callSTDbyIntCcode(5, 'USA', 'ENT' , 38) ; 
CALL callSTDbyIntCcode(5, 'GGG', 'ENT' , 38) ; 
CALL callSTDbyIntCcode(10, 'GGG', 'CELEB' , 38) ; 

SELECT * FROM OPN_XYZNEWS_BOTS WHERE TOPICID = 1 AND CCODE = 'USA' ;

SELECT * FROM OPN_XYZNEWS_BOTS WHERE USERID IN (1004116, 1003835, 1006333) ;

SELECT * FROM OPN_POSTS ORDER BY POST_ID DESC ; -- 1504167
SELECT * FROM OPN_POSTS_RAW ORDER BY POST_ID DESC ; -- 1504167

SELECT * FROM OPN_POSTS_RAW WHERE POST_ID IN (1504427, 1504426) ;

SELECT POST_CONTENT, COUNT(1) FROM OPN_POSTS WHERE POST_ID < 1400000 AND POST_ID > 1300000 GROUP BY POST_CONTENT HAVING COUNT(1) > 1 ;

SELECT W.ROW_ID, IFNULL(W.NEWS_DATE, W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 499) NEWS_URL, SUBSTR(W.NEWS_HEADLINE, 1, 499) NEWS_HEADLINE
  , SUBSTR(W.NEWS_EXCERPT, 1, 499) NEWS_EXCERPT, W.COUNTRY_CODE 
  FROM WEB_SCRAPE_RAW W
  WHERE W.SCRAPE_TOPIC = 'POLITICS' AND IFNULL(W.MOVED_TO_POST_FLAG, 'N') = 'N' AND W.COUNTRY_CODE = 'IND'
  AND IFNULL(NEWS_DATE, SCRAPE_DATE) IS NOT NULL 
  AND IFNULL(NEWS_DATE, SCRAPE_DATE)   > CURRENT_DATE() - INTERVAL 3 DAY LIMIT 10;
 
SELECT * FROM OPN_POSTS WHERE POST_DATETIME > '2024-09-10 20:31:05'
AND (POST_CONTENT = 'https://www.usmagazine.com/entertainment/news/tiffany-pollard-says-her-mom-doesnt-approve-of-her-wedding-plans/'
OR URL_TITLE = 'https://www.usmagazine.com/entertainment/news/tiffany-pollard-says-her-mom-doesnt-approve-of-her-wedding-plans/') ;

CALL createBOTDiscussion('SCRAPE_TO_DISC', 1111, 'USA', 'L' , 10, '','' , '','') ;
SELECT * FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ;
SELECT * FROM WSR_CONVERTED wc ORDER BY ROW_ID DESC ;


CALL STD_MANAGER(5, 'IND', 'ENT') ;
CALL STD_MANAGER(5, 'USA', 'ENT') ;
CALL STD_MANAGER(10, 'USA', 'CELEB') ;

CALL STP_MONITOR_REVAMP() ;
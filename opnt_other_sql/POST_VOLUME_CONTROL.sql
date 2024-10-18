-- POLICY
/* we should keep all the posts in the last 100 days and all the posts that have been created as STD - because they are also created as KWs
 *  also keep all the posts that are made by actual (non-bot) users.
 * 
 * 
 * 
 */

-- checking the vol for posts before and after 100 days 

SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME < CURRENT_DATE() - INTERVAL 100 DAY AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 1.3M PROD
SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME >= CURRENT_DATE() - INTERVAL 100 DAY AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 32K PROD
SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME >= CURRENT_DATE() - INTERVAL 100 DAY AND POST_BY_USERID NOT IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 128 PROD

SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME < CURRENT_DATE() - INTERVAL 300 DAY AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 1.13M PROD
SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME >= CURRENT_DATE() - INTERVAL 300 DAY AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 32K PROD
SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME >= CURRENT_DATE() - INTERVAL 300 DAY AND POST_BY_USERID NOT IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 128 PROD

SELECT COUNT(1) FROM OPN_POSTS_RAW WHERE POST_DATETIME < CURRENT_DATE() - INTERVAL 300 DAY AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ; -- 1.15M PROD


-- SQL TO MANAGE THE INSTREAM AND DISCUSSION VOLUME
SET SQL_SAFE_UPDATES = 0;
SELECT COUNT(1) FROM OPN_POSTS WHERE POST_UPDATE_DTM > CURRENT_DATE() - INTERVAL 1 YEAR ORDER BY POST_ID DESC ;

CALL getInstreamANTI(bringuuid(1023377), 1, 0, 30) ;
CALL getDiscussionsNW(bringuuid(1005687), 1, 0, 30) ;

SELECT * FROM OPN_POSTS_RAW WHERE POST_UPDATE_DTM ='0000-00-00 00:00:00' ;
SELECT DISTINCT SCRAPE_SOURCE FROM WEB_SCRAPE_RAW WHERE MOVED_TO_POST_FLAG = 'N' ;
CALL WSR_DEDUPE('BBC/SPORTS') ;

SELECT SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 10 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1, 2 DESC ;

SELECT SCRAPE_SOURCE, COUNT(1)  FROM WEB_SCRAPE_RAW where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 10 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_SOURCE ORDER BY 1, 2 DESC ;

SELECT P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'Y' THEN 1 ELSE 0 END)  POSTCNT
, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'N' THEN 1 ELSE 0 END)  DISCCNT
, SUM(CASE WHEN U.BOT_FLAG <> 'Y' THEN 1 ELSE 0 END) REALPOSTS
FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID 
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 1 DAY GROUP BY P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE
ORDER BY 2, 3;

SELECT * FROM WSR_CONVERTED ORDER BY ROW_ID DESC ;

# FIND OUT HOW MANY CARTS ASSOCIATED WITH THE KWS THAT ARE POST-TO-KW FROM THE EARLIEST FIRST

WITH KW AS (SELECT K.TOPICID, K.KEYID, K.KEYWORDS, K.CREATION_DTM, K.ALT_KEYID, K.CREATED_BY_UID, K.ORIGIN_COUNTRY_CODE, U.USERNAME
FROM OPN_P_KW K, OPN_USERLIST U WHERE K.CREATED_BY_UID = U.USERID AND K.ALT_KEYID IS NOT NULL AND U.BOT_FLAG = 'Y' ORDER BY K.KEYID LIMIT 100),
P AS (SELECT * FROM OPN_POSTS WHERE );

SELECT COUNT(1) FROM OPN_P_KW ;

SELECT * FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID AND P.KEYID IS NULL AND U.BOT_FLAG = 'Y' AND P.POST_DATETIME < CURRENT_DATE() - INTERVAL 1 YEAR ORDER BY POST_ID LIMIT 100;
SELECT * FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID AND P.KEYID IS NULL AND U.BOT_FLAG = 'N' AND P.POST_ID >= 615057  ORDER BY POST_ID;
SELECT * FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID AND P.KEYID IS NULL AND U.BOT_FLAG = 'Y' AND P.POST_ID >= 615057  ORDER BY POST_ID;

WITH PD AS (SELECT P.POST_ID FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID AND P.KEYID IS NULL AND U.BOT_FLAG = 'Y' AND P.POST_ID > 615057 ORDER BY POST_ID LIMIT 100000)
DELETE FROM OPN_POSTS WHERE POST_ID IN (SELECT POST_ID FROM PD)

DELETE FROM OPN_POSTS WHERE POST_ID BETWEEN 10000 AND 20000 ;

SELECT COUNT(1) FROM OPN_POSTS ; -- 817764
SELECT * FROM OPN_POSTS WHERE POST_ID >= 615057  ORDER BY POST_ID ;

SELECT COUNT(1) FROM OPN_POST_SEARCH_T ;

CALL getInstreamNW(bringUUID(bringUseridFromUsername('newdbuser')), 1, 0, 30) ;
CALL getDiscussionsNW(bringUUID(bringUseridFromUsername('newdbuser')), 1, 0, 30) ;

CALL getInstreamNW(bringUUID(1000252), 1, 0, 30) ;
CALL getDiscussionsNW(bringUUID(1000253), 1, 0, 30) ;

SELECT COUNT(1) FROM OPN_POSTS WHERE POST_DATETIME < CURRENT_DATE() - INTERVAL 1 YEAR AND POST_BY_USERID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ;

SELECT * FROM OPN_30DAYS_POST_CONTENT ORDER BY LOAD_DTM DESC ;


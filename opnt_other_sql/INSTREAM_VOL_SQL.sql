/*  Finding just the instream volume numbers for any specific user */

SELECT * FROM OPN_USERLIST WHERE USERNAME LIKE 'NEWDB%' ; -- 1040252 NEWDBUSER

call getDiscussionsNW(bringuuid(1040252), 1, 0, 30) ;
call getInstreamNW(bringuuid(1040252), 1, 0, 30) ;
CALL getUserCarts(1, bringuuid(1040252), 'LATEST', 0, 100) ;

/* HOW TO FIND THE NUMBER OF KWS FOR A TOPICID IN THE CARTS OF THE LATEST USERS */

SELECT U.USERID, U.USERNAME, COUNT(C.KEYID) FROM 
OPN_USERLIST U, OPN_USER_CARTS C WHERE C.USERID = U.USERID AND U.BOT_FLAG = 'N' AND U.CREATION_DATE > CURRENT_DATE() - INTERVAL 100 day
AND C.TOPICID = 1 AND U.COUNTRY_CODE = 'GGG' GROUP BY U.USERID, U.USERNAME ORDER BY 1 DESC ; 

SELECT K.KEYID, K.KEYWORDS, COUNT(C.USERID) FROM OPN_P_KW K, OPN_USER_CARTS C, OPN_USERLIST U
WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' AND U.COUNTRY_CODE = 'USA'
AND K.KEYWORDS LIKE '%NEWS' AND K.NEWS_ONLY_FLAG = 'Y' GROUP BY K.KEYID, K.KEYWORDS ORDER BY K.KEYID ;

CREATE TABLE OPN_XYZNEWS_BOTS AS SELECT * FROM OPN_MAIN_BOTS WHERE 1 = 2 ;

SELECT * FROM OPN_MAIN_BOTS ;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID = 105087
AND U.BOT_FLAG = 'Y' AND U.COUNTRY_CODE = 'IND' ;

SELECT W.ROW_ID, IFNULL(W.NEWS_DATE, W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 499) NEWS_URL, SUBSTR(W.NEWS_HEADLINE, 1, 499) NEWS_HEADLINE
  , SUBSTR(W.NEWS_EXCERPT, 1, 499) NEWS_EXCERPT, W.COUNTRY_CODE 
  FROM WEB_SCRAPE_RAW W
  WHERE W.SCRAPE_TOPIC = 'POLITICS' AND IFNULL(W.MOVED_TO_POST_FLAG, 'N') = 'N' AND W.COUNTRY_CODE = 'USA'
  AND IFNULL(NEWS_DATE, SCRAPE_DATE) IS NOT NULL 
  AND IFNULL(STR_TO_DATE(W.NEWS_DATE, '%b %d, %Y %H:%i:%s'), SCRAPE_DATE) 
  > CURRENT_DATE() - INTERVAL 3 DAY LIMIT 5 ;
  
  SELECT W.ROW_ID, IFNULL(W.NEWS_DATE, W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 499) NEWS_URL, SUBSTR(W.NEWS_HEADLINE, 1, 499) NEWS_HEADLINE
  , SUBSTR(W.NEWS_EXCERPT, 1, 499) NEWS_EXCERPT, W.COUNTRY_CODE 
  FROM WEB_SCRAPE_RAW W
  WHERE W.SCRAPE_TOPIC = 'POLITICS' AND IFNULL(W.MOVED_TO_POST_FLAG, 'N') = 'N' AND W.COUNTRY_CODE = 'USA'
  AND IFNULL(NEWS_DATE, SCRAPE_DATE) IS NOT NULL 
  AND IFNULL(W.NEWS_DATE, W.SCRAPE_DATE)  > CURRENT_DATE() - INTERVAL 3 DAY LIMIT 500 ;
  
SELECT * FROM WEB_SCRAPE_RAW WHERE NEWS_DATE = '0000-00-00 00:00:00' ;
SELECT * FROM WEB_SCRAPE_RAW WHERE LENGTH(NEWS_DTM_RAW) = 19 ; -- 21, 31, 29
SELECT * FROM WEB_SCRAPE_RAW_L WHERE LENGTH(NEWS_DTM_RAW) = 29 ; -- 21, 31, 29
SELECT * FROM WEB_SCRAPE_RAW_L WHERE NEWS_DTM_RAW IS NULL ;
SELECT LENGTH(NEWS_DTM_RAW), COUNT(1) FROM WEB_SCRAPE_RAW GROUP BY LENGTH(NEWS_DTM_RAW) ;

105087
105088
105089
105108
105653
105654
105655
105667 ;

SELECT COUNT(1) FROM WEB_SCRAPE_RAW WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

SELECT * FROM OPN_POSTS ORDER BY POST_ID DESC LIMIT 100 ;

SELECT * FROM WSR_CONVERTED ORDER BY ROW_ID DESC LIMIT 100 ;

CALL STP_REMAINDER('POLITICS', 1, 'USA', 3, 2) ;

SELECT * FROM OPN_USER_INTERESTS ORDER BY ROW_ID DESC LIMIT 100 ;
SELECT * FROM OPN_USER_INTERESTS WHERE USERID = 1040586 ;
SELECT * FROM OPN_USER_CARTS WHERE USERID = 1040586 ;

SELECT * FROM OPN_USER_CARTS WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_INTERESTS ) ;

CALL insertUserInterests('069f91a8-2a40-11e7-a7ad-064c86fddcc0') ;




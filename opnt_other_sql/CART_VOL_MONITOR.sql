-- FIND THE CART VOL STATUS AND DISTRIBUTION AS OF NOW

-- 1. TOTAL VOL AND CRITICAL VOL (CRITICAL = CARTS THAT CONTAIN KWS < ID 106000)

SELECT COUNT(1) FROM OPN_USER_CARTS ; -- 2.86M PROD
SELECT COUNT(1) FROM OPN_USER_CARTS WHERE CREATION_DTM < CURRENT_DATE() - INTERVAL 100 DAY ; -- 2.1M PROD
SELECT COUNT(1) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID > 106000 ; -- 2.16M

-- Find the ROW_IDs from OPN_USER_CARTS that are: not the USERIDs who created the STD words, and not the NEWS_ONLY rows and those created < 15 days ago

SELECT C.KEYID, K.CREATED_BY_UID, C.USERID,  C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID > 106000 AND C.USERID <> K.CREATED_BY_UID ORDER BY 1;

-- then DELETE them from the OUC

DELETE FROM OPN_USER_CARTS WHERE ROW_ID IN (SELECT ROW_ID FROM (
SELECT C.KEYID, K.CREATED_BY_UID, C.USERID, C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID > 106000 AND C.USERID <> K.CREATED_BY_UID)Q1);

-- This leaves only those rows in the OUC that are: for the initial KWs such as Modi, trump etc. and the NEWS_ONLY KWs
-- or the rows from the last 15 days

SELECT C.KEYID, K.CREATED_BY_UID, C.USERID, C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID < 106000 order by 1 -- AND C.USERID = K.CREATED_BY_UID

-- First find out which carts need to be reduced. This is done by the following sql:

CREATE TABLE TEMP_KEYID4_CLEANUP AS
SELECT C.KEYID, COUNT(1) TCNT, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USA, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) IND
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGG FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = 2 AND K.COUNTRY_CODE = 'USA' GROUP BY C.KEYID 
HAVING SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) > 30 OR SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) > 30 ORDER BY COUNT(1) ;

SELECT C.KEYID, COUNT(1) TCNT, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USA, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) IND
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGG FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'IND' GROUP BY C.KEYID 
HAVING SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) > 30  ORDER BY COUNT(1) DESC ;

SELECT  U.COUNTRY_CODE, COUNT(1) TCNT FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 GROUP BY  U.COUNTRY_CODE ;


DROP TABLE TEMP_KEYID4_CLEANUP ;
SELECT * FROM TEMP_KEYID4_CLEANUP ;

SELECT COUNT(1) FROM OPN_USER_CARTS ;
SELECT COUNT(1) FROM TEMP_KEYID4_CLEANUP ;

SELECT COUNT(1) FROM (SELECT T.*, K.CREATION_DTM FROM TEMP_KEYID4_CLEANUP T, OPN_P_KW K WHERE T.KEYID = K.KEYID AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 10 DAY )Q  ;

SELECT T.*, K.CREATION_DTM FROM TEMP_KEYID4_CLEANUP T, OPN_P_KW K WHERE T.KEYID = K.KEYID AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 10 DAY ORDER BY TCNT DESC ; 

SELECT C.KEYID, COUNT(1) TCNT, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USA, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) IND
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGG FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'USA'  GROUP BY C.KEYID ORDER BY COUNT(1) DESC ;

CALL OPN_BULK_CART_CLEANUP(2) ;

SELECT COUNT(DISTINCT C.KEYID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID 
AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'USA' ; -- 1421532

SELECT COUNT(1) TCNT FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'IND' ;
SELECT TOPICID, COUNT(1) TCNT FROM OPN_USER_CARTS C WHERE C.CREATION_DTM > CURRENT_DATE() - INTERVAL 10 DAY GROUP BY TOPICID ;

SELECT COUNT(1) FROM OPN_POSTS_RAW ; -- 1.3M

SELECT COUNT(1) FROM WEB_SCRAPE_RAW_L wsrl WHERE SCRAPE_DATE > CURRENT_DATE() - INTERVAL 3 DAY ;

SELECT * FROM WEB_SCRAPE_RAW_L wsrl ;

select KEYID FROM (
SELECT C.KEYID, K.CREATION_DTM, COUNT(DISTINCT C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID 
AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'USA' AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 10 DAY
GROUP BY C.KEYID, K.CREATION_DTM ORDER BY COUNT(DISTINCT C.USERID) DESC)Q ; -- 1421532

/* TO find the specific users that we should use as recipients of the STP_REMAINDER we have the following sql:
 This sql gives us randomly selected one BOT user for each KEYID (for USA, POLITICS) that has been generated 
 in the last 20 days. The theory is that with these users, we are likely to find larger instream volumes
*/

WITH KD AS (select KEYID FROM (
SELECT C.KEYID, K.CREATION_DTM, COUNT(DISTINCT C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID 
AND U.BOT_FLAG = 'Y' AND C.TOPICID = 1 AND K.COUNTRY_CODE = 'USA' AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 20 DAY
GROUP BY C.KEYID, K.CREATION_DTM ORDER BY COUNT(DISTINCT C.USERID) DESC)Q)
SELECT t1.KEYID, t1.USERID
FROM OPN_USER_CARTS t1
JOIN (
    SELECT KEYID, MIN(USERID) AS userid
    FROM OPN_USER_CARTS WHERE KEYID IN (SELECT KEYID FROM KD)
    GROUP BY KEYID
) t2 ON t1.KEYID = t2.KEYID
GROUP BY t1.KEYID;

SELECT K.KEYID, K.KEYWORDS, COUNT(C.USERID) FROM OPN_P_KW K, OPN_USER_CARTS C, OPN_USERLIST U
WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' AND U.COUNTRY_CODE = 'IND'
AND K.KEYWORDS LIKE '%NEWS' AND K.NEWS_ONLY_FLAG = 'Y' GROUP BY K.KEYID, K.KEYWORDS ORDER BY K.KEYID ;

SELECT USERID, COUNT(KEYID) FROM OPN_USER_CARTS WHERE KEYID = 105087 GROUP BY USERID HAVING COUNT(KEYID) > 1 ;

SELECT COUNT(1) FROM OPN_USER_CARTS WHERE USERID IS NULL ;
DELETE FROM OPN_USER_CARTS WHERE USERID IS NULL ;

SELECT * FROM OPN_USERLIST WHERE USERID IN (1023228, 1024484, 1029944, 1037751) ;
SELECT * FROM OPN_USER_CARTS WHERE USERID IN (1023228, 1024484, 1029944, 1037751) and KEYID = 105087 ;

DELETE FROM OPN_USER_CARTS WHERE ROW_ID IN (486363, 578789, 1056014, 1486313) ;

SELECT C.TOPICID, C.KEYID, COUNT(1) TCNT, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USA, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) IND
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGG FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND K.NEWS_ONLY_FLAG <> 'Y' GROUP BY C.TOPICID, C.KEYID 
HAVING SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) > 30 OR SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) > 30 
OR SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) > 30 
ORDER BY COUNT(1) ;

SELECT * FROM OPN_P_KW WHERE NEWS_ONLY_FLAG = 'Y' OR (KEYID BETWEEN 100000 AND 200000 AND TOPICID IN (3,5,10)) ORDER BY KEYID ;
SELECT * FROM OPN_P_KW WHERE CREATION_DTM >  CURRENT_DATE() - INTERVAL 300 DAY AND CREATED_BY_UID IN (SELECT USERID FROM OPN_USERLIST WHERE BOT_FLAG = 'Y') ORDER BY KEYID ; -- 144486

SELECT C.KEYID, K.CREATED_BY_UID, COUNT(C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 3 DAY AND C.USERID <> K.CREATED_BY_UID 
GROUP BY C.KEYID, K.CREATED_BY_UID ORDER BY 3 DESC ;

SELECT COUNT(1) FROM (
SELECT C.KEYID, K.CREATED_BY_UID, C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID > 106000 AND C.USERID <> K.CREATED_BY_UID)Q  ;

SELECT COUNT(1) FROM (
SELECT C.KEYID, K.CREATED_BY_UID, C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND C.KEYID < 106000 AND C.USERID <> K.CREATED_BY_UID)Q1
 ;

SELECT * FROM OPN_P_KW WHERE NEWS_ONLY_FLAG = 'Y' ORDER BY KEYID DESC ;

SELECT COUNT(1) FROM OPN_USER_CARTS WHERE CREATION_DTM > CURRENT_DATE() - INTERVAL 1 DAY ;
SELECT COUNT(DISTINCT KEYID) FROM OPN_USER_CARTS WHERE CREATION_DTM > CURRENT_DATE() - INTERVAL 1 DAY ;

DELETE FROM OPN_USER_CARTS WHERE ROW_ID IN (SELECT ROW_ID FROM (
SELECT C.KEYID, K.CREATED_BY_UID, C.ROW_ID FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' 
AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL 15 DAY AND C.KEYID > 106000 AND C.USERID <> K.CREATED_BY_UID)Q1);

DROP TABLE TEMP_CART_DELETE ;



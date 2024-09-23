SELECT * FROM OPN_XYZNEWS_BOTS ;

SELECT TOPICID, CCODE, COUNT(1) FROM OPN_XYZNEWS_BOTS GROUP BY  TOPICID, CCODE ORDER BY 1, 2 ;

DELETE FROM  OPN_XYZNEWS_BOTS WHERE CCODE = 'IND' ;

SELECT C.TOPICID, K.KEYID, K.KEYWORDS, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USACOUNT
, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) INDCOUNT
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGGCOUNT
FROM OPN_P_KW K, OPN_USER_CARTS C, OPN_USERLIST U
WHERE C.KEYID = K.KEYID AND C.USERID = U.USERID AND U.BOT_FLAG = 'Y' -- AND U.COUNTRY_CODE = 'USA'
AND K.KEYWORDS LIKE '%NEWS' AND K.NEWS_ONLY_FLAG = 'Y' GROUP BY C.TOPICID, K.KEYID, K.KEYWORDS ORDER BY K.KEYID ;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID IN (105108)
AND U.BOT_FLAG = 'Y' AND C.USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 3 )
;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID IN (105087, 105088, 105089, 105653, 105654, 105655)
AND U.BOT_FLAG = 'Y' 
;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID IN (105087, 105088, 105089, 105653, 105654, 105655)
AND U.BOT_FLAG = 'Y' AND C.USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 )
;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID IN (105087, 105088, 105089, 105653, 105654, 105655)
AND U.BOT_FLAG = 'Y' AND C.USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 )
;

INSERT INTO OPN_XYZNEWS_BOTS(USERID, USER_UUID, USERNAME, TOPICID, KEYID, TOPICNAME, CCODE)
SELECT DISTINCT C.USERID, U.USER_UUID, U.USERNAME, C.TOPICID, C.KEYID, UPPER(T.TOPIC), U.COUNTRY_CODE
FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_TOPICS T
WHERE C.USERID = U.USERID AND C.TOPICID = T.TOPICID AND C.KEYID IN (105087, 105088, 105089, 105653, 105654, 105655)
AND U.BOT_FLAG = 'Y' AND C.USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 )
;


INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 600)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 60)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 1000)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'USA')  
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 200)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105087, USERID, 1, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105087))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 20)Q ;

-- END OF TOPCID = 1 KEYID = 105087
-- STARTING TOPCID = 10 KEYID = 105088

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 300)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 30)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 1 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 200)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 20)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105088, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105088))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 10)Q ;

-- END OF TOPCID = 10 KEYID = 105088
-- STARTING TOPCID = 10 KEYID = 105089

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 600)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 30)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 1000)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 300)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105089, USERID, 10, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105089))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 10 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 30)Q ;

-- END OF TOPCID = 10 KEYID = 105089
-- STARTING TOPCID = 2 KEYID = 105654

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 300)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 30)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 600)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 60)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105654, USERID, 2, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105654))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 2 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 10)Q ;

-- END OF TOPCID = 2 KEYID = 105654
-- STARTING TOPCID = 4 KEYID = 105653

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 300)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 30)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 600)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 60)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105653, USERID, 4, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105653))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 4 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 10)Q ;

-- END OF TOPCID = 4 KEYID = 105653
-- STARTING TOPCID = 4 KEYID = 105655

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 300)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('IND')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'IND') 
ORDER BY RAND() LIMIT 30)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 600)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('USA')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'USA') 
ORDER BY RAND() LIMIT 60)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 100)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', 105655, USERID, 5, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE BOT_FLAG = 'Y' AND COUNTRY_CODE IN ('GGG')
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (105655))
AND USERID NOT IN (SELECT DISTINCT USERID FROM OPN_MAIN_BOTS WHERE TOPICID = 5 AND CCODE = 'GGG') 
ORDER BY RAND() LIMIT 10)Q ;

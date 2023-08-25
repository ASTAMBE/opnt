-- IN ORDER FOR THE STP_REMAINDER AND CREATEBOTDISCUSSION PROCS TO BE SUCCESSFUL, WE NEED 100+ USERS WITH VERY DEEP CARTS IN EACH INTEREST*CCODE COMBO

/* FIRST, LET'S CALCULATE HOW MANY BOT USERS HAVE DEEP CARTS (DEEP CART IS DEFINED AS HAVING AT LEAST 5 KWS OF THE INTEREST*CCODE COMBO

SET MATCHKID = (SELECT CASE WHEN tid = 1 then 105087 WHEN tid = 2 THEN 105654 WHEN tid = 3 THEN 105108 WHEN tid = 4 THEN 105653 
WHEN tid = 5 THEN 105655 WHEN tid = 8 THEN 80005 WHEN tid = 10 AND ccode = 'IND' THEN 105088
WHEN tid = 10 AND ccode <> 'IND' THEN 105089 END ) ;

-- LET'S SAY TID5*IND COMBO AND ALSO CHECK FOR CARTS THAT CONTAIN THE XYZNEWS OF THIS INTEREST  */

SELECT * FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;
SELECT * FROM WSR_CONVERTED ORDER BY ROW_ID DESC LIMIT 100 ;

SELECT C.USERID, COUNT(C.KEYID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND C.TOPICID = 1 AND U.COUNTRY_CODE = 'USA' AND K.COUNTRY_CODE = 'USA'
GROUP BY C.USERID HAVING COUNT(C.KEYID) > 1 AND EXISTS (SELECT 1 FROM OPN_USER_CARTS C2  WHERE C2.USERID = C.USERID AND C2.KEYID IN (105087) AND C2.CART = 'L') ;

SELECT C.USERID, COUNT(C.KEYID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND C.TOPICID = 10 AND U.COUNTRY_CODE = 'IND' AND K.COUNTRY_CODE = 'IND'
GROUP BY C.USERID HAVING COUNT(C.KEYID) > 3 AND EXISTS (SELECT 1 FROM OPN_USER_CARTS C2  WHERE C2.USERID = C.USERID AND C2.KEYID IN (105655, 105588, 105589) AND C2.CART = 'L') ;

SELECT C.USERID, COUNT(C.KEYID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND C.TOPICID = 5 AND U.COUNTRY_CODE = 'IND' AND K.COUNTRY_CODE = 'IND'
GROUP BY C.USERID HAVING COUNT(C.KEYID) > 5 AND NOT EXISTS (SELECT 1 FROM OPN_USER_CARTS C2  WHERE C2.USERID = C.USERID AND C2.KEYID IN (105655, 105588, 105589) AND C2.CART = 'L') ;

SELECT K.TOPICID, U.COUNTRY_CODE, K.KEYID, COUNT(DISTINCT C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND C.KEYID IN (105087, 105088, 105089, 105654, 105108, 105653, 105655, 80005) AND U.BOT_FLAG = 'Y'
GROUP BY K.TOPICID, U.COUNTRY_CODE, K.KEYID ORDER BY 1 ;

SELECT * FROM OPN_MAIN_BOTS ;
SELECT CCODE, TOPICID, COUNT(1) FROM OPN_MAIN_BOTS GROUP BY CCODE, TOPICID ORDER BY 1,2 ;

-- USE THE FOLLOWING CALL TO ADD BOTS THAT HAVE THE SPECIFIC XYZNEWS IN THEIR CARTS

CALL ADD_1KW_TO_N_BOTS(2, 'GGG', 'L', 105654, 20) ;
CALL ADD_1KW_TO_N_BOTS(3, 'GGG', 'L', 105108, 60) ; -- 105653
CALL ADD_1KW_TO_N_BOTS(4, 'GGG', 'L', 105653, 60) ;
CALL ADD_1KW_TO_N_BOTS(4, 'IND', 'L', 105653, 60) ;
CALL ADD_1KW_TO_N_BOTS(4, 'USA', 'L', 105653, 60) ;

CALL ADD_1KW_TO_N_BOTS(5, 'GGG', 'L', 105655, 60) ;
CALL ADD_1KW_TO_N_BOTS(5, 'IND', 'L', 105655, 60) ;
CALL ADD_1KW_TO_N_BOTS(5, 'USA', 'L', 105655, 60) ;

CALL ADD_1KW_TO_N_BOTS(10, 'GGG', 'L', 105089, 60) ;
CALL ADD_1KW_TO_N_BOTS(10, 'IND', 'L', 105088, 60) ;
CALL ADD_1KW_TO_N_BOTS(10, 'IND', 'L', 105089, 60) ;
CALL ADD_1KW_TO_N_BOTS(10, 'USA', 'L', 105089, 60) ;

SELECT * FROM OPN_USER_CARTS WHERE KEYID = 105088 AND TOPICID <> 10 ;

UPDATE OPN_USER_CARTS SET TOPICID = 10 WHERE KEYID = 105089 ;

SELECT * FROM OPN_USER_CARTS WHERE KEYID IN (105087) AND TOPICID <> 1 ;

DELETE FROM OPN_USER_CARTS WHERE KEYID IN (105087) AND TOPICID <> 1 ;

SELECT KEYID, TOPICID, COUNT(1) FROM OPN_USER_CARTS WHERE KEYID IN (SELECT KEYID FROM (
SELECT KEYID, COUNT(DISTINCT TOPICID) FROM OPN_USER_CARTS GROUP BY KEYID HAVING COUNT(DISTINCT TOPICID) > 1)Q1)
GROUP BY KEYID, TOPICID HAVING COUNT(1) > 1 ORDER BY 1, 2;

SELECT * FROM OPN_USER_CARTS WHERE KEYID = 105589 AND TOPICID <> 2 ; ;
DELETE FROM OPN_USER_CARTS WHERE KEYID = 25009 AND TOPICID <> 2 ; ;

CALL callSTDbyIntCcode(1, 'USA', 'POLITICS' , 3) ;

SELECT ROW_ID, SCRAPE_SOURCE FROM opntprod.WEB_SCRAPE_RAW_L WHERE COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC = 'POLITICS'  ORDER BY RAND() LIMIT 3 ;

CALL createBOTDiscussion('SCRAPE_TO_DISC', 667, 'USA', 'L' , 1, '','', '','' ) ;
CALL createBOTDiscussion('STD_NO_EXCRPT', 457, 'GGG', 'L' , 5, '','' , '', '', 5) ;
CALL createBOTDiscussion('STD_ONLY_DISC', 456, 'IND', 'L' , 10, '','', '','', 5 ) ;
SELECT * FROM OPN_USERLIST WHERE USERNAME = 'ASTGGGBIZ' ;
CALL callSTDbyENTCELEBIND(2) ;

INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_DTM_RAW, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, TAG_DONE_FLAG)
SELECT SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_DTM_RAW, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, TAG_DONE_FLAG FROM WEB_SCRAPE_RAW_L
WHERE ROW_ID = 569 ;

SELECT USERID, USERNAME, USER_UUID  FROM (
SELECT U1.USERID, U1.USERNAME, U1.USER_UUID, U1.COUNTRY_CODE, COUNT(DISTINCT C1.KEYID) KEYCNT FROM OPN_USER_CARTS C1, OPN_USERLIST U1
WHERE C1.USERID = U1.USERID AND U1.COUNTRY_CODE = 'USA' AND C1.TOPICID = 1 AND U1.BOT_FLAG = 'Y'
and EXISTS (SELECT 1 FROM OPN_USER_CARTS C2  WHERE C2.USERID = C1.USERID AND C2.KEYID = 105087 AND C2.CART = 'L')
GROUP BY U1.USERID HAVING COUNT(DISTINCT C1.KEYID) > 5 ORDER BY RAND() LIMIT 1)Q ;

SELECT USERID, USERNAME, USER_UUID  FROM OPN_MAIN_BOTS WHERE CCODE = 'USA' AND TOPICID = 1 ORDER BY RAND() LIMIT 1 ;
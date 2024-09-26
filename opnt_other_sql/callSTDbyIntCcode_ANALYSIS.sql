SET SQL_SAFE_UPDATES = 0;
SELECT * FROM OPN_POSTS ORDER BY POST_ID DESC LIMIT 10 ;
SELECT * FROM OPN_POSTS where post_id in (1280544, 1280540) ;
SELECT * FROM OPN_POSTS_RAW ORDER BY POST_ID DESC LIMIT 10 ;
SELECT * FROM OPN_POST_SEARCH_T ORDER BY POST_ID DESC LIMIT 100 ;
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC LIMIT 10 ;
SELECT * FROM WSR_CONVERTED ORDER BY ROW_ID DESC LIMIT 100 ;
SELECT COUNT(1) FROM WSR_CONVERTED ;
SELECT * FROM OPN_POSTS WHERE POST_ID = 1271822 ;
SELECT * FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'USA' ORDER BY ROW_ID DESC ;
SELECT SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TOPIC, COUNT(1) FROM WEB_SCRAPE_RAW_L GROUP BY SCRAPE_DATE, COUNTRY_CODE, SCRAPE_TOPIC ORDER BY 1, 2 ;
SELECT COUNTRY_CODE, SCRAPE_TOPIC, COUNT(1) FROM WEB_SCRAPE_RAW GROUP BY COUNTRY_CODE, SCRAPE_TOPIC ORDER BY 1, 2 ;
SELECT * FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE = '2023-11-17' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC = 'SPORTS' ;
DELETE FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE <> '2023-11-17';
CALL createBOTDiscussion('SCRAPE_TO_DISC', 17, 'GGG', 'L' , 1, '','', '','' ) ;
SELECT * FROM OPN_POSTS WHERE STP_PROC_NAME = 'SCRAPE_TO_DISC' ORDER BY POST_ID DESC ;
SELECT SCRAPE_SOURCE, COUNT(1) FROM OPN_POSTS WHERE POST_ID > 1270000 GROUP BY SCRAPE_SOURCE;
SELECT SCRAPE_DATE, SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW_L GROUP BY SCRAPE_DATE, SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1 DESC ;
SELECT * FROM OPN_USERLIST WHERE USERNAME LIKE'AST%' AND COUNTRY_CODE = 'GGG' ; -- ASTCMC1/1022601
DELETE FROM WEB_SCRAPE_RAW_L WHERE COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC = 'POLITICS' ;
CALL showInitialDiscussions(BRINGuuid(1022601), 1, 0, 30) ;
SELECT * FROM OPN_P_KW WHERE KEYID IN (109926, 109919, 109916) ;
CALL getDiscussionsANTI(bringuuid(1022601), 1, 0, 30) ;
CALL getInstreamNW(bringuuid(1022601), 1, 0, 30) ;

SELECT * FROM OPN_P_KW WHERE KW_URL IS NOT NULL AND LENGTH(KW_URL) < 50 ;
CALL STD_MANAGER(1, 'GGG', 'POLITICS') ;
CALL STD_MANAGER(1, 'IND', 'POLITICS') ;
CALL STD_MANAGER(1, 'USA', 'POLITICS') ;
CALL STD_MANAGER(2, 'GGG', 'SPORTS') ;
CALL STD_MANAGER(2, 'IND', 'SPORTS') ;
CALL STD_MANAGER(2, 'USA', 'SPORTS') ;
CALL STD_MANAGER(3, 'GGG', 'SCIENCE') ;
CALL STD_MANAGER(4, 'GGG', 'BUSINESS') ;
CALL STD_MANAGER(4, 'IND', 'BUSINESS') ;
CALL STD_MANAGER(4, 'USA', 'BUSINESS') ;
CALL STD_MANAGER(5, 'IND', 'ENT') ;
CALL STD_MANAGER(5, 'USA', 'ENT') ;
CALL STD_MANAGER(10, 'USA', 'CELEB') ;
CALL callSTDbyENTCELEBIND(120) ;
DELETE FROM WEB_SCRAPE_RAW WHERE COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC = 'POLITICS' ;

SELECT TOPICID, STP_PROC_NAME, POSTOR_COUNTRY_CODE, COUNT(1) FROM OPN_POSTS WHERE POST_ID > 1235000 -- AND STP_PROC_NAME = 'SCRAPE_TO_DISC' 
AND POST_DATETIME > CURRENT_DATE() - INTERVAL 2 DAY GROUP BY TOPICID, STP_PROC_NAME, POSTOR_COUNTRY_CODE ORDER BY 1,2 ;
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;

SELECT ROW_ID, SCRAPE_SOURCE FROM opntprod.WEB_SCRAPE_RAW_L WHERE COUNTRY_CODE = ccode AND SCRAPE_TOPIC = scr_tpc  ORDER BY RAND() LIMIT howMany ;

CALL callSTDbyIntCcode(3, 'GGG', 'SCIENCE' , 3) ;
CALL callSTDbyIntCcode(5, 'GGG', 'ENT' , 3) ;
CALL callSTDbyIntCcode(10, 'USA', 'CELEB' , 3) ;

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

SELECT * FROM WSR_CONVERTED WHERE ROW_ID > 965000 AND  NEWS_URL = 'https://www.nytimes.com/2023/11/03/world/middleeast/hamas-gaza-evacuees-rafah-crossing.html'  ;
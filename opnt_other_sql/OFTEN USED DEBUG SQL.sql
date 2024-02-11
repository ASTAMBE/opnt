SET SQL_SAFE_UPDATES = 0;

SELECT * FROM OPN_USERLIST order by USERID desc ; -- 1023365
SELECT * FROM OPN_USERLIST WHERE USERNAME LIKE 'ASTCMC%' order by USERID desc ; -- 1023365
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;
SELECT * FROM OPN_P_KW WHERE KEYWORDS LIKE '%MODI%' ;
SELECT * FROM OPN_KW_TAGS ORDER BY KEYID DESC ; 
SELECT * FROM OPN_USER_BHV_LOG ORDER BY ROW_ID DESC ; -- 47772
SELECT * FROM OPN_USER_CARTS WHERE USERID IN (1022725, 1006539) AND TOPICID = 9 ;
SELECT * FROM OPN_USER_DEVICE_LOG ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_P_KW WHERE KEYID NOT IN (SELECT KEYID FROM OPN_KW_TAGS) ORDER BY KEYID DESC ;
SELECT * FROM OPN_USER_INTERESTS WHERE USERID IN (1002398, 1006539) ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_USERLIST WHERE USERID IN (1002397, 1006539, 1022725) ;
SELECT * FROM OPN_POSTS ORDER BY POST_ID DESC ;
SELECT TIME_TO_SEC(TIMEDIFF(NOW(), POST_DATETIME)) diff FROM OPN_POSTS WHERE POST_ID = 722598 ;
SELECT * FROM OPN_USERLIST  WHERE USER_UUID = '9399eff5-7019-11eb-961c-06500c451eb8' ; 
SELECT * FROM OPN_INVITE_ACCEPT_LOG ;
SELECT * FROM OPN_POSTS WHERE POST_ID = 722375 ;
SELECT ROUTINE_TYPE, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' AND ROUTINE_DEFINITION LIKE '%UPDATED_BY_PROC%' ;

SELECT ROUTINE_TYPE, ROUTINE_NAME, LAST_ALTERED, LENGTH(ROUTINE_DEFINITION) RLEN FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' ORDER BY 3 DESC LIMIT 30 ;

SELECT MONTH(CREATION_DATE) MTH, COUNTRY_CODE, USER_TYPE, COUNT(1) FROM OPN_USERLIST WHERE CREATION_DATE > CURRENT_DATE - INTERVAL 200 DAY GROUP BY MONTH(CREATION_DATE), COUNTRY_CODE, USER_TYPE ORDER BY 1;
SELECT MONTH(CREATION_DATE) MTH,  COUNT(1) FROM OPN_USERLIST WHERE USER_TYPE in ('USER', 'GUEST') AND CREATION_DATE > CURRENT_DATE - INTERVAL 100 DAY GROUP BY MONTH(CREATION_DATE) ORDER BY 1;
SELECT MONTH(CREATION_DATE) MTH, TRUE_COUNTRY_CODE,  COUNT(1) FROM OPN_USERLIST WHERE USER_TYPE = 'USER' 
AND CREATION_DATE > CURRENT_DATE - INTERVAL 10 DAY GROUP BY MONTH(CREATION_DATE), TRUE_COUNTRY_CODE ORDER BY 1;

SELECT TOPICID, POSTOR_COUNTRY_CODE, SUM(CASE WHEN STP_PROC_NAME = 'STP_REMAINDER' THEN 1 ELSE 0 END) RMND_CNT 
, SUM(CASE WHEN STP_PROC_NAME = 'STP_STAG23_MICRO' THEN 1 ELSE 0 END) MACRO_CNT
FROM OPN_POSTS WHERE POST_DATETIME > CURRENT_DATE() - INTERVAL 2 DAY  GROUP BY TOPICID, POSTOR_COUNTRY_CODE ;
 
SELECT K.KEYID, K.KEYWORDS, T.TOPICID, T.TOPIC, CAST(P.POST_PROCESSED_DTM AS DATE) PPDT, P.POSTOR_COUNTRY_CODE, COUNT(P.POST_ID)
FROM OPN_P_KW K, OPN_TOPICS T, OPN_POSTS P
WHERE P.TAG1_KEYID = K.KEYID AND P.POST_PROCESSED_DTM > CURRENT_DATE() - INTERVAL 1 DAY
AND P.TOPICID = T.TOPICID AND K.KEYWORDS LIKE '%NEWS%'
GROUP BY K.KEYID, K.KEYWORDS, T.TOPICID, T.TOPIC, CAST(P.POST_PROCESSED_DTM AS DATE), P.POSTOR_COUNTRY_CODE ORDER  BY T.TOPICID, CAST(P.POST_PROCESSED_DTM AS DATE);

-- 1033268 'Love Your Lord' is the last common user between prod and dev. after that, dev was separated

SELECT * FROM OPN_USERLIST WHERE USER_TYPE = 'USER' AND USERID > 1033268 ;
SELECT * FROM OPN_POSTS WHERE POST_ID > 1330647 AND TOPICID = 1 AND POSTOR_COUNTRY_CODE = 'USA' ORDER BY POST_ID DESC LIMIT 100 ;

SELECT * FROM OPN_PUSH_LAUNCH ;

SELECT COUNTRY_CODE, SCRAPE_TOPIC, COUNT(1) FROM WSR_CONVERTED WHERE ROW_ID > 915000 AND  SCRAPE_DATE > '2023-09-08' GROUP BY COUNTRY_CODE, SCRAPE_TOPIC ORDER BY 1, 2 ;
SELECT SCRAPE_SOURCE, COUNT(1) FROM WSR_CONVERTED WHERE ROW_ID > 915000 AND  NEWS_DATE > '2023-09-08' AND SCRAPE_TOPIC IN ('BUSINESS')
AND COUNTRY_CODE = 'IND' GROUP BY SCRAPE_SOURCE ORDER BY 1, 2 ;
SELECT SCRAPE_SOURCE, COUNT(1) FROM WSR_CONVERTED WHERE ROW_ID > 915000 AND  NEWS_DATE > '2023-09-08' AND COUNTRY_CODE = 'IND' GROUP BY SCRAPE_SOURCE ORDER BY 1, 2 ;



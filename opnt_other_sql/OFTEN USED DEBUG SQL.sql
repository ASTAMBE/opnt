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
 
SELECT K.KEYID, K.KEYWORDS, T.TOPICID, T.TOPIC, CAST(P.POST_PROCESSED_DTM AS DATE) PPDT, P.POSTOR_COUNTRY_CODE, COUNT(P.POST_ID)
FROM OPN_P_KW K, OPN_TOPICS T, OPN_POSTS P
WHERE P.TAG1_KEYID = K.KEYID AND P.POST_PROCESSED_DTM > CURRENT_DATE() - INTERVAL 1 DAY
AND P.TOPICID = T.TOPICID AND K.KEYWORDS LIKE '%NEWS%'
GROUP BY K.KEYID, K.KEYWORDS, T.TOPICID, T.TOPIC, CAST(P.POST_PROCESSED_DTM AS DATE), P.POSTOR_COUNTRY_CODE ORDER  BY T.TOPICID, CAST(P.POST_PROCESSED_DTM AS DATE);

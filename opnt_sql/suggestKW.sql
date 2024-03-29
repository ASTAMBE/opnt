-- suggestKW

DELIMITER //
DROP PROCEDURE IF EXISTS suggestKW //
CREATE  PROCEDURE `suggestKW`( UUID varchar(45))
thisproc: BEGIN
/* 
05/22/2021 AST: This proc is used for suggesting the new KWs for the calling user
06/14/2021 AST:  When the IVL is very large, the call takes over 16 sec. to address this, we need to split
the results into 2 sections: 
1. where IVL = 30 days - also P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY for much faster
2. If the above section brings < 1 results then section 2 will bring any unused KWs.
 */
declare  UID, IVL, IVLCNT INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'suggestKW', CONCAT('suggested KWs -',CCODE));

/* end of use action tracking */

SET IVL = 30 ;

SET IVLCNT = (SELECT COUNT(1) FROM (

SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 9 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q9
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 1  AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q1 
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 2 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q2
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 4 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q4
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 5 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q5
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 10 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q10
)QQ
) ;


CASE WHEN IVLCNT < 1 THEN

SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 9  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q9
UNION ALL
SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 1  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q1
UNION ALL
SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 2  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q2 
UNION ALL
SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 4  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q4
UNION ALL
SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 5  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q5 
UNION ALL
SELECT TOPIC, TOPICID, KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, K.KEYID, K.KEYWORDS FROM OPN_P_KW K, OPN_TOPICS T
WHERE K.TOPICID = T.TOPICID AND LENGTH(K.KEYWORDS) > 7
-- AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY
AND K.TOPICID = 10  AND K.COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY K.KEYID DESC LIMIT 1
) Q10
;

WHEN IVLCNT >= 1 THEN

SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 9 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q9
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 1  AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q1 
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 2 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q2
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 4 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q4
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 5 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q5
UNION ALL
SELECT TOPIC, TOPICID, TAG1_KEYID KEYID, KEYWORDS FROM (
SELECT T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS, COUNT(P.POST_ID) PCNT FROM OPN_POSTS P, OPN_P_KW K, OPN_TOPICS T
WHERE P.TAG1_KEYID = K.KEYID AND K.TOPICID = T.TOPICID
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL IVL DAY
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL IVL DAY
AND P.TAG1_KEYID IS NOT NULL AND P.TOPICID = 10 AND K.COUNTRY_CODE = CCODE
AND P.POSTOR_COUNTRY_CODE = CCODE AND K.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID)
GROUP BY T.TOPIC, T.TOPICID, P.TAG1_KEYID, K.KEYWORDS ORDER BY COUNT(P.POST_ID) DESC LIMIT 2
) Q10
;

END CASE ;





END //
DELIMITER ;

-- 

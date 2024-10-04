-- showFreshContent

 DELIMITER //
DROP PROCEDURE IF EXISTS showFreshContent //
CREATE PROCEDURE showFreshContent(uuid varchar(45), fromIndex INT, toIndex INT)
BEGIN

/*
10/02/2024 AST: This proc is for showing the latest/active/interesting discussions to the users when they change their interest selections
We can also show this as a daily or every time that the user opens the app
Eventually we can use the AI to select the correct contents - currently it is using the RAND

This code has an outer CASE statement - that checks simply if for this USERID and CCODE and the INTEREST_ID set, are there at least 30 discussions
in the last 30 days. If yes, then it proceeds to bring them. The second CASE is to bifurcate the treatment of TID 3 - which needs to use GGG as the CCODE

The main SELECT (and the PCNT) also checks if any of the resulting discussions have already been put into the cart by this user - and excludes them.


*/

declare  uid, tid, PCNT INT ;
DECLARE ccode VARCHAR(5) ;
DECLARE UNAME VARCHAR(50) ;

SELECT USERID, COUNTRY_CODE, USERNAME INTO uid, ccode, UNAME FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SET PCNT = (SELECT COUNT(1) FROM OPN_POSTS P WHERE P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y' AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 1 DAY  AND P.DEMO_POST_FLAG <> 'Y' 
AND P.TOPICID IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = uid) AND P.POSTOR_COUNTRY_CODE = ccode  AND P.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)) ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, uid, uuid, NOW(), 'showFreshContent', CONCAT(uid,'-',ccode));

/* end of use action tracking */

CASE WHEN PCNT >= 30 THEN


CASE 
        WHEN EXISTS (SELECT 1 
                     FROM OPN_USER_INTERESTS  I
                     WHERE I.USERID = uid 
                       AND I.INTEREST_ID = 3) 
        THEN 
        SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, P.KEYID, COUNT(C.USERID) USERCOUNT FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 1 DAY  AND P.DEMO_POST_FLAG <> 'Y' AND P.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)
AND P.TOPICID NOT IN (3) AND P.TOPICID IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = uid) 
AND P.POSTOR_COUNTRY_CODE = CCODE GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) , P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, P.KEYID
UNION ALL 
SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, P.KEYID, COUNT(C.USERID) USERCOUNT FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 1 DAY  AND P.DEMO_POST_FLAG <> 'Y' AND P.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)
AND P.TOPICID IN (3)  AND P.POSTOR_COUNTRY_CODE = 'GGG' GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT), P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, P.KEYID
 ORDER BY RAND() LIMIT fromIndex, toIndex ;
 
 ELSE 
	SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID,P.KEYID, COUNT(C.USERID) USERCOUNT FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 1 DAY  AND P.DEMO_POST_FLAG <> 'Y' AND P.KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)
AND P.TOPICID NOT IN (3) AND P.TOPICID IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = uid) 
AND P.POSTOR_COUNTRY_CODE = CCODE GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) , P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, P.KEYID
ORDER BY RAND() LIMIT fromIndex, toIndex ;

END CASE ;

ELSE 

	CASE 
        WHEN EXISTS (SELECT 1 
                     FROM OPN_USER_INTERESTS  I
                     WHERE I.USERID = uid 
                       AND I.INTEREST_ID = 3) 
        THEN 
        SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, COUNT(C.USERID) FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 10 DAY  AND P.DEMO_POST_FLAG <> 'Y' 
AND P.TOPICID NOT IN (3) AND P.TOPICID IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = uid) 
AND P.POSTOR_COUNTRY_CODE = CCODE GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) , P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID
UNION ALL 
SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, COUNT(C.USERID) FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 10 DAY  AND P.DEMO_POST_FLAG <> 'Y' 
AND P.TOPICID IN (3)  AND P.POSTOR_COUNTRY_CODE = 'GGG' GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT), P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID
 ORDER BY RAND() LIMIT fromIndex, toIndex ;
 
 ELSE 
	SELECT P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) SHOW_CONTENT, P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID, COUNT(C.USERID) FROM OPN_POSTS P, OPN_USER_CARTS C
WHERE P.KEYID = C.KEYID AND P.CLEAN_POST_FLAG = 'Y' AND IFNULL(P.DELETED_FLAG, 'N') <> 'Y'
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 10 DAY  AND P.DEMO_POST_FLAG <> 'Y' 
AND P.TOPICID NOT IN (3) AND P.TOPICID IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = uid) 
AND P.POSTOR_COUNTRY_CODE = CCODE GROUP BY P.TOPICID, IFNULL(P.URL_TITLE, P.POST_CONTENT) , P.POST_CONTENT, P.POSTOR_COUNTRY_CODE, P.POST_ID
ORDER BY RAND() LIMIT fromIndex, toIndex ;

END CASE ;

END CASE ;


END //
DELIMITER ;

-- 

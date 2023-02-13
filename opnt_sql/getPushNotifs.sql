-- getPushNotifs

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getPushNotifs //
CREATE PROCEDURE getPushNotifs()
BEGIN

/* 
 08/11/2020 Kapil: Confirmed
 08/28/2020 AST: adding the PUSH_TYPE, PUSH_TITLE, SOURCE_ID
 09/07/2020 AST : Removed old sql
 */


SELECT L.APP_TOKEN, L.USERID, UL.USERNAME, L.USER_PLATFORM LAST_USED_PLATFORM, L.PUSH_TOPIC
, L.PUSH_TYPE, L.PUSH_TITLE, L.SOURCE_ID, COUNT(1) PUSHCOUNT
FROM OPN_PUSH_LAUNCH L, OPN_USERLIST UL,
(SELECT APP_TOKEN APT, USER_PLATFORM, MAX(USERID) MUID FROM OPN_PUSH_LAUNCH -- WHERE USERID IN (1022540)
GROUP BY APP_TOKEN, USER_PLATFORM) M
WHERE L.APP_TOKEN = M.APT AND L.USERID = M.MUID AND L.USER_PLATFORM = M.USER_PLATFORM
AND L.USERID = UL.USERID
GROUP BY L.APP_TOKEN, L.USERID, UL.USERNAME, L.USER_PLATFORM, L.PUSH_TOPIC
, L.PUSH_TYPE, L.PUSH_TITLE, L.SOURCE_ID
;

 TRUNCATE TABLE OPN_PUSH_LAUNCH ;


END //
DELIMITER ;

-- 
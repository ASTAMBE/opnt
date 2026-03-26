-- getUserInterests

DELIMITER //
DROP PROCEDURE IF EXISTS getUserInterests //
CREATE PROCEDURE `getUserInterests`(uuid VARCHAR(45))
BEGIN

/*
05/16/2020 AST: Creating this proc to build the Interest List (already selected and unselected)
for a user.

05/26/2020 AST: Added the USR BHV section
08/11/2020 Kapil: Confirmed

02/10/2024 AST: Changing this proc to not use the OPN_USER_INTEREST_V which was messing up the performance
Now it is < 0.5 sec instead of 6.5 sec
*/

declare  orig_uid INT;
declare UNAME VARCHAR(40) ;

SELECT USERNAME, USERID INTO UNAME, orig_uid FROM OPN_USERLIST WHERE USER_UUID = uuid;

/* adding the user action tracking portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, UUID, NOW(), 'getUserInterests', CONCAT(orig_uid,'-',UNAME));


/* end of use action tracking */

SELECT T.TOPICID, T.TOPIC, T.CODE, IF(I.INTEREST_ID IS NULL, 'N', 'Y') 'SLCT'
FROM OPN_TOPICS T LEFT OUTER JOIN OPN_USER_INTERESTS I ON T.TOPICID = I.INTEREST_ID
AND I.USERID = orig_uid
;
  
END //
DELIMITER ;

-- 
-- getUserInterests

DELIMITER //
DROP PROCEDURE IF EXISTS getUserInterests //
CREATE DEFINER=`root`@`%` PROCEDURE `getUserInterests`(uuid VARCHAR(45))
BEGIN

/*
05/16/2020 AST: Creating this proc to build the Interest List (already selected and unselected)
for a user.

05/26/2020 AST: Added the USR BHV section
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
declare UNAME VARCHAR(40) ;

SELECT USERNAME, USERID INTO UNAME, orig_uid FROM OPN_USERLIST WHERE USER_UUID = uuid;

/* adding the user action tracking portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, UUID, NOW(), 'getUserInterests', CONCAT(orig_uid,'-',UNAME));


/* end of use action tracking */

SELECT T.TOPICID, T.TOPIC, T.CODE, IF(IV2.SELECTED_KW_COUNT IS NULL, 'N', 'Y') 'SLCT'
FROM OPN_TOPICS T LEFT OUTER JOIN 
(SELECT IV.INTEREST_ID, IV.INTEREST_NAME, IV.INTEREST_CODE, IV.SELECTED_KW_COUNT
FROM OPN_USER_INTERESTS_V IV WHERE IV.USERID = orig_uid) IV2
ON T.TOPICID = IV2.INTEREST_ID ORDER BY T.CODE
;
  
END //
DELIMITER ;

-- 
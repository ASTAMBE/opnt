-- saveUserInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS saveUserInterests //
CREATE PROCEDURE saveUserInterests(uuid varchar(45), tid INT)
BEGIN

/* 	

06/09/2020 AST: Initial Creation for recording the User Interests when the user signs up first
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid, pbuid INT;
declare uname, intName varchar(40) ;
declare intCode varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USERNAME INTO orig_uid, uname FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT T.TOPIC, T.CODE INTO intName, intCode FROM OPN_TOPICS T WHERE T.TOPICID = tid ;

DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME, INTEREST_CODE, CREATION_DTM, USERNAME)
VALUES (orig_uid, uuid, tid, intName, intCode, NOW(), uname);


END //
DELIMITER ;

-- 
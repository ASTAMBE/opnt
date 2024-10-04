-- reflectCartInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS reflectCartInterests //
CREATE PROCEDURE reflectCartInterests(uuid varchar(45))
BEGIN

/* 	

09/30/2024 AST: This proc is created to reflect the Interest changes that occur due to the changes in 
a user's cart - E.g. a user may completely remove all the KWs in one or more Interests 
This proc should be called only through the insertUserCartsByTopic.php after the insert step forloop

*/

declare  orig_uid, pbuid INT;
declare uname, intName varchar(40) ;
declare intCode varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USERNAME INTO orig_uid, uname FROM OPN_USERLIST WHERE USER_UUID = uuid ;
-- SELECT T.TOPIC, T.CODE INTO intName, intCode FROM OPN_TOPICS T WHERE T.TOPICID = tid ;

-- DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid ;

DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid
-- AND TOPICID NOT IN (SELECT DISTINCT TOPICID FROM OPN_USER_CARTS WHERE USERID = orig_uid) 
; 

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT orig_uid, uuid, T1.TOPICID, T1.TOPIC, T1.CODE, NOW(), uname FROM 
(SELECT TOPICID, TOPIC, CODE FROM OPN_TOPICS WHERE TOPICID IN (SELECT DISTINCT TOPICID FROM OPN_USER_CARTS WHERE USERID = orig_uid)
)T1
;



END //
DELIMITER ;

-- 
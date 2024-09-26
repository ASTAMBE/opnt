-- insertUserInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS insertUserInterests //
CREATE PROCEDURE insertUserInterests(uuid varchar(45))
BEGIN

/* 	

09/17/2024 AST: This proc is being created to save a user's interests (TOPICIDS) after his 
cart is saved. This proc should be called from the API (insertUserCartsByTopic.php) itself 
after the cart save process is complete.

This will ensure that after any change in the cart, we will rebuild the interest profile of the user

*/

declare  orig_uid, pbuid INT;
declare uname, intName varchar(40) ;
declare intCode varchar(3) ;

SET SQL_SAFE_UPDATES = 0;
SET orig_uid = (SELECT USERID FROM OPN_USERLIST WHERE USER_UUID = uuid) ;

DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME, INTEREST_CODE, CREATION_DTM, SELECTED_KW_COUNT, USERNAME)
SELECT UI.USERID, U.USER_UUID, UI.INTEREST_ID, T.TOPIC, T.CODE INTEREST_CODE, NOW() CREATION_DTM, UI.SELECTED_KW_COUNT, U.USERNAME 
FROM (SELECT USERID, TOPICID INTEREST_ID, COUNT(DISTINCT KEYID) SELECTED_KW_COUNT FROM OPN_USER_CARTS WHERE USERID = orig_uid GROUP BY USERID, TOPICID) UI
, (SELECT USERID, USER_UUID, USERNAME FROM OPN_USERLIST WHERE USERID = orig_uid) U, OPN_TOPICS T
WHERE UI.USERID = U.USERID AND UI.INTEREST_ID = T.TOPICID AND UI.USERID = orig_uid ;


END //
DELIMITER ;

-- 
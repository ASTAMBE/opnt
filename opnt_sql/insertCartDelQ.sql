-- insertCartDelQ

 DELIMITER //
DROP PROCEDURE IF EXISTS insertCartDelQ //
CREATE PROCEDURE insertCartDelQ(userid varchar(45), topicid INT)
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */
declare  orig_uid, pbuid INT;

SET @orig_uid := (SELECT  bringUserid(userid));
-- SET @Ppbuid := (SELECT bringUseridFromUsername(postuserid));

-- ADDED THE LINE BELOW AS A STEP FOR MAKING LAST_UPDATE_DTM-BASED CLUSTERING

DELETE FROM OPN_CART_ARCHIVE WHERE OPN_CART_ARCHIVE.USERID = @orig_uid AND OPN_CART_ARCHIVE.TOPICID = topicid;  

-- THE DELETE FROM OPN_CART_ARCHIVE HAD TO BE ADDED BEFORE THE DELETE FROM OPN_USER_CARTS. ELSE IT DOESN'T WORK.

DELETE FROM OPN_USER_CARTS WHERE OPN_USER_CARTS.USERID = @orig_uid AND OPN_USER_CARTS.TOPICID = topicid;  

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(userid), @orig_uid, userid, NOW(), 'insertCartDelQ', CONCAT(@orig_uid,'-',topicid));

/* end of user action tracking */




END //
DELIMITER ;

-- 
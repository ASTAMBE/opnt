-- insertCartDelQ

 DELIMITER //
DROP PROCEDURE IF EXISTS insertCartDelQ //
CREATE PROCEDURE insertCartDelQ(userid varchar(45), topicid INT)
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
  12/24/2024 AST: Nullifying this proc - by commenting out the DELETE FROM OPN_USER_CARTS
        Why ? because the insertCartDelQ is messing up the showFreshCOntent - by removing the existing
        keys from the user's cart in order to save teh SFC selections.
        This could have been handled by having a separate process for the SFC selections - but that 
        will require more dev - might as well fix the basic problem - the cart should have always been an UPSERT
        The orig insertCartInsertQ has been saved in the DOC folder just in case.
        
        01/29/2025 AST: Turning back on the DELETE of cart for the user - in NEWDEV only for the time being
 */
declare  orig_uid, pbuid INT;

SET @orig_uid := (SELECT  bringUserid(userid));
-- SET @Ppbuid := (SELECT bringUseridFromUsername(postuserid));

-- ADDED THE LINE BELOW AS A STEP FOR MAKING LAST_UPDATE_DTM-BASED CLUSTERING

-- DELETE FROM OPN_CART_ARCHIVE WHERE OPN_CART_ARCHIVE.USERID = @orig_uid AND OPN_CART_ARCHIVE.TOPICID = topicid;  

-- THE DELETE FROM OPN_CART_ARCHIVE HAD TO BE ADDED BEFORE THE DELETE FROM OPN_USER_CARTS. ELSE IT DOESN'T WORK.

DELETE FROM OPN_USER_CARTS WHERE OPN_USER_CARTS.USERID = @orig_uid AND OPN_USER_CARTS.TOPICID = topicid;  

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(userid), @orig_uid, userid, NOW(), 'insertCartDelQ', CONCAT(@orig_uid,'-',topicid));

/* end of user action tracking */




END //
DELIMITER ;

-- 
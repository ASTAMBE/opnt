-- removeKWFromUIDTIDKID

 DELIMITER //
DROP PROCEDURE IF EXISTS removeKWFromUIDTIDKID //
CREATE PROCEDURE removeKWFromUIDTIDKID(UID INT, TID INT, KID INT)
BEGIN

DECLARE AlreadyExists INT;
DECLARE USUUID VARCHAR(45) ;

DELETE FROM OPN_CART_ARCHIVE WHERE USERID = UID AND TOPICID = TID;

INSERT INTO OPN_CART_ARCHIVE(OLD_CART_ID, USERID, TOPICID, CART, KEYID, CREATION_DTM, DELETE_DTM)
SELECT ROW_ID, USERID, TOPICID, CART, KEYID, CREATION_DTM, NOW() FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UID AND KEYID = KID ;

SET USUUID = bringUUID(UID) ;

CALL ludtmUpdate(USUUID, TID) ;

CALL NEWCART_TOP(USUUID, TID);

  
END //
DELIMITER ;

-- 
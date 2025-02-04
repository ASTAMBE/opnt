-- insertSFC

 DELIMITER //
DROP PROCEDURE IF EXISTS insertSFC //
CREATE PROCEDURE insertSFC(uuid varchar(45), tid INT, kid INT, cartv varchar(3))
thisproc:BEGIN

/*     01/29/2025 AST: Creating this proc to insert the showFreshContent selections from the SFC window
Currently the app is using the insertCartInsertQ - which ends up overwriting the existing KIDs from the user cart
Hence this proc will do the job of only adding the SFC KIDs. contd..
*/

declare  orig_uid, kidtid INT;
DECLARE SUSP, orig_cart VARCHAR(5) ;

SELECT  USERID, USER_SUSPEND_FLAG INTO orig_uid, SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT TOPICID INTO kidtid FROM OPN_P_KW WHERE KEYID = kid;

/* why do we do kidtid ? because the app code is sometimes messed up and gets wrong TOPICID for a KEYID. 
The kidtid ensures that even if the app messes up the TID, the kidtid will ensure the correct TID being inserted */

IF SUSP = 'Y' THEN LEAVE thisproc ;

ELSE

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(uuid), orig_uid, uuid, NOW(), 'insertSFC', CONCAT('uid-tid-kidtid-kid-cart:',orig_uid,'-',kidtid, '-', tid, '-', kid, '-', cartv));

/* end of user action tracking */

/* First step is to remove the KID from the cart IF IT ALREADY EXISTS in the cart
This is not supposed to happen - because the SFC ensures that we show only those KIDs that are NOT in the cart already
This is a precautionary step (DELETE) to ensure that there are never any double-entered KIDs in the cart */

DELETE FROM OPN_USER_CARTS WHERE USERID = orig_uid AND KEYID = kid ;

INSERT INTO OPN_USER_CARTS(TOPICID, USERID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (kidtid, orig_uid, kid, cartv, NOW(), NOW());


/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(uuid), orig_uid, uuid, NOW(), 'insertSFC', CONCAT('uid-tid-kid-cart:',orig_uid,'-',kidtid, '-', kid, '-', cartv));

/* end of user action tracking */

END IF ;


END //
DELIMITER ;

-- 
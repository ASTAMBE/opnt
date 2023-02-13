-- addSearchKwToCart

 DELIMITER //
DROP PROCEDURE IF EXISTS addSearchKwToCart //
CREATE PROCEDURE addSearchKwToCart(tid INT -- , ccode VARCHAR(5)
, uuid varchar(45), cartv VARCHAR(3), kid INT)
thisProc: BEGIN

/* This proc is for adding the KWs to a user's cart where the KWs 
are selected from the results of a search
This proc is the first usage of the composite key for OUC. 
OUC now has a composite key of UID+TOPICID+KEYID

This will use the INSERT OR UPDATE  strategy
It will also not invoke the CLustering - 
as a new network algo has been developed that eliminates clustering

addSearchKwToCart(tid , ccode , uuid , cartv , kid )

04/25/2020 AST: Actually removed the cluster call today. 

05/26/2020 AST: Removing the ccode from Input Params
08/19/2020 Kapil: Confirmed

*/

  DECLARE  UID INT ;
  DECLARE SUSP VARCHAR(5) ;

SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE

SET UID = (SELECT bringUserid(uuid)) ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(uuid), UID, uuid, NOW()
, 'addSearchKwToCart', CONCAT(tid, '-',cartv,'-', kid));

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( cartv, kid, UID, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = cartv;

-- CALL NEWCART_TOP_NOTAILOR(uuid, tid) ;
END IF ;   


END //
DELIMITER ;

-- 
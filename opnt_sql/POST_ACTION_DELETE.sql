-- POST_ACTION_DELETE

-- TRIGGER TO REMOVE KE FROM ACTION-USER'S CART

DELIMITER $$
DROP TRIGGER IF EXISTS POST_ACTION_DELETE $$
CREATE TRIGGER POST_ACTION_DELETE 
AFTER DELETE ON OPN_USER_POST_ACTION for each row
begin

/*

	02/26/2023 AST: This trigger will remove the KW from the user's cart once the user removes
    his Post Action (L/H)
       

*/

DELETE FROM OPN_USER_CARTS WHERE OPN_USER_CARTS.USERID = OLD.ACTION_BY_USERID AND OPN_USER_CARTS.KEYID = OLD.KEYID ;

/* Raw Logging */

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
'POST ACTION DELETE TRIGGER - Cart Deleted: ACTION_BY_USERID,OLD.KEYID'
, CONCAT(OLD.ACTION_BY_USERID,'-', OLD.KEYID), NOW() ) ;

/* End of raw logging */

INSERT INTO OPN_UPA_DELETED(OLD_ROW_ID, ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM, CAUSE_POST_ID, TOPICID, ACTY_CODE, UPDATE_DTM) 
VALUES (OLD.ROW_ID, OLD.ACTION_BY_USERID, OLD.POST_BY_USERID, OLD.POST_ACTION_TYPE, OLD.POST_ACTION_DTM, OLD.CAUSE_POST_ID
, OLD.TOPICID, OLD.ACTY_CODE, NOW());

END$$

DELIMITER ; 

-- 
-- upsertCartKW

 DELIMITER //
DROP PROCEDURE IF EXISTS upsertCartKW //
CREATE PROCEDURE upsertCartKW(uuid varchar(45), tid INT, kid INT, cartv varchar(3))
thisproc:BEGIN

/*     09/08/2021 AST: Proc for adding or updating a single KW in a cart

		10/03/2021 AST: Handling the SKIP (removal) of a single KW from the cart.
*/

declare  orig_uid INT;
DECLARE SUSP VARCHAR(5) ;

SELECT  USERID, USER_SUSPEND_FLAG INTO orig_uid, SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;

IF SUSP = 'Y' THEN LEAVE thisproc ;

ELSE

CASE WHEN cartv = 'S' THEN

DELETE FROM OPN_USER_CARTS WHERE USERID = orig_uid AND KEYID = kid ;

WHEN cartv IN ('H', 'L') THEN

DELETE FROM OPN_USER_CARTS WHERE USERID = orig_uid AND KEYID = kid ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( cartv, kid, orig_uid, tid, NOW(), NOW()) ;

END CASE ;

END IF ;


END //
DELIMITER ;

-- 
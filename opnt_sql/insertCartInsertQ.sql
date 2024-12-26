-- insertCartInsertQ

 DELIMITER //
DROP PROCEDURE IF EXISTS insertCartInsertQ //
CREATE PROCEDURE insertCartInsertQ(uuid varchar(45), tid INT, kid INT, cartv varchar(3))
thisproc:BEGIN

/*      070517 AST
        ADDED LAST_UPDATE_DTM --> NOW() IN THE INSERT STMNT FOR LUDTM-BASED CLUSTERING
        08/19/2020 Kapil: Confirmed
        
        12/24/2024 AST: COnverting this proc to an UPSERT in order to obviate the insertCartDelQ
        Why ? because the insertCartDelQ is messing up the showFreshCOntent - by removing the existing
        keys from the user's cart in order to save teh SFC selections.
        This could have been handled by having a separate process for the SFC selections - but that 
        will require more dev - might as well fix the basic problem - the cart should have always been an UPSERT
        The orig insertCartInsertQ has been saved in the DOC folder just in case.
        
        TBD: Take a relook at the reflectUserInterests - i have deleted the DELETE statement there - may need to bring it back
*/

declare  orig_uid, kidtid INT;
DECLARE SUSP, orig_cart VARCHAR(5) ;

SELECT  USERID, USER_SUSPEND_FLAG INTO orig_uid, SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT TOPICID INTO kidtid FROM OPN_P_KW WHERE KEYID = kid;

IF SUSP = 'Y' THEN LEAVE thisproc ;

ELSE

SET orig_cart = (SELECT COALESCE((SELECT MAX(CART) FROM OPN_USER_CARTS WHERE USERID = orig_uid AND KEYID = kid), 'NC')) ;

CASE WHEN orig_cart = 'NC' then 

INSERT INTO OPN_USER_CARTS(TOPICID, USERID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (kidtid, orig_uid, kid, cartv, NOW(), NOW());

WHEN orig_cart <> 'NC' AND orig_cart <> cartv THEN 
UPDATE OPN_USER_CARTS SET CART = cartv where USERID = orig_uid AND KEYID = kid ;

WHEN orig_cart <> 'NC' AND orig_cart = cartv THEN 
leave thisproc ;

END CASE ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(uuid), orig_uid, uuid, NOW(), 'insertCartInsertQ', CONCAT('uid-tid-kid-cart:',orig_uid,'-',kidtid, '-', kid, '-', cartv));

/* end of user action tracking */

END IF ;


END //
DELIMITER ;

-- 
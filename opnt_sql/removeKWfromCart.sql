-- singleKWCart

DELIMITER //
DROP PROCEDURE IF EXISTS singleKWCart //
CREATE PROCEDURE `singleKWCart`(UUID varchar(45), KID INT, TID INT, CARTV VARCHAR(5))
BEGIN
/* 
	09/21/2021 AST: This proc is used for showing only one KW in the cart
    This is used when a user clicks an already selected KW (by clicking the image from top bar)
    This proc will take the keyid and the cart(L/H) that already exists for the keyid and show it.
    When the user makes any change to the KW cart, the app will call the upsertCartKW API
 */
 
declare  UID INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'singleKWCart', CONCAT(UID,'-',UNAME, '-', KID));


SELECT UID USERID, 1 TOPICID, C.CART, K1.KEYID, K1.KEYWORDS, K1.KW_IMAGE_URL, CNT.HCNT, CNT.LCNT 
FROM OPN_P_KW K1, OPN_USER_CARTS C, (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = TID GROUP BY KEYID) CNT
WHERE C.USERID = UID AND C.KEYID = KID 
AND K1.KEYID = CNT.KEYID
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID = KID ;

END //
DELIMITER ;

-- 

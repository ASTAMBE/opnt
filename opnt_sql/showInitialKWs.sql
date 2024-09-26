-- showInitialKWs

 DELIMITER //
DROP PROCEDURE IF EXISTS showInitialKWs //
CREATE PROCEDURE showInitialKWs(uuid varchar(45), tid INT, fromIndex INT, toIndex INT)
BEGIN

/*
	12/18/2022 AST: Building this proc to show the most active KWs to the new user - only when he creates a new login.-
    It is expected that the user will select at least one of the KWs for L/H. If he doesn't select at least one, we 
    flash a message that he may not get much content and urge him to select at least one.
    
    09/30/2023 AST: Added (unix_timestamp(NOW()) - unix_timestamp(CREATION_DTM)) to bring the latest KWs that 
    have been formed from the scrapes.
    
    10/09/2023 AST: Added the user tracking 
    Also added the filter to exclude the KWs that may be already in the cart
*/

declare  uid INT ;
DECLARE ccode VARCHAR(5) ;
DECLARE UNAME VARCHAR(50) ;

SELECT USERID, COUNTRY_CODE, USERNAME INTO uid, ccode, UNAME FROM OPN_USERLIST WHERE USER_UUID = uuid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, uid, uuid, NOW(), 'showInitialKWs', CONCAT(tid,'-',ccode));

/* end of use action tracking */

SELECT ROW_ID, KEYID, KEYWORDS FROM (
SELECT 'SRC A' SRC, (unix_timestamp(NOW()) - unix_timestamp(CREATION_DTM)) ROW_ID, KEYID, KEYWORDS FROM OPN_P_KW WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE = ccode
AND KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)
UNION ALL
SELECT 'SRC B' SRC, (unix_timestamp(NOW()) - unix_timestamp(CREATION_DTM)) ROW_ID, KEYID, KEYWORDS FROM OPN_P_KW WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE <> ccode
AND KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid)
ORDER BY 1, 2, 3
)Q
LIMIT fromIndex, toIndex
;


END //
DELIMITER ;

-- 

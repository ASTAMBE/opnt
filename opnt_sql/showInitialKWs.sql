-- showInitialKWs

 DELIMITER //
DROP PROCEDURE IF EXISTS showInitialKWs //
CREATE PROCEDURE showInitialKWs(uuid varchar(45), tid INT, fromIndex INT, toIndex INT)
BEGIN

/*
	12/18/2022 AST: Building this proc to show the most active KWs to the new user - only when he creates a new login.
    It is expected that the user will select at least one of the KWs for L/H. If he doesn't select at least one, we 
    flash a message that he may not get much content and urge him to select at least one.
*/

declare  uid INT ;
DECLARE ccode VARCHAR(5) ;

SELECT USERID, COUNTRY_CODE INTO uid, ccode FROM OPN_USERLIST WHERE USER_UUID = uuid ;

SELECT ROW_ID, KEYID, KEYWORDS FROM (
SELECT 'SRC A' SRC, ROW_ID, KEYID, KEYWORDS FROM OPN_INITIAL_KWS_SHOWN WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE = ccode
UNION ALL
SELECT 'SRC B' SRC, ROW_ID, KEYID, KEYWORDS FROM OPN_INITIAL_KWS_SHOWN WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE <> ccode
ORDER BY 1, 3 
)Q
LIMIT fromIndex, toIndex
;


END //
DELIMITER ;

-- 

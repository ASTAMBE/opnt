-- showInitialDiscussions

 DELIMITER //
DROP PROCEDURE IF EXISTS showInitialDiscussions //
CREATE PROCEDURE showInitialDiscussions(uuid varchar(45), tid INT, fromIndex INT, toIndex INT)
BEGIN

/*
	10/12/2023 AST: Initial Creation: To bring the latest discussions to be shown to the user 
    whenever he has an empty cart.
    
    
    We need to show these every time he clicks instream or discussions or even the cart screen. 
*/

declare  uid INT ;
DECLARE ccode VARCHAR(5) ;
DECLARE UNAME VARCHAR(50) ;

SELECT USERID, COUNTRY_CODE, USERNAME INTO uid, ccode, UNAME FROM OPN_USERLIST WHERE USER_UUID = uuid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, uid, uuid, NOW(), 'showInitialDiscussions', CONCAT(tid,'-',ccode));

/* end of use action tracking */

SELECT ROW_ID, KEYID, KEYWORDS, POSTID FROM (
SELECT 'SRC A' SRC, (unix_timestamp(NOW()) - unix_timestamp(CREATION_DTM)) ROW_ID, KEYID, KEYWORDS, ALT_KEYID POSTID FROM OPN_P_KW WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE = ccode
AND KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid) AND ALT_KEYID IS NOT NULL
UNION ALL
SELECT 'SRC B' SRC, (unix_timestamp(NOW()) - unix_timestamp(CREATION_DTM)) ROW_ID, KEYID, KEYWORDS, ALT_KEYID POSTID FROM OPN_P_KW WHERE TOPICID = tid AND ORIGIN_COUNTRY_CODE <> ccode
AND KEYID NOT IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = uid) AND ALT_KEYID IS NOT NULL
ORDER BY 1, 2, 3
)Q
LIMIT fromIndex, toIndex
;


END //
DELIMITER ;

-- 

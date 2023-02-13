-- openKeywords

DELIMITER //
DROP PROCEDURE IF EXISTS openKeywords //
CREATE PROCEDURE `openKeywords`(TID INT, UUID varchar(45))
BEGIN
/* 
	08/26/2021 AST: This proc is used for bringing only the KWs that are not in a user's cart
 */
 
declare  UID INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'openKeywords', CONCAT(UID,'-',UNAME));


/* end of use action tracking */


/* 05/19/2020 AST: Building the new proc to include the sortOrder
    05/26/2020 AST: Added LIMIT fromIndex , toIndex for limiting the list
    
    06/18/2020 AST: Adding HCNT, LCNT
    05/20/2021 AST: Adding the FILTER of CLEAN_KW_FLAG = 'Y'. This is for ensuring that 
    the wrongly added words (such as 'Indian', 'bollywood' etc. are not shown for selection
    Will add 'J' for Junk as the CLEAN_WORD_FLAG code
    
    09/29/2021 AST: ADDED AND IFNULL(K1.NEWS_ONLY_FLAG,'N') <> 'Y'
    
        10/03/2021 AST: Adding IFNULL to the SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID
    This is because in case of an empty cart - the NULL messes up the exclusion.
    Also adding AND K1.STATE_CODE IS NOT NULL to filter out stateless KWs
*/

SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, K1.KW_IMAGE_URL, CNT.HCNT, CNT.LCNT 
FROM OPN_P_KW K1, (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = TID GROUP BY KEYID) CNT
WHERE K1.KEYID = CNT.KEYID AND K1.STATE_CODE IS NOT NULL
AND K1.PRIVATE_KW_FLAG = 'N' AND K1.CLEAN_KW_FLAG = 'Y' AND IFNULL(K1.NEWS_ONLY_FLAG,'N') <> 'Y'
AND K1.KEYID NOT IN 
(SELECT IFNULL(KEYID,101) FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID) 
ORDER BY K1.KEYID  ;

END //
DELIMITER ;

-- 

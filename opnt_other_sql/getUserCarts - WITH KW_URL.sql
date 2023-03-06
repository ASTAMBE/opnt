-- getUserCarts - WITH KW_URL

DELIMITER //
DROP PROCEDURE IF EXISTS getUserCarts //
CREATE DEFINER=`root`@`%` PROCEDURE `getUserCarts`(TID INT, UUID varchar(45), sortOrder VARCHAR(10), fromIndex INT, toIndex INT)
BEGIN
/* 
08/11/2020 Kapil: Confirmed

	03/04/2023 AST: Changed the join with CNT to LEFT OUTER - this is because with the new POST TO KW process
    the KWs do not have pre-allocated bot users. Hence the join had to be converted to outer.

 */
declare  UID INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'getUserCarts', CONCAT(TID,'-',CCODE));


/* end of use action tracking */


/* 05/19/2020 AST: Building the new proc to include the sortOrder
    05/26/2020 AST: Added LIMIT fromIndex , toIndex for limiting the list
    
    06/18/2020 AST: Adding HCNT, LCNT
    05/20/2021 AST: Adding the FILTER of CLEAN_KW_FLAG = 'Y'. This is for ensuring that 
    the wrongly added words (such as 'Indian', 'bollywood' etc. are not shown for selection
    Will add 'J' for Junk as the CLEAN_WORD_FLAG code
*/

CASE WHEN sortOrder = ('POPULAR') THEN 

SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT 
, KK.KW_URL2
FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
AND UC1.KEYID = S1.KEYID
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE K1.KEYID = S1.KEYID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE K1.KEYID = S1.KEYID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1 LEFT OUTER JOIN (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = 1 GROUP BY KEYID) CNT
ON Q1.KEYID = CNT.KEYID
LEFT OUTER JOIN (SELECT KEYID, ALT_KEYID, CASE WHEN KW_EXT LIKE '%http%' THEN KW_URL ELSE KW_EXT END KW_EXT2
, CASE WHEN KW_URL NOT LIKE '%http%' THEN KW_EXT ELSE KW_URL END KW_URL2 FROM OPN_P_KW WHERE KW_EXT IS NOT NULL) KK
ON Q1.KEYID = KK.KEYID
ORDER BY SRC, CART, SORTER DESC LIMIT fromIndex , toIndex ;
                
WHEN  sortOrder = ('ALPHA') THEN       


SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1 
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1 LEFT OUTER JOIN (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = 1 GROUP BY KEYID) CNT
ON Q1.KEYID = CNT.KEYID
LEFT OUTER JOIN (SELECT KEYID, ALT_KEYID, CASE WHEN KW_EXT LIKE '%http%' THEN KW_URL ELSE KW_EXT END KW_EXT2
, CASE WHEN KW_URL NOT LIKE '%http%' THEN KW_EXT ELSE KW_URL END KW_URL2 FROM OPN_P_KW WHERE KW_EXT IS NOT NULL) KK
ON Q1.KEYID = KK.KEYID
ORDER BY SRC, CART, SORTER LIMIT fromIndex , toIndex ;

WHEN  sortOrder = ('LATEST') THEN  

SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1 
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.CLEAN_KW_FLAG = 'Y'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1 LEFT OUTER JOIN (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = 1 GROUP BY KEYID) CNT
ON Q1.KEYID = CNT.KEYID
LEFT OUTER JOIN (SELECT KEYID, ALT_KEYID, CASE WHEN KW_EXT LIKE '%http%' THEN KW_URL ELSE KW_EXT END KW_EXT2
, CASE WHEN KW_URL NOT LIKE '%http%' THEN KW_EXT ELSE KW_URL END KW_URL2 FROM OPN_P_KW WHERE KW_EXT IS NOT NULL) KK
ON Q1.KEYID = KK.KEYID
ORDER BY SRC, CART, SORTER DESC LIMIT fromIndex , toIndex ;


END CASE ;

END //
DELIMITER ;

-- 
-- searchkeyword

DELIMITER //
DROP PROCEDURE IF EXISTS searchkeyword //

CREATE DEFINER=`root`@`%` PROCEDURE `searchkeyword`(tid INT, uuid varchar(45), country_code VARCHAR(5), searchterm varchar(60))
BEGIN
/*26-03-2020 Rohit:- 
Remove the substring search. Search as a entire string at once

06/17/2018 AST: Initial Proc creation for Search
11/02/2018 AST: changed the joins to OPUC as outer joins

call searchkeyword(8, bringUUID(1017005), 'IND', 'GOOGLE') ;

MAY-10-2020 AST: Removing @ from the @orig_uid and @UNAME

MAY-10-2020 AST: Including a filter where private KWs will not be displayed in the list of search results

06/02/2020 AST: Rebuilding with removal of @  

08/11/2020 Kapil: Confirmed
 */

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE STERM VARCHAR(70) ;

SET orig_uid := (SELECT  bringUserid(uuid));
SET UNAME := (SELECT USERNAME FROM OPN_USERLIST WHERE USER_UUID = uuid) ;


SET STERM := CONCAT('%', searchterm , '%');

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'searchKW', concat(tid,'-',searchterm));

/* end of use action tracking */

CASE WHEN country_code = 'GGG' THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
     /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('USA')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  NOT IN ('USA', 'GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
WHEN country_code = 'USA' THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('USA')
    AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
         /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  NOT IN ('USA', 'GGG')
          AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
               /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
WHEN country_code NOT IN ('USA' , 'GGG') THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN (country_code)
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE IN ('USA')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE NOT IN ('USA', 'GGG', country_code)
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
        END CASE ;




END//
DELIMITER ;

-- 
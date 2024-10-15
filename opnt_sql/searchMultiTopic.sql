-- searchMultiTopic

DELIMITER //
DROP PROCEDURE IF EXISTS searchMultiTopic //
CREATE PROCEDURE searchMultiTopic(topicid INT, userid varchar(45),  searchTerm varchar(60))
thisproc: BEGIN

/*

	01/07/2021 AST: Initial Creation : To return multi-topic search results for KWs
	02/16/2021 AST: Adding tid to output and removing country_code
    02/23/2021 AST: Removing the AND OUC.TOPICID = topicid from the portion that checks for
    already existing keyids in the cart - this condition was redundent earlier (in single search)
    Now it is actually causing dupes. so removing it in all segments of the code
    10/14/2024 AST: Going back to topic-specific search results - by adding  AND K.TOPICID = topicid
 */

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE STERM VARCHAR(70) ;
DECLARE country_code VARCHAR(5) ;

SELECT J.USERNAME, J.USERID, J.COUNTRY_CODE INTO UNAME, orig_uid, country_code 
FROM OPN_USERLIST J WHERE J.USER_UUID = userid ;


SET STERM := CONCAT('%', searchTerm , '%');

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'searchMultiTopic', concat(topicid,'-',searchTerm));

/* end of use action tracking */

CASE WHEN country_code = 'GGG' THEN

SELECT TNAME, QQ.TOPICID, KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE  IN ('GGG') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid )
     /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.COUNTRY_CODE  IN ('USA') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.COUNTRY_CODE  NOT IN ('USA', 'GGG') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY TNAME, TCOUNT DESC;
        
WHEN country_code = 'USA' THEN

SELECT TNAME, QQ.TOPICID, KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.COUNTRY_CODE  IN ('USA') AND K.TOPICID = topicid
    AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid   )
         /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE  IN ('GGG') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE  NOT IN ('USA', 'GGG') AND K.TOPICID = topicid
          AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
               /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY TNAME, TCOUNT DESC;
        
WHEN country_code NOT IN ('USA' , 'GGG') THEN

SELECT TNAME, QQ.TOPICID, KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE  IN (country_code) AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE  IN ('GGG') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE IN ('USA') AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT bringTopicfromTID(K.TOPICID) TNAME, K.TOPICID, K.KEYID, K.KEYWORDS, 'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE  K.COUNTRY_CODE NOT IN ('USA', 'GGG', country_code)  AND K.TOPICID = topicid
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid  )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY TNAME, TCOUNT DESC;
        
        END CASE ;




END//
DELIMITER ;

-- 
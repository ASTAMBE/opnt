-- getAllTopicsCartsByUserByCountry

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getAllTopicsCartsByUserByCountry //
CREATE DEFINER=`root`@`%` PROCEDURE `getAllTopicsCartsByUserByCountry`(topicid INT, userid varchar(45), country_code VARCHAR(5))
BEGIN

/*  
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;

SET orig_uid := (SELECT  bringUserid(userid));
SET UNAME := (SELECT U5.USERNAME FROM OPN_USERLIST U5 WHERE U5.USER_UUID = userid) ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'getAllTopicsCartsByUserByCountry', CONCAT(topicid,'-',country_code));


/* end of use action tracking */


/* 04/05/2019 AST: Changed the ordering of the KW display depending on the TID 
    04/11/2019 AST: Changed the ordering on the first case (topicid in 5,9,10) to have IRANK numbers 4 for the cart and all others 5.
    This is done so that the ranking by KEYID DESC can take effect.
    The ordering is NOT changed on the rest of the topics because still considering the ranking first ordered by the global vs local etc.
    
    Also under consideration: remove the dichotomy of ORIGIN_COUNTRY_CODE VS COUNTRY_CODE.
    This is because the concept was introduced due to the lack of the Search and Create KW Feature. 
    
    Now with both the capabilities in place, no user can create a GGG KW while being a USA or IND user.
    
    We should consider updating all KW's with their country_code = Origin_country_code.
    
    That way, no USA user would be seeing the IND keywords at the top.
    
     12/17/2019 AST: Removed @ from code
     
     05/10/2020 AST: Including a filter where Private KWs will not be displayed in the list of non-selected KWs
    
*/

CASE WHEN topicid IN (5,9,10) THEN 

SELECT QQQ.USERID, QQQ.TOPICID, QQQ.CART, QQQ.KEYID, QQQ.KEYWORDS, QQQ.IRANK FROM (
SELECT UC2.USERID, UC2.TOPICID, UC2.CART, D.KEYID, D.KEYWORDS, 4 IRANK,  TCOUNT FROM        
(SELECT K.KEYID, K.KEYWORDS,'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K, OPN_USER_CARTS UC
        WHERE K.TOPICID = topicid -- AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN ('IND')
        AND K.KEYID = UC.KEYID
     AND K.KEYID  IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
        GROUP BY K.KEYID, K.KEYWORDS) D, OPN_USER_CARTS UC2 
        WHERE D.KEYID = UC2.KEYID AND UC2.USERID = orig_uid
        UNION ALL 
        SELECT orig_uid USERID, topicid TOPICID, ' ' CART, KEYID, KEYWORDS, IRANK, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
     /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */     
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN (country_code) AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
         AND K.ORIGIN_COUNTRY_CODE NOT IN ('GGG')
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE IN ('GGG')  AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE NOT IN ('GGG', country_code) AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY IRANK, CART, KEYID DESC 
                )QQQ;
                
WHEN  topicid NOT IN (5,9,10) THEN       

SELECT QQQ.USERID, QQQ.TOPICID, QQQ.CART, QQQ.KEYID, QQQ.KEYWORDS, QQQ.IRANK FROM (
SELECT UC2.USERID, UC2.TOPICID, UC2.CART, D.KEYID, D.KEYWORDS, 4 IRANK,  TCOUNT FROM        
(SELECT K.KEYID, K.KEYWORDS,'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K, OPN_USER_CARTS UC
        WHERE K.TOPICID = topicid -- AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN ('IND')
        AND K.KEYID = UC.KEYID
     AND K.KEYID  IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
        GROUP BY K.KEYID, K.KEYWORDS) D, OPN_USER_CARTS UC2 
        WHERE D.KEYID = UC2.KEYID AND UC2.USERID = orig_uid
        UNION ALL 
        SELECT orig_uid USERID, topicid TOPICID, ' ' CART, KEYID, KEYWORDS, IRANK, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 6 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN (country_code) AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
         AND K.ORIGIN_COUNTRY_CODE NOT IN ('GGG')
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 7 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE IN ('GGG')  AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 8 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE NOT IN ('GGG', country_code) AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY IRANK, CART, TCOUNT DESC 
                )QQQ;
END CASE ;

END //
DELIMITER ;

-- 
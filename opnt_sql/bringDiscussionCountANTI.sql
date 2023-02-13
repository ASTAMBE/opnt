
-- bringDiscussionCountANTI

DELIMITER //
DROP FUNCTION IF EXISTS bringDiscussionCountANTI //
CREATE FUNCTION bringDiscussionCountANTI(UUID VARCHAR(45),  TID INT) RETURNS INT
BEGIN

/* 10/04/2021 AST: Initial Creation for Discussion Counts - only for non-bot posts */

  DECLARE PostCOUNT, UID INT ;
  DECLARE CCODE VARCHAR(5) ;
  
  SELECT USERID, COUNTRY_CODE INTO UID, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

SET PostCOUNT = (SELECT COUNT(1)
FROM OPN_POSTS P
, (SELECT DISTINCT B.USERID, B.BOT_FLAG, A.TOPICID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = UID) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID 
AND IFNULL(CU.BOT_FLAG, 'N') <> 'Y'
AND C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = UID 
AND OUUA.TOPICID = TID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART <> B.CART 
AND B.USERID NOT IN 
(SELECT DISTINCT D.USERID FROM 
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = UID AND C1.TOPICID = TID) C ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID FROM OPN_USER_CARTS C2 ) D
WHERE C.KEYID = D.KEYID AND C.CART = D.CART )
AND A.KEYID = B.KEYID AND A.TOPICID = TID ) UN
WHERE UN.USERID = P.POST_BY_USERID
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 30 DAY
AND UN.TOPICID = P.TOPICID
AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN 
(SELECT KK.KEYID FROM OPN_USER_CARTS KK WHERE KK.USERID = UID))

);

  RETURN PostCOUNT;
  
END;//

-- 
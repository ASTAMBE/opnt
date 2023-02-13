
-- getALLPCount

DELIMITER //
DROP FUNCTION IF EXISTS getALLPCount //
CREATE FUNCTION getALLPCount(UID INT, TID INT) RETURNS INT
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
this proc was still using the old network algo - changed it to the new
 SELECT getALLPCount(UID INT, TID INT) 
 This function is being created to support the new definition of the network
 now, ALL indicates all the users who have the same keyword/s but may or may not
 match the love/hate (in fact the ALL includes those that are exactly opposite
 
 */

  DECLARE ALLPCOUNT INT ;

  SET ALLPCOUNT = (SELECT COUNT(1) FROM OPN_POSTS P 
  WHERE  P.CLEAN_POST_FLAG = 'Y' AND P.TOPICID = TID
 AND P.POST_BY_USERID IN(
SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID -- AND USERID <> UID 
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID
) 

);

  RETURN ALLPCOUNT;
END;//

-- 
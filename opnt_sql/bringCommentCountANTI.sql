-- bringCommentCountANTI

DELIMITER //
DROP FUNCTION IF EXISTS bringCommentCountANTI //
CREATE FUNCTION bringCommentCountANTI(UUID VARCHAR(45),  postID INT) RETURNS INT
BEGIN

/* 05/03/2020 AST: Post COunt after rebuild of getPostsByUserNameALL 
	05/30/2020 AST: Removing deleted comments 
        	05/30/2020 AST: Removing parent comments that are outside the network
            06/18/2020 AST: Added AND A.CART <> B.CART for the ANTI

*/

  DECLARE CommentCOUNT, UID, TID INT ;
  
  SET UID = (SELECT USERID FROM OPN_USERLIST WHERE USER_UUID = UUID) ;
  SET TID = (SELECT MAX(TOPICID) FROM OPN_POST_COMMENTS WHERE CAUSE_POST_ID = postID) ;

SET CommentCOUNT = (SELECT COUNT(1) FROM 
OPN_POST_COMMENTS P, (
SELECT DISTINCT B.TOPICID, B.USERID IN_NW_UID  FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1
WHERE C1.TOPICID = TID AND C1.USERID = UID) A ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID FROM OPN_USER_CARTS C2
WHERE C2.TOPICID = TID  
AND C2.USERID NOT IN (SELECT OUA.ON_USERID FROM OPN_USER_USER_ACTION OUA
WHERE OUA.TOPICID = TID AND OUA.BY_USERID = UID AND OUA.ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART <> B.CART ) NW1
WHERE P.COMMENT_BY_USERID = NW1.IN_NW_UID AND P.TOPICID = NW1.TOPICID
AND P.CAUSE_POST_ID = postID AND P.COMMENT_DELETE_FLAG <> 'Y' );

  RETURN CommentCOUNT;
  
END;//

-- 
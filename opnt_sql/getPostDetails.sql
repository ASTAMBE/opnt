
-- getPostDetails

DELIMITER //
DROP PROCEDURE IF EXISTS getPostDetails //
CREATE PROCEDURE getPostDetails(userid varchar(45), postid INT)
BEGIN

/*

07/17/2020 AST: This proc is being rebuilt for the new UI. It will provide the 
		necessary details of the post and also ensure that the post is legit as per
        the user id.
08/11/2020 Kapil: Confirmed

04/25/2021 AST: Adding BOOKMARK_FLAG 

*/

declare  UID, TID INT;
DECLARE userDP VARCHAR(300) ;

SELECT U1.USERID, U1.DP_URL INTO UID, userDP FROM OPN_USERLIST U1 WHERE U1.USER_UUID = userid ;
SELECT TOPICID INTO TID FROM OPN_POSTS WHERE POST_ID = postid ;

SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_BY_USERID, OU.USERNAME, OU.DP_URL
, P.POST_CONTENT,P.MEDIA_CONTENT,P.MEDIA_FLAG,
1 TOTAL_NS, bringPostLCount(postid) LCOUNT, bringPostHCount(postid) HCOUNT
, bringUserPostAction(UID, postid) POST_ACTION_TYPE
, '' UU_ACTION, bringPostCCount(postid) POST_COMMENT_COUNT
, CASE WHEN BK.POST_ID = postid THEN 'Y' ELSE 'N' END BKMK_FLAG
FROM OPN_POSTS P
LEFT OUTER JOIN OPN_POST_BOOKMARKS BK ON P.POST_ID = BK.POST_ID AND BK.USERID = UID
INNER JOIN OPN_USERLIST OU ON P.POST_BY_USERID = OU.USERID
WHERE P.POST_BY_USERID = OU.USERID
AND P.POST_ID = postid
AND P.CLEAN_POST_FLAG = 'Y'
AND P.POST_BY_USERID IN 
(SELECT B.USERID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = UID) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = UID 
AND OUUA.TOPICID = TID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.TOPICID = TID)
-- AND P.POST_BY_USERID = orig_uid
;

END //
DELIMITER ;

-- 
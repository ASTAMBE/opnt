-- myCommentPosts

DELIMITER //
DROP PROCEDURE IF EXISTS myCommentPosts //
CREATE PROCEDURE myCommentPosts(userid varchar(45), topicid INT, fromindex INT, toindex INT)
BEGIN

/* 	07/07/2020 AST: Initial Creation - Proc for finding all the posts where I have commented as a user. When user clicks the Comment Counts in the Activity screen
                    
07/09/2020 AST: Added filter for removing the users who have been kicked out by this user
08/11/2020 Kapil: Confirmed

*/

declare  orig_uid INT;

SET orig_uid = (SELECT  bringUserid(userid));

SELECT P.POST_ID, OU.USERNAME POST_BY_USERNAME, OU.DP_URL, P.TOPICID, P.POST_DATETIME, P.POST_CONTENT
, P.MEDIA_CONTENT, P.MEDIA_FLAG, IFNULL(POST_LHC.LCOUNT,0) LCOUNT
, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, IFNULL(OPC.POST_COMMENT_COUNT, 0) POST_COMMENT_COUNT
FROM OPN_POSTS P
INNER JOIN (SELECT DISTINCT CC.CAUSE_POST_ID FROM OPN_POST_COMMENTS CC WHERE CC.COMMENT_BY_USERID = orig_uid 
AND CC.TOPICID = topicid) PC
ON P.POST_ID = PC.CAUSE_POST_ID
INNER JOIN OPN_USERLIST OU ON P.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON P.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' GROUP BY CAUSE_POST_ID) OPC 
ON P.POST_ID = OPC.CAUSE_POST_ID
WHERE P.POST_BY_USERID NOT IN (SELECT UA.ON_USERID FROM OPN_USER_USER_ACTION UA
WHERE UA.BY_USERID = orig_uid AND UA.TOPICID = topicid AND UA.ACTION_TYPE = 'KO' )
ORDER BY P.POST_DATETIME DESC LIMIT fromindex, toindex;

END //
DELIMITER ;

-- 
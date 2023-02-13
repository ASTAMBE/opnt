-- blockedPostList

DELIMITER //
DROP PROCEDURE IF EXISTS blockedPostList //
CREATE PROCEDURE blockedPostList(tid INT, fromindex INT, toindex INT)
BEGIN

/*

01/06/2022 : Initial Creation AST: 

This script is created in order to bring all the posts that have been tagged as CLEAN_POST_FLAG = 'N'
This is due to the post having a non-whitelisted domain. The posts are brought with POST_DATETIME DESC 

*/

DECLARE POSTCONTENT, EMBCONTENT VARCHAR(2000) ;
DECLARE postid INT ;

SELECT P.POST_ID, R.POST_DATETIME, U.USERNAME, R.POST_CONTENT, R.EMBEDDED_CONTENT
FROM OPN_POSTS_RAW R, OPN_POSTS P, OPN_USERLIST U
WHERE R.POST_ID = P.POST_ID AND R.POST_BY_USERID = U.USERID AND P.CLEAN_POST_FLAG = 'N'
AND R.TOPICID = tid ORDER BY R.POST_DATETIME LIMIT fromindex, toindex ;


  
  
END; //
 DELIMITER ;
 
 -- 
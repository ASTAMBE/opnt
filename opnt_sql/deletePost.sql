-- deletePost

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS deletePost //
CREATE PROCEDURE deletePost(userid varchar(45), postid INT)
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 CALL deletePost(userid varchar(45), postid INT) 
 08/11/2020 Kapil: Confirmed
 
 01/28/2021 AST: This is being changed from hard delete to soft delete. Now we will update the DELETED_FLAG
 and the POST_CONTENT
 03/15/2021 AST: Adding the removal of media content to the deleted post
 
 */

declare  orig_uid INT;

SET orig_uid := (SELECT  bringUserid(userid));

-- DELETE FROM OPN_POSTS  WHERE OPN_POSTS.POST_ID = postid AND OPN_POSTS.POST_BY_USERID = orig_uid ;
UPDATE OPN_POSTS SET POST_CONTENT = 'This post has been deleted', EMBEDDED_CONTENT = ''
, EMBEDDED_FLAG = 'N' , DELETED_FLAG = 'Y', MEDIA_CONTENT = '', MEDIA_FLAG = 'N' 
WHERE POST_ID = postid AND POST_BY_USERID = orig_uid ;

UPDATE OPN_POST_SEARCH_T SET POST_CONTENT = 'This post has been deleted', URL_TITLE = '', URL_EXCERPT = ''
, SEARCH_STRING = 'This post has been deleted' WHERE POST_ID = postid AND POST_BY_USERID = orig_uid ;


END //
DELIMITER ;

-- 
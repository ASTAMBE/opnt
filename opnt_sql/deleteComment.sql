-- deleteComment

 DELIMITER //
DROP PROCEDURE IF EXISTS deleteComment //
CREATE PROCEDURE deleteComment(userid varchar(45), commentID INT)
THISPROC: BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 CALL deleteComment(userid varchar(45), comment_id INT) 
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid, cbyuid INT;
DECLARE UNAME VARCHAR(40) ;
SET SQL_SAFE_UPDATES = 0;

SELECT U.USERID, U.USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST U WHERE U.USER_UUID = userid ;
SELECT COMMENT_BY_USERID INTO cbyuid FROM OPN_POST_COMMENTS WHERE COMMENT_ID = commentID ;

/* User Behavior Log Section */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'deleteComment', concat('COMMENT_ID',' = ',commentID));

/* End of User Behavior Log Section */

CASE WHEN orig_uid <> cbyuid THEN LEAVE THISPROC;

WHEN orig_uid = cbyuid THEN

UPDATE OPN_POST_COMMENTS SET COMMENT_DELETE_FLAG = 'Y', COMMENT_DELETE_DTM = NOW() 
, COMMENT_CONTENT = '-- Comment Deleted by User -- ', EMBEDDED_CONTENT = '', EMBEDDED_FLAG = 'N'
, MEDIA_CONTENT = '', MEDIA_FLAG = 'N'
WHERE OPN_POST_COMMENTS.COMMENT_ID = commentID ;

UPDATE OPN_POST_COMMENTS SET PARENT_COMMENT_CONTENT = '-- Comment Deleted by User -- '
, PARENT_MEDIA_CONTENT = '', PARENT_MEDIA_FLAG = 'N' 
WHERE OPN_POST_COMMENTS.PARENT_COMMENT_ID = commentID ;

END CASE ;

END  //
DELIMITER ;

-- 
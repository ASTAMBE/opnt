-- postBookmark

DELIMITER //
DROP PROCEDURE IF EXISTS removeBookmark //
CREATE PROCEDURE removeBookmark(uuid varchar(45), postid INT )
thisProc: BEGIN

/*   

04/18/2021 AST : Initial Creation - to make bookmarks for posts
 
*/

declare  orig_uid, tid, PBUID INT;
DECLARE UNAME VARCHAR(30) ;
declare SUSPUSER varchar(3) ;

SELECT OU.USERID, OU.USERNAME, OU.USER_SUSPEND_FLAG INTO orig_uid, UNAME, SUSPUSER
FROM OPN_USERLIST OU WHERE OU.USER_UUID = uuid ;

SELECT TOPICID, POST_BY_USERID INTO tid, PBUID FROM OPN_POSTS WHERE POST_ID = postid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'removeBookmark', postid);


/* end of use action tracking */

CASE WHEN SUSPUSER = 'Y' THEN LEAVE thisProc ;

WHEN SUSPUSER = 'N' THEN

DELETE FROM OPN_POST_BOOKMARKS WHERE OPN_POST_BOOKMARKS.USERID = orig_uid AND OPN_POST_BOOKMARKS.POST_ID = postid ;

SELECT 'SUCCESS' STATUS ;

END CASE ;

END; //
 DELIMITER ;
 
 -- 
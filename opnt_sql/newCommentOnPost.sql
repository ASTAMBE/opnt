-- newCommentOnPost 

 DELIMITER //
DROP PROCEDURE IF EXISTS newCommentOnPost //
CREATE PROCEDURE newCommentOnPost(commentUUID varchar(45),  causePostID INT
, commentContent varchar(2000), embedded_content varchar(1000), embedded_flag varchar(3)
, media_content varchar (500), media_flag varchar(3))
BEGIN

/* 04/22/2020 AST:  Rebuilding as a full comment on post with media attachments
 04/28/2020 AST: User BHV Log to be done
 04/30/2020 AST: Added COMMENT_BY_UNAME
 06/04/2020 AST: Added identifiers for all the tables in the proc below
 
 08/09/2020 AST: Confirmed  
 08/14/2020 Kapil: Confirmed  
 */

declare  orig_uid, pbuid, tid INT;
declare COMMENT_TYPE varchar(10) ;
DECLARE UNAME VARCHAR(40) ;

SELECT OU.USERID, OU.USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST OU WHERE OU.USER_UUID = commentUUID ;

SELECT OP.TOPICID, OP.POST_BY_USERID INTO tid, pbuid FROM OPN_POSTS OP
where OP.POST_ID = causePostID ;

/* USER BH LOG */

 INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
 VALUES(UNAME, orig_uid, commentUUID, NOW(), 'newCommentOnPost', concat('UID-causePostID', '-', orig_uid, '-', causePostID) );
 
 /* END USER BH LOG */


INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(causePostID, pbuid, tid, 1, commentContent, orig_uid, UNAME
, commentContent, orig_uid, UNAME, media_content
, media_flag, NOW()
, now(), embedded_content, embedded_flag, 'CONP', media_content, media_flag);


END //
DELIMITER ;

-- 
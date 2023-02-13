-- newCommentOnComment 

 DELIMITER //
DROP PROCEDURE IF EXISTS newCommentOnComment //
CREATE PROCEDURE newCommentOnComment(concUUID varchar(45),  parentCommentID INT
, concContent varchar(2000), embedded_content varchar(1000), embedded_flag varchar(3)
, media_content varchar (500), media_flag varchar(3))
BEGIN

/* 04/22/2020 AST:  Rebuilding as a full comment on Comment with media attachments
 04/28/2020 AST: User BHV Log to be done
 06/04/2020 AST: Added OPC identifier for the SELECT and the OPN_POST_COMMENTS table
 
 08/09/2020 AST: Confirmed  
 08/14/2020 Kapil: Confirmed  */

declare  orig_uid, causepostbyuid, parentcmntbyuid, tid, causePostID INT;
declare parentCommentMediaFlag  varchar(3) ;
DECLARE UNAME, parentCommentByUname VARCHAR(40) ;
DECLARE parentCommentContent varchar(2000) ;
declare parentCommentMediaContent varchar(500) ;
declare parentCommentDTM DATETIME ;

SELECT USERID, USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST WHERE USER_UUID = concUUID ;

SELECT OPC.CAUSE_POST_ID, OPC.POST_BY_USERID, OPC.TOPICID, OPC.COMMENT_CONTENT, OPC.COMMENT_BY_USERID, OPC.COMMENT_BY_UNAME
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG, OPC.COMMENT_DTM
INTO causePostID, causepostbyuid, tid, parentCommentContent, parentcmntbyuid, parentCommentByUname
, parentCommentMediaContent, parentCommentMediaFlag, parentCommentDTM
FROM OPN_POST_COMMENTS OPC where OPC.COMMENT_ID = parentCommentID  ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_ID
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_BYUID
, PARENT_COMMENT_UNAME
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG
, PARENT_COMMENT_DTM
, COMMENT_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, COMMENT_TYPE
, MEDIA_CONTENT
, MEDIA_FLAG) 
VALUES
(causePostID
, causepostbyuid
, tid
, 1
, concContent
, orig_uid
, UNAME
, parentCommentID
, parentCommentContent
, parentcmntbyuid
, parentCommentByUname
, parentCommentMediaContent
, parentCommentMediaFlag
, parentCommentDTM
, now()
, embedded_content
, embedded_flag
, 'CONC'
, media_content
, media_flag);


END //
DELIMITER ;

-- 
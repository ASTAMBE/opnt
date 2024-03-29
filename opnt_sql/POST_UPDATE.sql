-- POST_UPDATE

-- TRIGGER TO UPDATE POSTS ON OPN_POSTS_RAW

/* 04/09/2020 AST: Added MEDIA_CONTENT = NEW.MEDIA_CONTENT
, MEDIA_FLAG = NEW.MEDIA_FLAG to handle the new media fields 

05/15/2021 AST: Adding TAG1_KEYID and STP_PROC_NAME to UPDATE. This is for the retagPost proc

08/09/2021 AST: Added TOPICID to UPDATE list

*/

DELIMITER $$
DROP TRIGGER IF EXISTS POST_UPDATE $$
CREATE TRIGGER POST_UPDATE 
AFTER UPDATE ON OPN_POSTS_RAW for each row
begin

IF NEW.EMBEDDED_FLAG = 'N' THEN

UPDATE OPN_POSTS SET POST_CONTENT = NEW.POST_CONTENT, MEDIA_CONTENT = NEW.MEDIA_CONTENT
, MEDIA_FLAG = NEW.MEDIA_FLAG
, EMBEDDED_CONTENT = NULL
, EMBEDDED_FLAG = 'N', CLEAN_POST_FLAG = 'Y'
, POST_UPDATE_DTM = NOW(), POST_PROCESSED_FLAG = 'Y'
, TAG1_KEYID = NEW.TAG1_KEYID, STP_PROC_NAME = NEW.STP_PROC_NAME
, TOPICID = NEW.TOPICID
, POST_PROCESSED_DTM = NOW() WHERE POST_ID = OLD.POST_ID; 

ELSE

UPDATE OPN_POSTS SET POST_CONTENT = NEW.POST_CONTENT, MEDIA_CONTENT = NEW.MEDIA_CONTENT
, MEDIA_FLAG = NEW.MEDIA_FLAG
, EMBEDDED_CONTENT = NEW.EMBEDDED_CONTENT
, EMBEDDED_FLAG = 'Y', CLEAN_POST_FLAG = 'N'
, POST_UPDATE_DTM = NOW(), POST_PROCESSED_FLAG = 'N'
, TAG1_KEYID = NEW.TAG1_KEYID, STP_PROC_NAME = NEW.STP_PROC_NAME
, TOPICID = NEW.TOPICID
, POST_PROCESSED_DTM = NOW() WHERE POST_ID = OLD.POST_ID; 

CALL CLEAN_POST_FLG(OLD.POST_ID);
END IF;

END$$

DELIMITER ; 

--
-- NEW_COMMENT_CLEAN_FLAG

DELIMITER $$
DROP TRIGGER IF EXISTS NEW_COMMENT_CLEAN_FLAG $$
CREATE DEFINER=`root`@`%` TRIGGER NEW_COMMENT_CLEAN_FLAG 
AFTER INSERT ON OPN_POST_COMMENTS_RAW for each row
begin

/* -- CHANGE LOG

-- AT 04062017 ADDED COMMENT_UPDATE_DTM IN INSERT STATEMENTS

04252018 AST: adding the portion for updating the POST_UPDATE_DTM whenever a comment is added on a post
Similar code will have to be added to the COMMENT_UPDATE proc. But that is going to be more complicated

04/25/2020 AST: Adding media_content AND media_flag to the trigger

04/27/2020 AST: Added PARENT_COMMENT_CONTENT
, PARENT_COMMENT_UNAME, PARENT_COMMENT_DTM, PARENT_MEDIA_CONTENT, PARENT_MEDIA_FLAG

 04/30/2020 AST: Added COMMENT_BY_UNAME

*/

CASE WHEN NEW.COMMENT_TYPE = 'CONP' THEN

IF NEW.EMBEDDED_FLAG = 'N' THEN 
INSERT INTO OPN_POST_COMMENTS(COMMENT_ID
, CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, PARENT_COMMENT_ID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_BYUID
, COMMENT_DTM
, COMMENT_UPDATE_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, CLEAN_COMMENT_FLAG
, COMMENT_PROCESSED_FLAG
, COMMENT_PROCESSED_DTM
, MEDIA_CONTENT
, MEDIA_FLAG
, COMMENT_TYPE
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_UNAME
, PARENT_COMMENT_DTM
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG  )
VALUES
(NEW.COMMENT_ID
, NEW.CAUSE_POST_ID
, NEW.POST_BY_USERID
, NEW.TOPICID
, NEW.COMMENT_ID
, NEW.COMMENT_SEQ
, NEW.COMMENT_CONTENT
, NEW.COMMENT_BY_USERID
, new.COMMENT_BY_UNAME
, NEW.COMMENT_BY_USERID
, NEW.COMMENT_DTM
, NEW.COMMENT_DTM
, ''
, 'N'
, 'Y'
, 'Y'
, NOW()
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG
, NEW.COMMENT_TYPE
, NEW.COMMENT_CONTENT
, NEW.PARENT_COMMENT_UNAME
, NOW()
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG);


/* 04252018 AST: POST_UPDATE_DTM change begins part 1 */

UPDATE OPN_POSTS SET POST_UPDATE_DTM = NOW() WHERE POST_ID = NEW.CAUSE_POST_ID ;

/* 04252018 AST: POST_UPDATE_DTM change ends part 1 */

ELSE 
INSERT INTO OPN_POST_COMMENTS
(COMMENT_ID
, CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, PARENT_COMMENT_ID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_BYUID
, COMMENT_DTM
, COMMENT_UPDATE_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, CLEAN_COMMENT_FLAG
, COMMENT_PROCESSED_FLAG
, COMMENT_PROCESSED_DTM
, MEDIA_CONTENT
, MEDIA_FLAG
, COMMENT_TYPE
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_UNAME
, PARENT_COMMENT_DTM
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG  )
VALUES
(NEW.COMMENT_ID
, NEW.CAUSE_POST_ID
, NEW.POST_BY_USERID
, NEW.TOPICID
, NEW.COMMENT_ID
, NEW.COMMENT_SEQ
, NEW.COMMENT_CONTENT
, NEW.COMMENT_BY_USERID
, NEW.COMMENT_BY_UNAME
, NEW.COMMENT_BY_USERID
, NEW.COMMENT_DTM
, NEW.COMMENT_DTM
, NEW.EMBEDDED_CONTENT
, 'Y'
, 'N'
, 'N'
, NOW()
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG
, NEW.COMMENT_TYPE
, NEW.COMMENT_CONTENT
, NEW.COMMENT_BY_UNAME
, NEW.COMMENT_DTM
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG);

/* 04252018 AST: POST_UPDATE_DTM change begins part 2 
Here the thinking is like this: Even if the CLEAN_COMMENT_FLG keeps the comment unclean, the POST_UPDATE_DTM 
for the CAUSE_POST_ID will get updated no NOW().
This is not in ideal situation - why bump up a post when the comment is unclean?
But this is a quick and 'dirty' way to do it.
In future, we can actually change the CLEAN_COMMENT_FLG itself to add this update statement 
to the update statements in the CLEAN_COMMENT_FLG

*/

UPDATE OPN_POSTS SET POST_UPDATE_DTM = NOW() WHERE POST_ID = NEW.CAUSE_POST_ID ;

/* 04252018 AST: POST_UPDATE_DTM change ends part 2 */

 CALL CLEAN_COMMENT_FLG(NEW.COMMENT_ID);
END IF;

WHEN NEW.COMMENT_TYPE = 'CONC' THEN

IF NEW.EMBEDDED_FLAG = 'N' THEN 
INSERT INTO OPN_POST_COMMENTS(COMMENT_ID
, CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, PARENT_COMMENT_ID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_BYUID
, COMMENT_DTM
, COMMENT_UPDATE_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, CLEAN_COMMENT_FLAG
, COMMENT_PROCESSED_FLAG
, COMMENT_PROCESSED_DTM
, MEDIA_CONTENT
, MEDIA_FLAG
, COMMENT_TYPE
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_UNAME
, PARENT_COMMENT_DTM
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG  )
VALUES
(NEW.COMMENT_ID
, NEW.CAUSE_POST_ID
, NEW.POST_BY_USERID
, NEW.TOPICID
, NEW.PARENT_COMMENT_ID
, NEW.COMMENT_SEQ
, NEW.COMMENT_CONTENT
, NEW.COMMENT_BY_USERID
, new.COMMENT_BY_UNAME
, NEW.PARENT_COMMENT_BYUID
, NEW.COMMENT_DTM
, NEW.COMMENT_DTM
, ''
, 'N'
, 'Y'
, 'Y'
, NOW()
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG
, NEW.COMMENT_TYPE
, NEW.PARENT_COMMENT_CONTENT
, NEW.PARENT_COMMENT_UNAME
, NEW.PARENT_COMMENT_DTM
, NEW.PARENT_MEDIA_CONTENT
, NEW.PARENT_MEDIA_FLAG);


/* 04252018 AST: POST_UPDATE_DTM change begins part 1 */

UPDATE OPN_POSTS SET POST_UPDATE_DTM = NOW() WHERE POST_ID = NEW.CAUSE_POST_ID ;

/* 04252018 AST: POST_UPDATE_DTM change ends part 1 */

ELSE 
INSERT INTO OPN_POST_COMMENTS
(COMMENT_ID
, CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, PARENT_COMMENT_ID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_BYUID
, COMMENT_DTM
, COMMENT_UPDATE_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, CLEAN_COMMENT_FLAG
, COMMENT_PROCESSED_FLAG
, COMMENT_PROCESSED_DTM
, MEDIA_CONTENT
, MEDIA_FLAG
, COMMENT_TYPE
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_UNAME
, PARENT_COMMENT_DTM
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG  )
VALUES
(NEW.COMMENT_ID
, NEW.CAUSE_POST_ID
, NEW.POST_BY_USERID
, NEW.TOPICID
, NEW.PARENT_COMMENT_ID
, NEW.COMMENT_SEQ
, NEW.COMMENT_CONTENT
, NEW.COMMENT_BY_USERID
, NEW.COMMENT_BY_UNAME
, NEW.PARENT_COMMENT_BYUID
, NEW.COMMENT_DTM
, NEW.COMMENT_DTM
, NEW.EMBEDDED_CONTENT
, 'Y'
, 'N'
, 'N'
, NOW()
, NEW.MEDIA_CONTENT
, NEW.MEDIA_FLAG
, NEW.COMMENT_TYPE
, NEW.PARENT_COMMENT_CONTENT
, NEW.PARENT_COMMENT_UNAME
, NEW.PARENT_COMMENT_DTM
, NEW.PARENT_MEDIA_CONTENT
, NEW.PARENT_MEDIA_FLAG);

/* 04252018 AST: POST_UPDATE_DTM change begins part 2 
Here the thinking is like this: Even if the CLEAN_COMMENT_FLG keeps the comment unclean, the POST_UPDATE_DTM 
for the CAUSE_POST_ID will get updated no NOW().
This is not in ideal situation - why bump up a post when the comment is unclean?
But this is a quick and 'dirty' way to do it.
In future, we can actually change the CLEAN_COMMENT_FLG itself to add this update statement 
to the update statements in the CLEAN_COMMENT_FLG

*/

UPDATE OPN_POSTS SET POST_UPDATE_DTM = NOW() WHERE POST_ID = NEW.CAUSE_POST_ID ;

/* 04252018 AST: POST_UPDATE_DTM change ends part 2 */

 CALL CLEAN_COMMENT_FLG(NEW.COMMENT_ID);
END IF;

END CASE ;

END$$

DELIMITER ; 
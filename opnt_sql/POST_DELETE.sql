-- POST_DELETE

-- TRIGGER TO DELETE POSTS FROM OPN_POSTS

DELIMITER $$
DROP TRIGGER IF EXISTS POST_DELETE $$
CREATE TRIGGER POST_DELETE 
AFTER DELETE ON OPN_POSTS for each row
begin

/*

	07/17/2020 AST: Adding the DELETE from OPN_POST_SEARCH_T to ensure that 
					deleted posts don't show up in search results

*/

DELETE FROM OPN_POST_COMMENTS WHERE OPN_POST_COMMENTS.CAUSE_POST_ID = OLD.POST_ID ;

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.CAUSE_POST_ID = OLD.POST_ID ;

DELETE FROM OPN_POST_SEARCH_T WHERE OPN_POST_SEARCH_T.POST_ID = OLD.POST_ID ;

INSERT INTO OPN_POSTS_DELETED(OLD_POST_ID, TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, EMBEDDED_CONTENT
, TAG1_KEYID, TAG2_KEYID, TAG3_KEYID, CLEAN_POST_FLAG, POST_UPDATE_DTM
, DEMO_POST_FLAG, POSTOR_COUNTRY_CODE, POSTOR_TYPE_TAG, ACTION_TYPE) 
VALUES (OLD.POST_ID, OLD.TOPICID, OLD.POST_DATETIME, OLD.POST_BY_USERID
, OLD.POST_CONTENT, OLD.EMBEDDED_CONTENT, OLD.TAG1_KEYID, OLD.TAG2_KEYID, OLD.TAG3_KEYID, OLD.CLEAN_POST_FLAG, NOW()
, OLD.DEMO_POST_FLAG, OLD.POSTOR_COUNTRY_CODE, OLD.POSTOR_TYPE_TAG, 'D');

END$$

DELIMITER ; 

-- 
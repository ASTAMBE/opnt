-- proctest

 DELIMITER //
DROP PROCEDURE IF EXISTS proctest //
CREATE PROCEDURE proctest(uuid varchar(45), actionSource VARCHAR(10), actionType varchar(5), sourceID INT)
thisproc:BEGIN

/*
	    
*/

declare  ORIG_UID, causePostID, TID, causeCommentID, postByUID, commentByUID, altkey, altkid INT;
DECLARE actionTypeNew,UNAME VARCHAR(30) ;
DECLARE POSTCONTENT VARCHAR(300) ;

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT TOPICID, POST_BY_USERID, IFNULL(KEYID, 0), SUBSTR(POST_CONTENT, 1, 100) INTO TID, postByUID, altkey, POSTCONTENT FROM OPN_POSTS WHERE POST_ID = sourceID ;

CASE WHEN altkey = 0 THEN 
SELECT ifnull(MIN(KEYID),0) INTO altkid FROM OPN_P_KW WHERE KEYWORDS LIKE CONCAT("'", POSTCONTENT, '%', "'") ;
-- SELECT UNAME, ORIG_UID, TID, postByUID, altkey, POSTCONTENT, CONCAT("'", POSTCONTENT, '%', "'"), altkid ;
-- LEAVE thisproc ;

WHEN  altkey != 0 THEN
SET altkid = altkey ;
-- SELECT UNAME, ORIG_UID, TID, postByUID, altkey, POSTCONTENT, CONCAT("'", POSTCONTENT, '%', "'"), altkid ;

END CASE ;
-- LEAVE thisproc ;


/* Adding RAW logging portion */

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
CONCAT('sourceID', '-', 'altkey-altkid-CONCAT' )
, concat(sourceID,'-', altkey, '-', altkid,'-', CONCAT("'", POSTCONTENT, '%', "'") ), NOW()) ; 

-- END OF RAW LOGGING */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, ORIG_UID, uuid, NOW(), 'userPostLH-PROCTEST'
, CONCAT(ORIG_UID, ' - POST -',actionType, ' FOR POST_ID = ', sourceID));

/* end of use action tracking */

IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;
INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM
, CAUSE_POST_ID, ACTION_SOURCE, TOPICID, KEYID) 
VALUES (ORIG_UID, postByUID, actionTypeNew, NOW(), sourceID, 'POST', TID, altkid) ;



END //
DELIMITER ;

-- 

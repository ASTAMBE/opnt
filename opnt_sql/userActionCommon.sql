-- userActionCommon

 DELIMITER //
DROP PROCEDURE IF EXISTS userActionCommon //
CREATE PROCEDURE userActionCommon(uuid varchar(45), actionSource VARCHAR(10), actionType varchar(5), sourceID INT)
BEGIN

/*
	06/04/2020 AST: Building this proc as a combined proc for User Post or Comment Actions
	When a user Loves or Hates a Post or a Comment, this proc will record the action.
    As usual, it will first delete any existing actions - in order to avoid possible doubles.alter
    
    actionSource 	= POST/COMMENT
    actionType 		= L0/H0/L1/H1 (L0/H0 is sent when the user is canceling an existing L/H)
						L1/H1 is sent when the user is showing L/H fresh
    sourceID		= POST_ID/COMMENT_ID
	
	08/11/2020 Kapil: Confirmed
    
    12/26/2022 AST: Added user BHV log
    
    02/26/2023 AST: Added ALT_KEYID from OPN_POSTS for convertPostToKW proc
    03/04/2023 AST: When a user already has L/H for a post, he can change it in 2 ways. 
    1. He can click the same sign again - this will cancel the existing L/H and pass a L0/H0 as param
    2. If he simply switches the sign (eg. he had given L but now he is clicking H), then the App 
    actually passes 2 API calls. First for a 0 - no negate the existing sign
    Then it passes the 1 to record his latest opinion on the post.alter
    This introduces a need whereby we need to specifically delete the CART row as part of
    dealing with the L0/H0 param.
    
    10/21/2024 AST: It was found that sometimes a post may be created again and escapes the DUPE detection
    This can cause a vreakdown if the same post is L/H by a user and then the convertPosttoKW tries to create a new KW
    It finds that the KW already exists - this scenario results into an internal error which prevents the recording
    of L/H in the OPN_USER_POST_ACTION table.alter
    Hence we need to populate the altkey in a different manner.
    
*/

declare  ORIG_UID, causePostID, TID, causeCommentID, postByUID, commentByUID, altkey, altkid INT;
DECLARE actionTypeNew,UNAME VARCHAR(30) ;
DECLARE POSTCONTENT VARCHAR(300) ;

CASE WHEN actionSource = 'COMMENT' THEN

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT OPC1.TOPICID, OPC1.COMMENT_BY_USERID, OPC1.CAUSE_POST_ID INTO TID, commentByUID, causePostID
FROM OPN_POST_COMMENTS OPC1 WHERE OPC1.COMMENT_ID = sourceID ;

/* Adding user action logging portion - in case we want to turn this on for this proc */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, ORIG_UID, uuid, NOW(), 'userCommentLH'
, CONCAT(ORIG_UID, ' - COMMENT -',actionType, ' FOR COMMENT_ID = ', sourceID));

/* end of use action tracking */

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.ACTION_BY_USERID = ORIG_UID 
AND OPN_USER_POST_ACTION.CAUSE_COMMENT_ID = sourceID 
AND OPN_USER_POST_ACTION.COMMENT_BY_USERID =  commentByUID ;

CASE WHEN actionType = 'L1' or actionType = 'H1' THEN
IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;

INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, COMMENT_BY_USERID, ACTION_TYPE, POST_ACTION_DTM
, CAUSE_COMMENT_ID, ACTION_SOURCE, TOPICID) 
VALUES (ORIG_UID, commentByUID, actionTypeNew, NOW(), sourceID, 'COMMENT', TID) ;
ELSE BEGIN END;

END CASE ;

WHEN actionSource = 'POST' THEN

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT TOPICID, POST_BY_USERID, IFNULL(KEYID, 0), SUBSTR(POST_CONTENT, 1, 100) INTO TID, postByUID, altkey, POSTCONTENT FROM OPN_POSTS WHERE POST_ID = sourceID ;

IF altkey = 0 THEN 
SELECT ifnull(MIN(KEYID),0) INTO altkid FROM OPN_P_KW WHERE KEYWORDS LIKE CONCAT("'", POSTCONTENT, '%', "'") ;
ELSE 
set altkid = altkey ;

/* Adding RAW logging portion */

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
CONCAT('sourceID', '-', 'altkey-altkid-CONCAT' )
, concat(sourceID,'-', altkey, '-', altkid,'-', CONCAT("'", POSTCONTENT, '%', "'") )) ; 

-- END OF RAW LOGGING */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, ORIG_UID, uuid, NOW(), 'userPostLH'
, CONCAT(ORIG_UID, ' - POST -',actionType, ' FOR POST_ID = ', sourceID));

/* end of use action tracking */

CASE WHEN actionType IN ('L0', 'H0') THEN 

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.ACTION_BY_USERID = ORIG_UID 
AND OPN_USER_POST_ACTION.CAUSE_POST_ID = sourceID AND OPN_USER_POST_ACTION.POST_BY_USERID =  postByUID ;

DELETE FROM OPN_USER_CARTS WHERE USERID = ORIG_UID AND TOPICID = TID AND KEYID = altkid ;

 WHEN actionType IN ('L1', 'H1') THEN
IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;
INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM
, CAUSE_POST_ID, ACTION_SOURCE, TOPICID, KEYID) 
VALUES (ORIG_UID, postByUID, actionTypeNew, NOW(), sourceID, 'POST', TID, altkid) ;

END CASE ;

END IF ;

END CASE ;

END //
DELIMITER ;

-- 

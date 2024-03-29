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
    actionType 		= L/H 
    sourceID		= POST_ID/COMMENT_ID
	
	08/11/2020 Kapil: Confirmed
*/

declare  ORIG_UID, causePostID, TID, causeCommentID, postByUID, commentByUID INT;
DECLARE actionTypeNew,UNAME VARCHAR(30) ;

CASE WHEN actionSource = 'COMMENT' THEN

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT OPC1.TOPICID, OPC1.COMMENT_BY_USERID, OPC1.CAUSE_POST_ID INTO TID, commentByUID, causePostID
FROM OPN_POST_COMMENTS OPC1 WHERE OPC1.COMMENT_ID = sourceID ;

/* Adding user action logging portion - in case we want to turn this on for this proc */
/*
INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, ORIG_UID, uuid, NOW(), 'userCommentLH'
, CONCAT(ORIG_UID, ' - COMMENT -',actionType, ' FOR COMMENT_ID = ', sourceID));
*/
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

SELECT TOPICID, POST_BY_USERID INTO TID, postByUID FROM OPN_POSTS WHERE POST_ID = sourceID ;

/* Adding user action logging portion */



/* end of use action tracking */

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.ACTION_BY_USERID = ORIG_UID 
AND OPN_USER_POST_ACTION.CAUSE_POST_ID = sourceID 
AND OPN_USER_POST_ACTION.POST_BY_USERID =  postByUID ;

CASE WHEN actionType = 'L1' or actionType = 'H1' THEN
IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;
INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM
, CAUSE_POST_ID, ACTION_SOURCE, TOPICID) 
VALUES (ORIG_UID, postByUID, actionTypeNew, NOW(), sourceID, 'POST', TID) ;
ELSE BEGIN END;
END CASE ;

END CASE ;

END //
DELIMITER ;

-- 

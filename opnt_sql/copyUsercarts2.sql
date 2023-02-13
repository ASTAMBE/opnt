-- copyUserCarts2

DROP PROCEDURE IF EXISTS `copyUserCarts2`;
DELIMITER //
CREATE PROCEDURE copyUserCarts2(uuidFrom varchar(45), uuidTo varchar(45), postID INT, uType varchar(5))
THISPROC: BEGIN

/* 	

	07/13/2020 AST: Initial Creation for copying an inviter user's carts to invitee user
					Handling the cases where the inviter kills the cart after the invite
                    
	08/09/2020 AST: COnfirmed
	12/09/2020 AST: Added enhannced BHV LOG. Added OU update to track the invites

	01/12/2021 AST: adding cases for copying minimum cart so that existing users
    can also get 'shared post'
    Why: Here is what is happening. Lots of people have registered but there is no further 
	interaction. We need to nudge them by posting controversial articles or posts and
    inviting them to join the discussion.
    But this can be done only if we allow the sharedTo user to have at least something
    common with the sharing user - if not then we should copy just one element from the sharer
    cart to shareTo cart
    Whast if sharer and shareTo have exactly opposite carts?
    Option 1: We can select a random keyid (that is not in the cart already) in that topic 
    and assign it to both with same cart L
    Option 2: truly leave them alone and show a msg that this post is not available
    option 3: in this case the post will be avlbl as an 'opposite' - we can write very
    complex code to identify this scenario and take the app landing to opposites
*/

declare UIDFROM, UIDTO, FROMCARTCNT, TOCARTCNT, TIDTO, copyINVITERKID INT;
declare UNAMEFROM, UNAMETO varchar(40) ;
declare CCODEFROM, CCODETO, CARTFROM, CARTTO, uty varchar(3) ;

declare T1, T2, T3, T4, T5, T8, T9, T10, CRTCMNCNT, TAG1KID, KIDCOMNCNT INT ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;

SET SQL_SAFE_UPDATES = 0;

SELECT U1.USERID, U1.USERNAME, U1.COUNTRY_CODE INTO UIDFROM, UNAMEFROM, CCODEFROM 
FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuidFrom ;

SELECT U2.USERID, U2.USERNAME, U2.COUNTRY_CODE INTO UIDTO, UNAMETO, CCODETO 
FROM OPN_USERLIST U2 WHERE U2.USER_UUID = uuidTo ;

-- SELECT UIDFROM, UNAMEFROM, CCODEFROM, UIDTO, UNAMETO, CCODETO ;
-- LEAVE THISPROC;

/*  In this bloack below: make the declarations for the case where the inviter is 
sharing from profile page - which means no specific postid is shared */

CASE WHEN postID = 0 AND uType = 'NEW' THEN 
SELECT IFNULL(UC1.TOPICID, 0) INTO TIDTO FROM OPN_USER_CARTS UC1 WHERE UC1.USERID = UIDFROM 
ORDER BY UC1.LAST_UPDATE_DTM DESC LIMIT 1 ;

 WHEN postID = 0 AND uType = 'OLD' THEN 
SET TIDTO = IFNULL((SELECT UC2.TOPICID FROM OPN_USER_CARTS UC2 WHERE UC2.USERID = UIDTO
ORDER BY UC2.LAST_UPDATE_DTM DESC LIMIT 1),0) ;

-- SELECT TIDTO ; LEAVE THISPROC;

WHEN postID <> 0 THEN 
SET TIDTO = IFNULL((SELECT OPR1.TOPICID FROM OPN_POSTS_RAW OPR1 WHERE OPR1.POST_BY_USERID = UIDFROM 
AND OPR1.POST_ID = postID), 0) ;

END CASE ;
    
/* End of profile page share declarations block */

SET TOCARTCNT = (SELECT COUNT(1) FROM OPN_USER_CARTS WHERE USERID = UIDTO) ;

/* 	When the Inviter has an empty cart - then the invitee carts are also kept empty or unchanged */

CASE WHEN TIDTO = 0 AND uType = 'NEW' THEN 
/* this case is when inviter killed his cart but invitee created a new profile - assign the deafault cart to invitee */

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UIDTO, T1, 'L', 1, NOW(), NOW()), (UIDTO, T10, 'L', 10, NOW(), NOW()) 
, (UIDTO, T5, 'L', 5, NOW(), NOW()), (UIDTO, T3, 'L', 3, NOW(), NOW())
, (UIDTO, T2, 'L', 2, NOW(), NOW()), (UIDTO, T4, 'L', 4, NOW(), NOW())
, (UIDTO, T8, 'L', 8, NOW(), NOW()), (UIDTO, T9, 'L', 9, NOW(), NOW()) ;

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME, INVITEE_UUID
, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('TID0NEW', uuidFrom, UIDFROM, UNAMEFROM, uuidTo, UIDTO, UNAMETO, NOW()) ;

SELECT uuidTo, 0, 0 ;

WHEN TIDTO = 0 AND uType = 'OLD' THEN 
/* this case is when inviter killed his cart but invitee has an existing profile */

SET TIDTO = IFNULL((SELECT UC2.TOPICID FROM OPN_USER_CARTS UC2 WHERE UC2.USERID = UIDTO
ORDER BY UC2.LAST_UPDATE_DTM DESC LIMIT 1), 1) ;

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME, INVITEE_UUID
, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('TID0OLD', uuidFrom, UIDFROM, UNAMEFROM, uuidTo, UIDTO, UNAMETO, NOW()) ;

SELECT uuidTo, TIDTO, 0 ;

-- END CASE ;

/* Now starting the main CASE block */

-- CASE 
WHEN TIDTO <> 0 AND postID = 0 AND uType = 'NEW'  THEN

-- SELECT TIDTO, postID, uType ; LEAVE THISPROC;

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

UPDATE OPN_USERLIST SET INVITEE_FLAG = 'Y', INVITER_UNAME = UNAMEFROM, INVITER_UID = UIDFROM
WHERE USERID = UIDTO ;

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME, INVITEE_UUID
, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('POSTID0 - INVITEENEW', uuidFrom, UIDFROM, UNAMEFROM, uuidTo, UIDTO, UNAMETO, NOW()) ;

SELECT uuidTo, TIDTO, 0 ;

WHEN TIDTO <> 0 AND postID = 0 AND uType = 'OLD'  THEN

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME, INVITEE_UUID
, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('POSTID0 - INVITEEOLD', uuidFrom, UIDFROM, UNAMEFROM, uuidTo, UIDTO, UNAMETO, NOW()) ;

SELECT uuidTo, TIDTO, 0 ;

WHEN TIDTO <> 0 AND postID <> 0 AND uType = 'NEW'  THEN

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

UPDATE OPN_USERLIST SET INVITEE_FLAG = 'Y', INVITER_UNAME = UNAMEFROM, INVITER_UID = UIDFROM
WHERE USERID = UIDTO ;

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME
, INVITE_POSTID, INVITEE_UUID, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('POSTSHARE - INVITEENEW', uuidFrom, UIDFROM, UNAMEFROM, postID, uuidTo, UIDTO, UNAMETO, NOW()) ;

WHEN TIDTO <> 0 AND postID <> 0 AND uType = 'OLD'  THEN

SET CRTCMNCNT = (SELECT COUNT(1) FROM (SELECT A.KEYID
FROM OPN_USER_CARTS A, OPN_USER_CARTS B
WHERE A.USERID = UIDFROM AND B.USERID = UIDTO
AND A.KEYID = B.KEYID AND A.CART = B.CART AND A.TOPICID = TIDTO)Q) ;

/* Starting the sub-case where post is shared with an existing user - since he already has a cart
this could result into opinion over-writing */

/* case 1: if the CRTCMNCNT is > 0 then the invitee and inviter already have common in this TID
 then there is no need for copying anything - can directly take the invitee to the shared postid */
 
 CASE WHEN CRTCMNCNT > 0 THEN
 
 /* There is a very special case of this case: What is the invitee and inviter have different
 country_codes? in that case even if they have common cart, the post will not be visible to 
 the invitee if inviter is USA/IND while invitee is IND/USA and the post has a TAG1_KEYID and
 is non-GGG. Inn that case the invitee will still not see it */
 
 INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME
, INVITE_POSTID, INVITEE_UUID, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('POSTSHARE - INVITEEOLD - CMNCRT', uuidFrom, UIDFROM, UNAMEFROM, postID, uuidTo, UIDTO, UNAMETO, NOW()) ;

SELECT uuidTo, TIDTO, postID ;

WHEN CRTCMNCNT <= 0 THEN

/* 01/29/2021 AST: At this time, we are going to treat this very important case in a simple handling
	Nothing will be copied and the invitee will simply get a message that he doesn't have any common cart */
    
    /* actually, there are many special cases of this case:
    1. what if the inviter and invitee have exactly opposite carts: Then we should be taking the invitee
    to the 'Opposite-minded' discussion. Too complicated for the time being
    
    The basic, functional thing is: Inviter wants to share something and invitee has clicked it becuase
    he found it interesting but he has nothing in common with the inviter. The q is: should we engineer 
    the consummation of this transaction by surreptitiously bringing them into a common network by
    
    - forcing a new KW on both - the KW could be a made up UUID that is used only for this kind of
    forced networking. Then q are: should we make this uuid-key visible in the cart? does that 
    produce an undesirable experience to the invitee - or inviter
    
    this can produce its own downside - the carts can keep getting heavier etc.
    We will keep monitoring to see if this special case needs a heavier engg solution
    
    */

/*
SET KIDCMNCNT = (SELECT COUNT(1) FROM (SELECT A.KEYID
FROM OPN_USER_CARTS A, OPN_USER_CARTS B
WHERE A.USERID = UIDFROM AND B.USERID = UIDTO AND A.KEYID = B.KEYID AND A.TOPICID = TIDTO)Q) ;

SELECT KEYID, CART INTO copyINVITERKID, CARTTO FROM OPN_USER_CARTS WHERE USERID = UIDFROM AND TOPICID = TIDTO 
ORDER BY LAST_UPDATE_DTM DESC LIMIT 1 ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
VALUES(UIDTO, TIDTO, copyINVITERKID, CARTTO, NOW(), NOW()) ;

*/

INSERT INTO OPN_INVITE_ACCEPT_LOG(INVITE_TYPE, INVITER_UUID, INVITER_UID, INVITER_UNAME
, INVITE_POSTID, INVITEE_UUID, INVITEE_UID, INVITEE_UNAME, INVITE_ACCEPT_DTM)
VALUES('POSTSHARE - INVITEEOLD - NOCMN', uuidFrom, UIDFROM, UNAMEFROM, postID, uuidTo, UIDTO, UNAMETO, NOW() ) ;

SELECT uuidTo, TIDTO, postID ;
 
 END CASE ;
 
 

END CASE ;


END//
DELIMITER ;

-- 
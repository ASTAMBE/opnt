-- convertPostToKW

-- USE `opntprod`;
DROP procedure IF EXISTS `convertPostToKW`;

DELIMITER $$
-- USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `convertPostToKW`(postid INT, tid INT, actionbyid INT
, actiondtm DATETIME, actionType varchar(5), kidparam INT )
thisproc: BEGIN

/*
    02/05/2023 AST: Initial Creation
    This proc will be called from the OPN_POSTS (INSERT) trigger. It will take the postid param
    and check if this postid has already been converted to a KW. if yes, then it will simply exit
    If the post hasn't been converted to KW, then it will fetch all the requisite data from
    OPN_POSTS and do the necessary processing to convert it into KW - will insert into
    OPN_P_KW, OPN_KW_TAGS AND OPN_USER_CARTS
    
    What CCODE to use ? : The ccode of the new KW to be created should be that of the user who is doing the 
    L/H to the post. THis thinking may change later.
    
    The overall plan is this:
    
    This proc will do the following jobs:
    1. It will bring the post details such as URL_TITLE, POST_CONTENT etc. and prepare the SUBSTR for them
    2. It will create a KW out of the post that has been passed as a param
    3. It will fetch back the newly created KEYID (or the KEYID that has been passed to it) and upsert a 
    row in the OPN_USER_CARTS table for the acting user.
    4. Finally, it will update the OPN_POSTS table with the newly created KEYID for the passed POST_ID
    
    How does it work ?
    
    1. When a user clicks L/H for a post, that invokes the userActionCommon API. THis will create a row in 
    the OPN_USER_POST_ACTION table for that post_id. At the time of the invoking of the userActionCommon
    API, either the OPN_POSTS already has a KEYID associated with this POST_ID, or it has a NULL for the KEYID.
    The userActionCommon will also receive this KEYID (or NULL).
		1.1 If the KEYID is non-null, then it is understood that a KW has already been created. Now it only 
        needs an upsert in the OPN_USER_CARTS table. Hence this proc (convertPostToKW) will only upsert
        the cart (why upsert ? because the user may change his L/H, so it may exist already in his cart)
        1.2 If the KEYID is null, then the proc will do all the 4 tasks mentioned above.
        
	04/21/2023 AST: Covering the case of discussion post converting to KW - in a discussion post, you may have
    no URL - hence you have to use IFNULL(substrURLT, substrPCONT) for KEYWORDS
    
    06/11/2023 AST: Adding the ADD_NUSERS_4K1 call - for parity with the cretaaeKW proc
    
 */

declare pbuid, actionByUID, postidvar, newkeyid INT;
DECLARE pbuname, actionByUNAME VARCHAR(30) ;
DECLARE substrPCONT, KW, substrURLT, UUID VARCHAR(160) ;
DECLARE POSTCONTENT, URLTITLE LONGTEXT ;
DECLARE actionCDTM DATETIME ;
DECLARE CCODE VARCHAR(5) ;

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
'convertPostToKW-Entrypoint: postid-actionbyid-actionType-kidparam', CONCAT(postid,'-',actionbyid,'-', actionType, '-', kidparam), NOW() ) ;

CASE WHEN kidparam = 0 THEN

SELECT P.POST_ID, POST_CONTENT, SUBSTR(P.POST_CONTENT, 1, 160), P.URL_TITLE, SUBSTR(P.URL_TITLE, 1, 160)
INTO postidvar, POSTCONTENT, substrPCONT, URLTITLE, substrURLT FROM OPN_POSTS P WHERE P.POST_ID = postid ;

SELECT USERNAME, USER_UUID, COUNTRY_CODE INTO actionByUNAME, UUID, CCODE 
FROM OPN_USERLIST WHERE USERID = actionbyid ;

/* Creating the new KeyWord below and updating the OPN_POSTS */

INSERT INTO OPN_P_KW(TOPICID, KEYWORDS, KW_TRIM, COUNTRY_CODE, DISPLAY_SEQ, CREATION_DTM
, LAST_UPDATE_DTM, CLUSTER_PRIO, ORIGIN_COUNTRY_CODE, NEW_KW_FLAG, SCRAPE_TAG1, SCRAPE_TAG2,
USER_CREATED_KW, CREATED_BY_UID, CREATED_BY_UUID, CREATED_BY_UNAME, CLEAN_KW_FLAG, KW_EXT, KW_URL, ALT_KEYID)
VALUES (tid, IFNULL(substrURLT, substrPCONT)
, CONCAT(UPPER(REPLACE(IFNULL(substrURLT, substrPCONT), ' ', '') ), tid) , CCODE, 5, NOW()
, NOW(), 5, CCODE, 'N', 'NOSCRAPE', 'NOSCRAPETAG2'
, 'Y', actionbyid, UUID, actionByUNAME, 'Y', URLTITLE, POSTCONTENT , postid ); 

SELECT KEYID INTO newkeyid FROM OPN_P_KW WHERE ALT_KEYID = postid limit 1 ;

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
'convertPostToKW-Inserted New POST to KW: newkeyid-substrURLT-POSTCONTENT-postid'
, CONCAT(newkeyid, '-', substrURLT,'-',POSTCONTENT,'-', postid), NOW() ) ;

INSERT INTO OPN_KW_TAGS(TOPICID, KEYID, KEYWORDS, KW_TRIM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE
, SCRAPE_TAG1, SCRAPE_TAG2, KW_EXT, KW_URL, ALT_KEYID, SCRAPE_DESIGN_DONE, KW_DTM)
VALUES(tid, newkeyid, IFNULL(substrURLT, substrPCONT)
, CONCAT(UPPER(REPLACE(IFNULL(substrURLT, substrPCONT), ' ', '') ), tid) , CCODE, CCODE
, 'NOSCRAPE', 'NOSCRAPETAG2', URLTITLE, POSTCONTENT, postid, 'N', NOW()) ;

UPDATE OPN_POSTS SET KEYID = newkeyid WHERE POST_ID = postid ;

/* End of new KW creation */

/* Begin upsert in the cart */

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES(actionType, newkeyid, actionbyid, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = actionType ;

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
'convertPostToKW-Inserted CART with new POST-TO-KW: newkeyid-Cart For USERID-Topicid-CART Value'
, CONCAT(newkeyid, '-', actionbyid,'-',tid,'-', actionType), NOW() ) ;

-- CALL ADD_NUSERS_4K1(newkeyid , CCODE,  tid) ;

/* END upsert in the cart */

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(actionByUNAME, actionbyid, UUID, NOW(), 'convertPostToKW', CONCAT(tid,'-',postid, '-', newkeyid));

/* end of user action tracking */

WHEN kidparam <> 0 then

-- SELECT actionType, kidparam, actionbyid, tid ;

-- LEAVE thisproc ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( actionType, kidparam, actionbyid, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = actionType ;

INSERT INTO OPN_RAW_LOGS(KEYVALUE_KEY, KEYVALUE_VALUE, LOG_DTM) VALUES(
'convertPostToKW-Inserted CART with existing POST-TO-KW: kidparam-Cart For USERID-Topicid-CART Value'
, CONCAT(kidparam, '-', actionbyid,'-',tid,'-', actionType), NOW() ) ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(NULL, actionbyid, NULL, NOW(), 'convertPostToKW-CART', CONCAT(tid,'-',postid, '-', actionType));

/* end of user action tracking */

END CASE ;


END$$

DELIMITER ;

-- 
-- createSearchKW

DELIMITER //
DROP PROCEDURE IF EXISTS createSearchKW //
CREATE PROCEDURE createSearchKW(tid INT, uuid varchar(45), userKW varchar(60), usercart varchar(3))
THISPROC: BEGIN

/*
06/17/2018 AST: Initial Proc creation for a new KW being created through the search screen
08/24/2018 AST: Added SCRAPE_TAG1, SCRAPE_TAG2 to INSERT INTO OPN_KW_TAGS
10/31/2018 AST: SCRAPE_TAG2 in the INSERT replaced with CONCAT(LOWER(REPLACE(KEYWORDS, ' ', '') ),TOPICID)
This is done to deal with the proposed change where the opn_p_kw will have keywords + topicid as composite key

CALL createSearchKW(9, bringUUID(1017079), 'IND', 'Mamata Didi and Congress Sleeping Together Again', 'H') ;

The Proc does 3 things: 
- It creates the new KW
- It puts the new KW in the creating user's cart (that is why there is the usercart param)
- And it also creates a post for the creating user with the new KW as the post content

04/10/2019 AST: Changed the TNAME to case statement - because earlier it was using the TOPICNAME from opn_topics
and that was causing issues in the downstream tagging and STP processes.

05/31/2020 AST: Removing the the ccode form input params. Also replaced newPost with newPostWithMedia call.

06/14/2020 AST: Added WHEN TOPICID = 11 THEN 'HEALTH' 
08/19/2020 Kapil: Confirmed

10/06/2024 AST: Suppressing the OPN_SCRAPE_DESIGN_GEN call - because it is failing
and because the scrape design is not being used anymnore

 */

declare  orig_uid , NEWKID INT;
DECLARE UNAME, TNAME VARCHAR(30) ;
DECLARE STAG24LLIST VARCHAR(60) ;
DECLARE ccode VARCHAR(5) ;
DECLARE SUSP VARCHAR(5) ;

SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE

SET TNAME := (SELECT CASE WHEN TOPICID = 1 THEN 'POLITICS'
WHEN TOPICID = 2 THEN 'SPORTS' 
WHEN TOPICID = 3 THEN 'SCIENCE'
WHEN TOPICID = 4 THEN 'BUSINESS' 
WHEN TOPICID = 5 THEN 'ENT'
WHEN TOPICID = 6 THEN 'RELIGION' 
WHEN TOPICID = 7 THEN 'LIFE'
WHEN TOPICID = 8 THEN 'MISC' 
WHEN TOPICID = 9 THEN 'TREND'
WHEN TOPICID = 10 THEN 'CELEB' 
WHEN TOPICID = 11 THEN 'HEALTH' 

END  FROM OPN_TOPICS WHERE TOPICID = tid );

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE INTO orig_uid, UNAME, ccode FROM OPN_USERLIST OU WHERE OU.USER_UUID = uuid ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'createSearchKW', CONCAT(tid, '-', userKW));


INSERT INTO OPN_P_KW(TOPICID, KEYWORDS, KW_TRIM, COUNTRY_CODE, DISPLAY_SEQ, CREATION_DTM
, LAST_UPDATE_DTM, CLUSTER_PRIO, ORIGIN_COUNTRY_CODE, NEW_KW_FLAG, SCRAPE_TAG1, SCRAPE_TAG2,
USER_CREATED_KW, CREATED_BY_UID, CREATED_BY_UUID, CREATED_BY_UNAME, CLEAN_KW_FLAG)
VALUES (tid, userKW, CONCAT(UPPER(REPLACE(KEYWORDS, ' ', '') ), TOPICID) , ccode, 5, NOW(), NOW(), 5, ccode, 'N'
, UPPER(TNAME), CONCAT(LOWER(REPLACE(KEYWORDS, ' ', '') ),TOPICID), 'Y', orig_uid, uuid, UNAME, 'Y' ); 

SET NEWKID = (SELECT MAX(KEYID) FROM OPN_P_KW WHERE KEYWORDS  = userKW AND TOPICID = tid) ;
SET STAG24LLIST = (SELECT SCRAPE_TAG2 FROM OPN_P_KW WHERE KEYID = NEWKID) ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( usercart, NEWKID, orig_uid, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = usercart;

/* 03/11/2019  removing the clustering section - because it is not mneeded anymore after SQL-based network  */
 -- removed on 03/11/2019 CALL NEWCART_TOP_NOTAILOR(uuid, tid) ;

INSERT INTO OPN_KW_TAGS(TOPICID, KEYID, KEYWORDS, KW_TRIM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE
, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_DESIGN_DONE, KW_DTM)
SELECT TOPICID, KEYID, KEYWORDS, KW_TRIM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE
, SCRAPE_TAG1, SCRAPE_TAG2, 'N', CREATION_DTM FROM OPN_P_KW WHERE KEYID = NEWKID ;

CALL newPostWithMedia(tid, uuid, userKW, '', 'N', '', 'N') ;

/* 03/11/2019  Adding new users for the new KW - because we need at least 25-40 users in H and L in order to distribute the tagged posts  */

CALL ADD_NUSERS_4K1(NEWKID , ccode,  tid) ;

-- ADD_NUSERS_4K1 call added on 03/11/2019

-- CALL OPN_SCRAPE_DESIGN_GEN(tid, NEWKID, STAG24LLIST, userKW ) ;
END IF ;


END //
DELIMITER ;

-- 
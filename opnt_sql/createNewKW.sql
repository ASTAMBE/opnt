-- createNewKW

DELIMITER //
DROP PROCEDURE IF EXISTS createNewKW //
CREATE PROCEDURE createNewKW(entryKey varchar(15), tid INT, uuid varchar(45), pvtFlag varchar(3), userKW varchar(60), usercart varchar(3))
THISPROC: BEGIN

/*

	01/07/2021 AST: Initial Creation: This proc is to create new KWs withou the Add Users or Scrape Design. These KWs 
    Also these KWs will not have KW_TAGs
    
    CALL createNewKW('kwkwkw', 1, 'f7c02081-5f6e-11ea-82d4-06500c451eb8', 'N', 'Trump Supporters should be arrested', 'L') ;

 */

declare  orig_uid , NEWKID INT;
DECLARE UNAME, TNAME VARCHAR(30) ;
DECLARE STAG24LLIST VARCHAR(60) ;
DECLARE ccode VARCHAR(5) ;
DECLARE SUSP VARCHAR(5) ;

SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE THISPROC ;
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

CASE WHEN entryKey <> 'kalyan' THEN LEAVE THISPROC ;

WHEN entryKey = 'kalyan' THEN 

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE INTO orig_uid, UNAME, ccode FROM OPN_USERLIST OU WHERE OU.USER_UUID = uuid ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'createNewKW', CONCAT(tid, '-', userKW));


INSERT INTO OPN_P_KW(TOPICID, KEYWORDS, KW_TRIM, COUNTRY_CODE, DISPLAY_SEQ, CREATION_DTM
, LAST_UPDATE_DTM, CLUSTER_PRIO, ORIGIN_COUNTRY_CODE, NEW_KW_FLAG, SCRAPE_TAG1, SCRAPE_TAG2,
USER_CREATED_KW, CREATED_BY_UID, CREATED_BY_UUID, CREATED_BY_UNAME, CLEAN_KW_FLAG, PRIVATE_KW_FLAG)
VALUES (tid, userKW, CONCAT(UPPER(REPLACE(KEYWORDS, ' ', '') ), TOPICID) , ccode, 5, NOW(), NOW(), 5, ccode, 'N'
, UPPER(TNAME), CONCAT(LOWER(REPLACE(KEYWORDS, ' ', '') ),TOPICID), 'Y', orig_uid, uuid, UNAME, 'Y', pvtFlag ); 

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

END CASE ;
END IF ;


END //
DELIMITER ;

-- 
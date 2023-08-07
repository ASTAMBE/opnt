-- createBOTDiscussion

DELIMITER //
DROP PROCEDURE IF EXISTS createBOTDiscussion //
CREATE PROCEDURE createBOTDiscussion(CREATION_TYPE varchar(10), source_table varchar(50), source_row INT
, topicid INT, userid varchar(45), message varchar(2000)
, embedded_content varchar(1000), embedded_flag varchar(3) ,media_content varchar (500),media_flag varchar(3))
thisProc: BEGIN

/*   
08/06/2023 AST:Creating this proc to create discussion posts by BOTs.
 
*/

declare  orig_uid INT;
DECLARE UNAME,fromTable VARCHAR(30) ;
DECLARE CCODE, SUSPUSER VARCHAR(5) ;
DECLARE URL, newsTitle, newsExcrpt varchar(1000) ;

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE, OU.USER_SUSPEND_FLAG INTO orig_uid, UNAME, CCODE, SUSPUSER
FROM OPN_USERLIST OU WHERE OU.USER_UUID = userid ;

SET NAMES UTF8mb4;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'createBOTDiscussion', CONCAT(topicid,'-',CCODE));


/* end of use action tracking */

CASE WHEN SUSPUSER = 'Y' THEN LEAVE thisProc ;

WHEN SUSPUSER = 'N' THEN

CASE WHEN CREATION_TYPE = 'ORIG_POST' THEN

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG)
VALUES (topicid, NOW(), orig_uid, message, 'N'
, embedded_content, embedded_flag, CCODE, media_content, media_flag);

WHEN CREATION_TYPE = 'SCRAPE_TO_DISC' THEN

SET fromTable = source_table ;
SELECT NEWS_URL, NEWS_HEADLINE, 

END CASE ;

END; //
 DELIMITER ;
 
 -- 
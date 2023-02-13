-- newPostwithmedia

DELIMITER //
DROP PROCEDURE IF EXISTS newPostwithmedia //
CREATE PROCEDURE newPostwithmedia(topicid INT, userid varchar(45), message varchar(2000)
, embedded_content varchar(1000), embedded_flag varchar(3) -- , postor_country_code varchar(5)
,media_content varchar (500),media_flag varchar(3))
thisProc: BEGIN

/*   
05/10/2020 AST: Adding Comments for readability 
Also removing @ from local vars
Also Adding DEMO_POST_FLAG = 'N'

05/31/2020 AST:  Removing the postor_country_code from input params
08/11/2020 Kapil: Confirmed

 04/15/2021 AST: Adding code to disable the suspended user from using this proc
 
*/

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE, SUSPUSER VARCHAR(5) ;

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE, OU.USER_SUSPEND_FLAG INTO orig_uid, UNAME, CCODE, SUSPUSER
FROM OPN_USERLIST OU WHERE OU.USER_UUID = userid ;

SET NAMES UTF8mb4;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'newPostwithmedia', CONCAT(topicid,'-',CCODE));


/* end of use action tracking */

CASE WHEN SUSPUSER = 'Y' THEN LEAVE thisProc ;

WHEN SUSPUSER = 'N' THEN

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG)
VALUES (topicid, NOW(), orig_uid, message, 'N'
, embedded_content, embedded_flag, CCODE, media_content, media_flag);

END CASE ;

END; //
 DELIMITER ;
 
 -- 
-- userKWReport

 DELIMITER //
DROP PROCEDURE IF EXISTS userKWReport //
CREATE PROCEDURE userKWReport(uuid VARCHAR(45), TID INT, KID INT, userComment VARCHAR(40))
BEGIN

/* 07/27/2020 AST: Initial Creation - to allow users to report inappropriate keywords 
08/11/2020 Kapil: Confirmed
*/

DECLARE KW VARCHAR(150) ;
DECLARE UNAME VARCHAR(40) ;
DECLARE CCODE VARCHAR(5) ;
DECLARE UID INT;

SELECT USERID, USERNAME INTO UID, UNAME FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT KEYWORDS, COUNTRY_CODE INTO KW, CCODE FROM OPN_P_KW WHERE KEYID = KID ;

/* USER BHV SECTION */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, uuid, NOW(), 'userKWReport', CONCAT(KW,'-',userComment));

/* END OF USER BHV SECTION */

INSERT INTO OPN_USER_KW_REPORT(TOPICID, KEYID, KEYWORDS, REPORTED_UID, REPORTED_UUID
, REPORTED_UNAME, REPORT_DTM, REPORT_REASON, KW_CCODE)
VALUES(TID, KID, KW, UID, uuid
, UNAME, NOW(), userComment, CCODE) ;

END //
DELIMITER ;

-- 

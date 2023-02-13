-- userKWScreening

DELIMITER //
DROP PROCEDURE IF EXISTS userKWScreening //
CREATE PROCEDURE userKWScreening(tid INT, fromindex INT, toindex INT)
BEGIN

/*

02/01/2022 : Initial Creation AST: 

This script is created in order to bring all the new KWs created by users - to make them available for 
all - or to reject them. 

*/

DECLARE userKW VARCHAR(100) ;
DECLARE kwImageURL VARCHAR(1000) ;
DECLARE stCode VARCHAR(10) ;
DECLARE STCODENUM INT ;

SELECT K.TOPICID, K.KEYID, K.KEYWORDS, K.KW_IMAGE_URL, K.CREATION_DTM, U.USERNAME, U.USER_TYPE
FROM OPN_P_KW K, OPN_USERLIST U WHERE K.CREATED_BY_UID = U.USERID AND K.STATE_CODE IS NULL AND K.TOPICID = tid
AND K.CREATED_BY_UID IS NOT NULL ORDER BY K.CREATION_DTM DESC LIMIT fromindex, toindex ;


  
  
END; //
 DELIMITER ;
 
 -- 
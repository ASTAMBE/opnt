-- userKWApproval

DELIMITER //
DROP PROCEDURE IF EXISTS userKWApproval //
CREATE PROCEDURE userKWApproval(tid INT, kid INT, kw VARCHAR(100), KWImageURL VARCHAR(1000), regionCode VARCHAR(10))
BEGIN

/*

02/01/2022 : Initial Creation AST: 

This script is created in order to bring all the new KWs created by users - to make them available for 
all - or to reject them. 

Decisions Made currently: It is decided that the KW Tags for this keyword will not be changed thru the proc
If they need to be changed, they will be chnaged manually by me.
If this occurs too often then we will turn it into a part of this proc

*/

DECLARE KWTRIM VARCHAR(100) ;
DECLARE STCODENUM INT ;

SET STCODENUM = (SELECT IFNULL(REGION_ID, 1) FROM OPN_STATE_CODES WHERE REGION_CODE = regionCode) ;
SET KWTRIM = CONCAT(UPPER(REPLACE(KEYWORDS, ' ', '') ), tid) ;

UPDATE OPN_P_KW K SET KEYWORDS = kw, KW_TRIM = KWTRIM, KW_IMAGE_URL = KWImageURL
, STATE_CODE = STCODENUM, LAST_UPDATE_DTM = NOW(), APPROVED_FLAG = 'Y'
WHERE TOPICID = tid AND KEYID = kid ;


  
  
END; //
 DELIMITER ;
 
 -- 
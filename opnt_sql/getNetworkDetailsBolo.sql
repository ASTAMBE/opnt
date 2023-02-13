-- getNetworkDetailsBolo

DELIMITER //
DROP PROCEDURE IF EXISTS getNetworkDetailsBolo //
CREATE PROCEDURE getNetworkDetailsBolo(uc1 varchar(30), uc2 varchar(45), tid INT)
BEGIN

/*
05/12/2020 AST: Bringing SQL comments inside and removing @ from Vars
Also, removed the AND UC1.CART = UC2.CART restriction so that this proc also shows 
the opposite cart matches. uc2 is the logged in user. uc1 is the user whose cart
is matching and we only know his username.

07/09/2020 AST: Added MATCH_PERCENT, MDTM (Max DTM) to populate the new UI

08/11/2020 Kapil: Confirmed

 08/20/2020 AST: Added OPN_USERLIST.CHAT_FLAG to turn the chat icon on/off
		08/25/2020 AST: Changed the CHF logic to deal with U1 and U2 chat_flag values
        
        10/17/2021 AST: Modified for Bolo - filtering out Politics News KW with
        AND IFNULL(K1.NEWS_ONLY_FLAG, 'N') <> 'Y'

*/

declare  orig_uid2, orig_uid1, NUMR, DENOM, PRCNT INT;
DECLARE MDTM DATETIME ;
-- DECLARE CHF VARCHAR(3) ;
DECLARE UNAME VARCHAR(40) ;
-- DECLARE PRCNT DOUBLE ;

SET orig_uid1 = (SELECT  bringUseridFromUsername(uc1));

SELECT USERID, USERNAME INTO orig_uid2, UNAME FROM OPN_USERLIST WHERE USER_UUID = uc2 ;

/* USER BH LOG */

 INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
 VALUES(UNAME, orig_uid2, uc2, NOW(), 'getNetworkDetailsBolo', concat(orig_uid2, '-', uc1) );
 
 /* END USER BH LOG */

SET NUMR = (SELECT COUNT(1) FROM OPN_USER_CARTS UU1, OPN_USER_CARTS UU2
WHERE UU1.TOPICID = UU2.TOPICID AND UU1.KEYID = UU2.KEYID
AND UU2.USERID = orig_uid2 AND UU1.USERID = orig_uid1
AND UU1.TOPICID = tid ) ;

SELECT COUNT(1), MAX(LAST_UPDATE_DTM) INTO DENOM, MDTM FROM OPN_USER_CARTS UU3 
WHERE UU3.USERID = orig_uid2 AND UU3.TOPICID = tid ;

SELECT T1.TOPIC, UC1.CART, K2.KEYWORDS, ROUND(NUMR*100/DENOM, 0) MATCH_PERCENT, MDTM 
, CASE WHEN UL2.CHAT_FLAG = 'N' THEN 'N' ELSE UL1.CHAT_FLAG END CHF
FROM OPN_USER_CARTS UC1, OPN_TOPICS T1, OPN_P_KW K1, OPN_USERLIST UL1,
OPN_USER_CARTS UC2, OPN_TOPICS T2, OPN_P_KW K2, OPN_USERLIST UL2 
WHERE UC1.USERID = UL1.USERID
AND UC1.TOPICID = T1.TOPICID
AND UC1.KEYID = K1.KEYID
AND IFNULL(K1.NEWS_ONLY_FLAG, 'N') <> 'Y'
AND UC1.USERID = orig_uid1
AND UC1.TOPICID = tid
AND UC2.USERID = UL2.USERID
AND UC2.TOPICID = T2.TOPICID
AND UC2.KEYID = K2.KEYID
AND UC2.USERID = orig_uid2
-- AND UC1.CART = UC2.CART
AND UC1.KEYID = UC2.KEYID
ORDER BY UC1.TOPICID, UC1.CART DESC;

END //
DELIMITER ;

-- 
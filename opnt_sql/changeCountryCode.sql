-- changeCountryCode

 DELIMITER //
DROP PROCEDURE IF EXISTS changeCountryCode //
CREATE PROCEDURE changeCountryCode(userid varchar(45),country_code varchar(5))
BEGIN

/* 	08/09/2020 AST: Confirmed Version  */
/* 	08/14/2020 Kapil: Confirmed Version  */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('changeCountryCode', NOW(), 'UUID', userid);

UPDATE OPN_USERLIST U SET U.COUNTRY_CODE = country_code , U.P_Q_CHANGE_DT = NOW()
WHERE U.USER_UUID = userid AND U.USERID>0;

END //
DELIMITER ;

-- 
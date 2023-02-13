-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS saveDeviceToken //
CREATE PROCEDURE saveDeviceToken(UID varchar(45), dtoken varchar(200))
BEGIN

/*
 08/11/2020 Kapil: Confirmed
 */


UPDATE OPN_USERLIST SET IDENTIFIER_TOKEN = dtoken, ID_TOKEN_DTM = NOW()
WHERE USER_UUID = UID;

  
END //
DELIMITER ;

-- 
-- userLoginApp

 DELIMITER //
DROP PROCEDURE IF EXISTS userLoginApp //
CREATE PROCEDURE userLoginApp(username varchar(30), pwd varchar(20), device_serial VARCHAR(40))
BEGIN

/* 04012018 AST: Added insret into proc log 
08/11/2020 Kapil: Confirmed
*/

DECLARE UID INT;
DECLARE UUID VARCHAR(45);

SET UID = (SELECT OU.USERID FROM OPN_USERLIST OU WHERE UPPER(OU.USERNAME) = UPPER(username));
SET UUID = (SELECT OU.USER_UUID FROM OPN_USERLIST OU WHERE UPPER(OU.USERNAME) = UPPER(username));

INSERT INTO OPN_ULOGIN_HIST(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL)
VALUES(username, UID, UUID, NOW(), 'userLogin');

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(UID, UUID, NOW(), device_serial, 'Y');

SELECT -- U.USERID, 
U.USER_UUID USERID, U.COUNTRY_CODE  , doesCartExist(username) CARTORNOT
 from OPN_USERLIST U
 WHERE U.USERNAME = username  and AES_DECRYPT(U.password,'290317') = pwd;
 
 

END //
DELIMITER ;

-- 
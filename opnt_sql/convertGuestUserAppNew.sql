-- convertGuestUserAppNew

 DELIMITER //
DROP PROCEDURE IF EXISTS convertGuestUserAppNew //
CREATE PROCEDURE convertGuestUserAppNew(guestuuid varchar(45), newUName varchar(20), username varchar(100)
, userid varchar(60), dp_url VARCHAR(255),CONVERTTYPE VARCHAR(40))
thisproc:BEGIN
/* 	26/03/2020 Rohit: -Create this store proc to register the Guest user 
	to the data based on there register type like facebook or google
	there are two case one for fb and one for google 
	Call convertGuestUserAppNew("uuid","rohit","Androu7867","userid","dp_url","com.facebook");
	Return the created user list.

	07/09/2020 AST: Added handling of the case where guest user comes back again and again
    in order to circumvent the 5 profiles per FG id.

 */
DECLARE ISGUEST, USEREXISTS INT;
DECLARE status varchar(30);
SET status= "error";

SET ISGUEST = (SELECT COUNT(*) FROM OPN_USERLIST 
WHERE USER_UUID = guestuuid AND USER_TYPE = 'GUEST');

SET USEREXISTS = (SELECT COUNT(1) FROM OPN_USERLIST UU1 WHERE UU1.FB_USERID = userid 
OR UU1.G_USERID = userid OR UU1.A_USERID = userid) ;

CASE WHEN USEREXISTS > 0 THEN 

SELECT 'YES' existFlag ; LEAVE thisproc ;

WHEN USEREXISTS  = 0 THEN

CASE WHEN ISGUEST = 1 THEN

CASE WHEN CONVERTTYPE = 'com.facebook' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName, U.FB_USER_NAME =username
, U.FB_USER_FLAG= 'Y', U.FB_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;

WHEN CONVERTTYPE= 'com.google' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName,U.G_UNAME =username
,U.FB_USER_FLAG= 'G', U.G_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;

WHEN CONVERTTYPE= 'com.apple' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName,U.A_UNAME =username
,U.FB_USER_FLAG= 'A', U.A_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;
 
END CASE ;

SELECT U.USERNAME, U.USERID, U.USER_UUID, U.USER_TYPE, U.COUNTRY_CODE 
FROM OPN_USERLIST U WHERE U.USER_UUID = guestuuid;

WHEN ISGUEST = 0 THEN
SELECT status;
END CASE ;

END CASE ;

END //
DELIMITER ;

-- 

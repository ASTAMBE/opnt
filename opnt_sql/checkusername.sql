-- -- 

DELIMITER //
DROP PROCEDURE IF EXISTS checkusername //
CREATE PROCEDURE `checkusername`(uname varchar(30))
BEGIN

/* 26/03/2020 Rohit: -Create this store proc to find is there username available in the database
Call checkusername("rohit123");
Return 1 if already in use.
return 0 if available for use.

12/13/2020 AST CONFIRMED
    06/06/2025 AST: Adding the user bhv log
    
    */

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(uname, null, null, NOW(), 'checkusername', CONCAT('username passed = ', uname));

/* end of user action tracking */

SELECT COUNT(USERNAME) as count FROM OPN_USERLIST WHERE USERNAME= uname;

END //
DELIMITER ;

-- 
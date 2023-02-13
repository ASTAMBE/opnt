-- bringUsernameByUUID

DELIMITER //
DROP FUNCTION IF EXISTS bringUsernameByUUID //
CREATE FUNCTION bringUsernameByUUID(UserUUID VARCHAR(45)) RETURNS varchar(40)
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 SELECT bringUsernameByUUID(UserUUID VARCHAR(45)) */

  DECLARE uname varchar(40) ;

SET uname = (SELECT USERNAME FROM OPN_USERLIST WHERE USER_UUID = UserUUID);

  RETURN uname;
END;//

-- 
-- bringUserid

DELIMITER //
DROP FUNCTION IF EXISTS bringUserid //
CREATE FUNCTION bringUserid(UserUUID VARCHAR(45)) RETURNS INT
BEGIN

/* 04/25/2020 AST: Rebuilt: Removed the @ from the var Uuserid 
 SELECT bringUserid(UserUUID VARCHAR(45)) */

  DECLARE Uuserid INT ;

SET Uuserid = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USER_UUID = UserUUID);

  RETURN Uuserid;
  
END;//

-- 
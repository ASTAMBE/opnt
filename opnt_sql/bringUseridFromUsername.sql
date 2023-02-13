-- bringUseridFromUsername

DELIMITER //
DROP FUNCTION IF EXISTS bringUseridFromUsername //
CREATE FUNCTION bringUseridFromUsername(username VARCHAR(30)) RETURNS INT
BEGIN

/* 04/25/2020 AST: Rebuilt: Removed the @ from the var Uuserid 
 SELECT bringUseridFromUsername(username VARCHAR(30)) */

  DECLARE Uuserid INT ;

SET Uuserid = (SELECT OU.USERID FROM OPN_USERLIST OU 
WHERE UPPER(OU.USERNAME) = UPPER(username));

  RETURN Uuserid;
END;//

-- 
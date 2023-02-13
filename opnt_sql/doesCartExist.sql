-- doesCartExist

DELIMITER //
DROP FUNCTION IF EXISTS doesCartExist //
CREATE FUNCTION doesCartExist(username varchar(30)) RETURNS INT
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 SELECT doesCartExist(username varchar(30)) */

  DECLARE CARTEXIST INT ;

SET CARTEXIST =  (SELECT EXISTS (SELECT * FROM OPN_USER_CARTS 
 WHERE USERID = (SELECT OU.USERID FROM OPN_USERLIST OU 
 WHERE UPPER(OU.USERNAME) = UPPER(username))) CARTORNOT);
 
  RETURN CARTEXIST;
  
END;//

-- 
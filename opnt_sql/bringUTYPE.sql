-- bringUTYPE

DELIMITER //
DROP FUNCTION IF EXISTS bringUTYPE //
CREATE FUNCTION bringUTYPE(TBUID INT) RETURNS VARCHAR(10)
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 SELECT bringUTYPE(TBUID INT) 
 This function is not being called anywhere - hence deprecated */

  DECLARE UTYPE VARCHAR(10) ;

SET UTYPE := (SELECT USER_TYPE FROM OPN_USERLIST WHERE USERID = TBUID);

  RETURN UTYPE;
END;//

-- 


-- bringUsernameByUID

DELIMITER //
DROP FUNCTION IF EXISTS bringUsernameByUID //
CREATE FUNCTION bringUsernameByUID(UID INT) RETURNS varchar(40)
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 SELECT bringUsernameByUID(UID INT) */

  DECLARE uname varchar(40) ;

SET uname = (SELECT USERNAME FROM OPN_USERLIST WHERE USERID = UID);

  RETURN uname;
END;//

-- 
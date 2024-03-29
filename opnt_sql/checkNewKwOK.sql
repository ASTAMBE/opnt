-- checkNewKwOK

 DELIMITER //
DROP PROCEDURE IF EXISTS checkNewKwOK //
CREATE PROCEDURE checkNewKwOK(uuid VARCHAR(45), tid INT, userKW varchar(60))
THISPROC: BEGIN

/*
11/02/2018 AST: Adding check if the KW already exists in the TID

TBD: add a check that a user can add only 3 new KW per day
Also make sure that the user is not blacklisted
08/19/2020 Kapil: Confirmed

12/29/2020 AST: In order to handle the non-english chars, the VERBO needs to be 
used as IFNULL - so that the NULL does not fail the CASE statement.

*/


  DECLARE VPH, KWTRIM, VPHWILD VARCHAR(60);
  DECLARE VERBO, KWTIDEXISTS INT;
  DECLARE SUSP VARCHAR(5) ;
  /*
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT VERBOTEN_PHRASE FROM OPN_VERBOTEN;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO VPH;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      */
SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE 

SET KWTRIM = UPPER(removeAlpha(userKW)) ;
-- SET VPHWILD = CONCAT("'%", VPH, "%'") ;
SET VERBO = (SELECT IFNULL(MAX(INSTR(KWTRIM, VERBOTEN_PHRASE) ), 0) FROM OPN_VERBOTEN  );

SET KWTIDEXISTS = (SELECT COUNT(*) FROM OPN_P_KW WHERE TOPICID = tid AND UPPER(KEYWORDS) = UPPER(REPLACE(userKW, ' ', '') ) ) ;

CASE WHEN KWTIDEXISTS = 0 THEN 

CASE WHEN VERBO  = 0 THEN SELECT 1 CHKSTATUS;

-- INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
-- VALUES(bringUsernameByUUID(uuid), bringUserid(uuid), uuid, NOW(), 'checkNewKwOK', CONCAT(tid, '-', userKW));

-- LEAVE THISPROC;

WHEN VERBO > 0 THEN SELECT NULL CHKSTATUS;

-- INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
-- VALUES(bringUsernameByUUID(uuid), bringUserid(uuid), uuid, NOW(), 'checkNewKwOK', CONCAT(tid, '-', userKW));

END CASE ;

 WHEN KWTIDEXISTS > 0 THEN SELECT NULL CHKSTATUS;
 
 END CASE ;
 END IF ;

     --   END LOOP;
  -- CLOSE CURSOR_I;


END //
DELIMITER ;

-- 
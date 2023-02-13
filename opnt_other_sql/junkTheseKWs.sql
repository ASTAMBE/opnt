-- junkTheseKWs
 
 
DELIMITER //
DROP PROCEDURE IF EXISTS junkTheseKWs//
CREATE PROCEDURE junkTheseKWs(CCD VARCHAR(5), NUMDAYS INT, KCNT INT, CUTOFF INT)
thisproc: BEGIN

/* 05/15/2021 AST: This proc is created for junking useless keywords - based on certain criteria

-- ANy KW that has been created in the last 100 days and have no posts with that TAG1_KEYID
-- any KW with only a single word

*/

DECLARE TID, KID, TK1C INT ;
DECLARE KW, STAG2 VARCHAR(100) ;

  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT TOPICID, KEYID, KEYWORDS, SCRAPE_TAG2, bringTK1Count(KEYID) 
  FROM OPN_P_KW WHERE COUNTRY_CODE = CCD AND CREATION_DTM > CURRENT_DATE() - INTERVAL NUMDAYS DAY 
  AND bringTK1Count(KEYID) < CUTOFF
  ORDER BY bringTK1Count(KEYID) LIMIT KCNT;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO TID, KID, KW, STAG2, TK1C;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      

CALL changeScrapeDesign(TID, KID, KW, STAG2, 'N','', '', '', '', '', '', '', '', '' ) ;

        END LOOP;
  CLOSE CURSOR_I;



  
END; //
 DELIMITER ;
 
 -- 
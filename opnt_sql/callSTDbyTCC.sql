-- callSTDbyTCC

DELIMITER $$
DROP PROCEDURE IF EXISTS callSTDbyTCC $$
CREATE PROCEDURE `callSTDbyTCC`(tid INT, tcc varchar(5))
thisproc:BEGIN

 /* 	02/28/2025 AST: This proc is for calling the createTCCDiscussion for the TCC that are being handled by OpenAI
		- Read from OPN_SFC_CONTENT for the specific TCC + INTEREST combination where CONVERTED_POST_ID  is null
        - For each row, call createTCCDiscussion: This will create a new discussion and the associated comments
        - There is no need for scr_tpc or howMany -> convert all the SFC rows for the TCC + INT combo
 */
    
       DECLARE NURL, NTITLE, NEXCRPT TEXT;
       DECLARE SCR_SRC VARCHAR(15) ;
  declare RID, UCNT INT;
  
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR SELECT ROW_ID FROM OPN_SFC_CONTENT WHERE TRUE_COUNTRY_CODE = tcc AND TOPICID = tid 
  -- AND CONTENT_DTM > NOW() - INTERVAL 48 HOUR 
  AND IFNULL(CONVERTED_POST_ID, 0) = 0 -- ORDER BY RAND() LIMIT 5 
  ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO RID ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
CALL createTCCDiscussion(RID) ;

        END LOOP;
  CLOSE CURSOR_I;
  
-- UPDATE WEB_SCRAPE_RAW_L SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOD(ROW_ID, 2) = 0 ORDER BY RAND() LIMIT 2 ;
  
END$$
DELIMITER ;

-- 

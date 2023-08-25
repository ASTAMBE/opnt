 -- callSTDbyIntCcode

 DELIMITER //
DROP PROCEDURE IF EXISTS callSTDbyIntCcode //
CREATE PROCEDURE callSTDbyIntCcode(tid INT, ccode varchar(5), scr_tpc varchar(15) , howMany INT)
thisproc:BEGIN

 /* 	08/18/2023 AST: This proc is for calling the createBOTDiscussion for the existing interest*Ccode combinations
		It will have SCRAPE_SOURCE specific handling to deal with the known idiosyncrasies of sources
		howMany is the number of discussions you want to create by calling this proc. This should be based on a
        visual inspection of how many scrapes are there for this interest*ccode combo
 */
    
       DECLARE NURL, NTITLE, NEXCRPT TEXT;
       DECLARE SCR_SRC VARCHAR(15) ;
  declare RID, UCNT INT;
  
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR SELECT ROW_ID, SCRAPE_SOURCE FROM opntprod.WEB_SCRAPE_RAW_L 
  WHERE COUNTRY_CODE = ccode AND SCRAPE_TOPIC = scr_tpc  ORDER BY RAND() LIMIT howMany ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO RID, SCR_SRC ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
CALL createBOTDiscussion('SCRAPE_TO_DISC', RID, ccode, 'L' , tid, '','' , '','') ;

        END LOOP;
  CLOSE CURSOR_I;
  
-- UPDATE WEB_SCRAPE_RAW_L SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOD(ROW_ID, 2) = 0 ORDER BY RAND() LIMIT 2 ;
  
END

; //
 DELIMITER ;
 
 -- 
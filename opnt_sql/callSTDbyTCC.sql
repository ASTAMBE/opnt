DELIMITER $$
DROP PROCEDURE IF EXISTS callSTDbyTCC $$
CREATE PROCEDURE `callSTDbyTCC`(tid INT, tcc VARCHAR(5))
thisproc: BEGIN

  DECLARE NURL, NTITLE, NEXCRPT TEXT;
  DECLARE SCR_SRC VARCHAR(15);
  DECLARE RID, UCNT INT;
  DECLARE DONE INT DEFAULT FALSE;
  
  DECLARE CURSOR_I CURSOR FOR 
    SELECT ROW_ID 
    FROM OPN_SFC_CONTENT 
    WHERE TRUE_COUNTRY_CODE = tcc 
      AND TOPICID = tid 
      AND CONVERTED_POST_ID IS NULL;
  
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;

  -- Step 1: Deduplicate rows for the specific (tid, tcc) combo where CONVERTED_POST_ID is NULL
  WITH cte AS (
    SELECT 
      ROW_ID,
      ROW_NUMBER() OVER (
        PARTITION BY CONTENT_URL 
        ORDER BY CONTENT_DTM DESC, ROW_ID DESC
      ) AS rn
    FROM OPN_SFC_CONTENT
    WHERE TRUE_COUNTRY_CODE = tcc  -- Scope to input TCC
      AND TOPICID = tid            -- Scope to input TOPICID
      --  AND CONVERTED_POST_ID IS NULL -- Only process unprocessed rows
  )
  DELETE FROM OPN_SFC_CONTENT
  WHERE ROW_ID IN (
    SELECT ROW_ID FROM cte WHERE rn > 1
  );
  
-- step 1.5: Delete the rows that have already been converted to KW's in previous days - because the scrapers often bring the same items in later days

DELETE FROM OPN_SFC_CONTENT WHERE CONVERTED_POST_ID IS NULL AND CONTENT_TITLE IN (SELECT KEYWORDS FROM OPN_P_KW WHERE CREATION_DTM > CURRENT_DATE() - INTERVAL 30 DAY) ;

  -- Step 2:  Process remaining rows 
  
  OPEN CURSOR_I;
  READ_LOOP: LOOP
    FETCH CURSOR_I INTO RID;
    IF DONE THEN
      LEAVE READ_LOOP;
    END IF;
    CALL createTCCDiscussion(RID);
  END LOOP;
  CLOSE CURSOR_I;

END$$
DELIMITER ;
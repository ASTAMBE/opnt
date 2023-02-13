-- postSkipScore

DELIMITER $$ 
DROP FUNCTION IF EXISTS postSkipScore $$
CREATE FUNCTION postSkipScore(PCON VARCHAR(1000)) RETURNS DECIMAL(6,2)
 thisproc: BEGIN
 /*
 
	12/22/2021 AST: This function gives 2 score for each skip word used in a post. The idea is: The skip words
    such as my, is, it, but, as etc. actually indicate a thoughtful post rather than random typing.
    The postSkipScore will be combined with other scoring techniques - such as one point for each word,
    negative points for F words, total length of the post etc.
    If the postSkipScore is zero then even if the total word and char scores are high, we may flag it as low quality
 
 */
DECLARE CNTR, SKPTOT, MATCHCNT, WORDCNT INT DEFAULT 0 ;
DECLARE SKIPWORD, CHKWORD VARCHAR(10) ;
  -- SET CNTR, MATCHCNT = 0;
  SET SKPTOT = (SELECT COUNT(1) FROM OPN_SKIP_WORDS) ;
  -- SET WORDCNT = (SELECT wordCount(PCON)) ;
  thisloop: LOOP
    SET CNTR = CNTR +1;
    select CONCAT(' ', SKIP_WORD, ' ') INTO CHKWORD from OPN_SKIP_WORDS WHERE ROW_ID = CNTR ;
    
    -- IF PCON LIKE CHKWORD THEN SET MATCHCNT = MATCHCNT + 1 ;
    SET MATCHCNT = MATCHCNT + ((LENGTH(UPPER(PCON)) - LENGTH(REPLACE(UPPER(PCON), CHKWORD, '')))/LENGTH(CHKWORD) )  ;
    -- SELECT GOODWORD ;
    -- END IF;
    IF CNTR = SKPTOT THEN LEAVE thisloop;
    END IF ;
 END LOOP thisloop;
-- RETURN ROUND(WORDCNT/MATCHCNT, 2) ;
RETURN MATCHCNT ;
END $$
DELIMITER ;

-- End of postSkipScore

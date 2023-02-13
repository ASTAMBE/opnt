-- callRetagPost
 
 
DELIMITER //
DROP PROCEDURE IF EXISTS callRetagPost //
CREATE PROCEDURE callRetagPost(TPCID INT, CCD VARCHAR(5), oldtag INT, PCNT INT)
thisproc: BEGIN

/* 05/15/2021 AST: This proc is created for re-tagging the posts that have been wrongly tagged due to faulty scrape designs
We will create a cursor for L1-L6 and NL1-NL3 - with DESC order of OPN_KW_TAGS.SCRAPE_DESIGN_DTM for the TID of the postid
Then we will check for match with each set with the post_content. 
If we find a match (and no match with NL1-NL3) then we will take that KID and use it as the new TAG1_KEYID

*/

DECLARE PID, TK1 INT ;
DECLARE CCD VARCHAR(5) ;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT POST_ID, TAG1_KEYID FROM OPN_POSTS_RAW WHERE TOPICID = TPCID
  AND POSTOR_COUNTRY_CODE = CCD AND TAG1_KEYID = oldtag ORDER BY POST_ID DESC LIMIT PCNT ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO PID, TK1  ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
CALL retagPost(PID, TPCID, CCD, oldtag) ;

        END LOOP;
  CLOSE CURSOR_I;
END; //
 DELIMITER ;
 
 -- 
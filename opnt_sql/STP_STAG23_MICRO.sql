-- STP_STAG23_MICRO

DELIMITER //
DROP PROCEDURE IF EXISTS STP_STAG23_MICRO //
CREATE PROCEDURE STP_STAG23_MICRO( STAG2V VARCHAR(50), STAG3V VARCHAR(50))
thisProc: BEGIN
  DECLARE SCRAPEID, PBUID, PBUID2, KID, TID, USERCNT, SCRAPECNT INT;
  DECLARE SCRAPEURL, URLTITLE VARCHAR(1000);
  DECLARE CCODE VARCHAR(5);
  DECLARE SCRPTPC VARCHAR(30) ;
  DECLARE SCRDATE DATE ;

/* 07/01/2020 AST:

	Rebuilding this very important proc.
    
    This proc is the main culmination of the entire STP Engine. Every STP script and 
    the critical OPN_UKW_TAGGING finally culminates into this proc call
    
    Problem Statement: The problem is that a globally relevant KW, such as 'coronavirus' 
    Why is it a problem: This KW was created by a user with IND ccode. Hence no USA 
    BOT users have been assigned this KW in their cart. But lots of USA users can be 
    expected to add it to their carts. But they will not get any news items because
    no USA BOTs have it.
    
    This requires a 2-step solution:
    
    Step 1: Fix the ADD_NUSERS_4K1 proc. Currently it inserts KW in only matching ccode users
    Make it so that it will also add users for the remaining 2 ccodes,
    Impact: If the KW is truly global then the scrapes will find enough links to create posts
    for all ccodes.
    If the KW is not really global, for ex. a mainly IND kw - such as 'COVID HANDLING IN MUMBAI',
    there won't be many scrapes from USA websites. When STP tries to push scrapes to USA BOTs,
    it will not find any scrapes to do so. No harm in that.
    
    Step 2: Then fix this proc (STP_STAG23_MICRO) - Turning around this proc completely.
    Instead of cursor being the userid, it should be the scrape_id - and find users to 
    push the scrape as a post from.
    
    07/06/2020 AST: Added condition handling for NULL PBUID
    
    07/07/2020 AST: Added URL_TITLE to the cursor and INSERT
    
    09/05/2020 AST: confirmed

*/

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR 
  SELECT W.ROW_ID, IFNULL(STR_TO_DATE(W.NEWS_DATE, '%Y-%m-%d'), W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 999) NEWS_URL, W.NEWS_HEADLINE, W.COUNTRY_CODE, K.KEYID, K.TOPICID
  FROM WEB_SCRAPE_RAW W, OPN_P_KW K
  WHERE W.SCRAPE_TAG2 = K.SCRAPE_TAG2 AND W.MOVED_TO_POST_FLAG = 'N' AND W.TAG_DONE_FLAG = 'Y'
  AND W.SCRAPE_TAG2 = STAG2V AND W.SCRAPE_TAG3 = STAG3V  ;


   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO SCRAPEID, SCRDATE, SCRPTPC, SCRAPEURL, URLTITLE, CCODE, KID, TID ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
      /*
SET USERCNT = (SELECT COUNT(DISTINCT C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE) ;

SET SCRAPECNT = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW WHERE SCRAPE_TAG2 = STAG2V AND SCRAPE_TAG3 = STAG3V 
AND MOVED_TO_POST_FLAG = 'N' AND TAG_DONE_FLAG = 'Y') ;

CASE WHEN USERCNT <= SCRAPECNT * 0.2 THEN

CALL ADD_NUSERS_4K1(KID, CCODE, TID) ; END CASE ;
*/

SET PBUID = (SELECT DISTINCT C.USERID FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.CART = STAG3V AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE 
AND U1.BOT_FLAG = 'Y' ORDER BY RAND() LIMIT 1)  ;

CASE WHEN PBUID IS NOT NULL THEN 

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, TAG1_KEYID, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID, SCRAPEURL, 'Y', '', 'N', CCODE, SCRAPEID, URLTITLE, KID, 'STP_STAG23_MICRO', '', 'N');

  UPDATE WEB_SCRAPE_RAW SET MOVED_TO_POST_FLAG = 'Y' WHERE ROW_ID = SCRAPEID ;
  
  WHEN PBUID IS NULL THEN 
  
  CALL ADD_NUSERS_4K1(KID, CCODE, TID) ; 
  
  SET PBUID2 = (SELECT DISTINCT C.USERID FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.CART = STAG3V AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE 
AND U1.BOT_FLAG = 'Y' ORDER BY RAND() LIMIT 1)  ;
  
  INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, TAG1_KEYID, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID2, SCRAPEURL, 'Y', '', 'N', CCODE, SCRAPEID, URLTITLE, KID, 'STP_STAG23_MICRO', '', 'N');

  UPDATE WEB_SCRAPE_RAW SET MOVED_TO_POST_FLAG = 'Y' WHERE ROW_ID = SCRAPEID ;
 
  LEAVE thisProc ;

 end case ;
 
        END LOOP;
  CLOSE CURSOR_I;
 
END

; //
 DELIMITER ;
 
 -- END OF STP_STAG23_MICRO

 -- 
-- STP_REMAINDER

DELIMITER //
DROP PROCEDURE IF EXISTS STP_REMAINDER //
CREATE PROCEDURE STP_REMAINDER(interest VARCHAR(25), TID INT, ccode VARCHAR(5), numdays INT, scrcount INT)
thisProc: BEGIN
  DECLARE SCRAPEID, PBUID, PBUID2, KID, USERCNT, SCRAPECNT, UNTAG_CNT INT;
  DECLARE SCRAPEURL, URLTITLE, NEWSDESC VARCHAR(1000);
  DECLARE CCODEVAR VARCHAR(5) ;
  DECLARE SCRPTPC VARCHAR(30) ;
  DECLARE SCRDATE DATETIME ;

/* 06/18/2024 AST: Adding the logic to take the last n days and counts as per the param
Also fixing the issue where the cursor brings nothing - due to the absence of IFNULL
for the W.MOVED_TO_POST_FLAG

06/18/2023 AST:
Reason: When the current STP process is completed, a large number of scrapes get swept into the WSR_UNTAGGED table
because the news items do not have any good tags that can be associated with the existing UKW tagging or the 
carefully built IND/USA/GGG tagging and STP infra (as the KWs and tagging has not kept pace with the news).
Currently only a small portion of this untagged news gets distributed as STP through the STP_GRAND_XYZNEWS. 
This proc will convert all the remaining (untagged) scrapes into posts and assign it to a carefully designed
random selection of users.

Purpose: 1. To convert the untagged scrapes into posts and slot them into well-designed USERID selections
2. To prepare the ground for automating the showInitialKWs proc - so that the latest news scrapes will 
automatically start appearing in the showInitialKWs

PreReq: In order to make this proc work, first the ADD_NUSERS_4K1 had to be added to the convertPostToKW
proc - only for the portion which actually converts the Post to KW. SO that enough recipients of the untagged 
scrapes can be pre-populated. 
Why? Because it makes sense to distribute to untagged STP into users who have had RECENT interactions in terms of
subscribing to the recently added KWs. If this is not done, then the STP will be done to those bots that have had 
only old KWs subscriptions.

Method: Create a cursor of the UNTAGGED news - before the scrapes are swept into the WSR_UNTAGGED. 
Then find the USERIDs that have had the most recent cart additions for the same interest and country code.
Then start converting each cursor row to post for each of these users - by using the order by rand() limit 1

This proc will need to be called in each of the STP processes - just before the sweeping into WSR_UNTAGGED
	

*/

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR 
  SELECT W.ROW_ID, IFNULL(STR_TO_DATE(W.NEWS_DATE, '%b %d, %Y %H:%i:%s'), W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 499) NEWS_URL, SUBSTR(W.NEWS_HEADLINE, 1, 499) NEWS_HEADLINE
  , SUBSTR(W.NEWS_EXCERPT, 1, 499) NEWS_EXCERPT, W.COUNTRY_CODE 
  FROM WEB_SCRAPE_RAW W
  WHERE W.SCRAPE_TOPIC = interest AND IFNULL(W.MOVED_TO_POST_FLAG, 'N') = 'N' AND W.COUNTRY_CODE = ccode
  AND IFNULL(NEWS_DATE, SCRAPE_DATE) IS NOT NULL 
  AND IFNULL(STR_TO_DATE(W.NEWS_DATE, '%b %d, %Y %H:%i:%s'), SCRAPE_DATE) 
  > CURRENT_DATE() - INTERVAL numdays DAY LIMIT scrcount ;


   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO SCRAPEID, SCRDATE, SCRPTPC, SCRAPEURL, URLTITLE, NEWSDESC, CCODEVAR ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

/*
SET UNTAG_CNT = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW W   WHERE W.SCRAPE_TOPIC = interest AND W.COUNTRY_CODE = CCODEVAR 
AND W.MOVED_TO_POST_FLAG = 'N' )*2 ; 
06/20/2024 ast: Originally the PBUID below was selected using a more complex logic - in order to take the most recent
cart additions among the BOT users. But that would take 3-5 sec per PBUID generation - resulting into several
minutes for this proc.

Hence now we are doing the easier - more random - not ordered by the latest cart changes - PBUID gen.

Also, we are going to use this proc to generate Posts (news items) as well as Discussions. 

This will be done by just checking if the SCRAPEID is even then Discussion, if odd then post 
*/

SET PBUID = (SELECT DISTINCT C.USERID FROM OPN_USER_CARTS C, OPN_USERLIST U WHERE C.TOPICID = TID
AND C.USERID = U.USERID AND U.COUNTRY_CODE = CCODEVAR  AND U.BOT_FLAG = 'Y' ORDER BY RAND() LIMIT 1)  ;

CASE WHEN SCRAPEID % 2 = 0 THEN 

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, URL_EXCERPT, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID, SCRAPEURL, 'N', '', 'N', CCODEVAR, SCRAPEID, URLTITLE, NEWSDESC
, 'STP_REMAINDER', '', 'N');

ELSE 

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, URL_EXCERPT, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID, SCRAPEURL, 'Y', '', 'N', CCODEVAR, SCRAPEID, URLTITLE, NEWSDESC
, 'STP_REMAINDER', '', 'N');

END CASE ;

	INSERT INTO WSR_CONVERTED
  UPDATE WEB_SCRAPE_RAW SET MOVED_TO_POST_FLAG = 'Y' WHERE ROW_ID = SCRAPEID ;
 
        END LOOP;
  CLOSE CURSOR_I;
 
END

; //
 DELIMITER ;
 
 -- END OF STP_STAG23_MICRO

 -- 
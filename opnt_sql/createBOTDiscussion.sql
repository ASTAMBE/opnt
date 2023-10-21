-- createBOTDiscussion

DELIMITER //
DROP PROCEDURE IF EXISTS createBOTDiscussion //
CREATE PROCEDURE createBOTDiscussion(CREATION_TYPE varchar(40), source_row_id INT, country_code VARCHAR(5), CARTVAL VARCHAR(3),
tid INT, message varchar(2000) , embedded_content varchar(1000), cmnt1 varchar(2000), cmnt2 varchar(2000) -- , minExistsUsers INT
)
thisProc: BEGIN

/*   
08/06/2023 AST:Creating this proc to create discussion posts by BOTs.
 08/14/2023 AST: Made small changes - like ccode lowercase and source_row -> source_row_id
 
 08/16/2023 AST: Adding the post STD sweep to WSR _CONVERTED by adding scr_src (scrape_source)
 
 08/19/2023 AST: Adding the minExistsUsers param to control how many minimum number of KWs of 
 the specific topicid should be in the users existing carts. Default is 10 - but for CELEB and ENT
we have to do 3 for now.
ALSO: Added the STD_ONLY_DISC case to create discussions that look like STP posts with previews.

08/23/2023 AST: Re-building the UID selector to use OPN_MAIN_BOTS. And removing the minExistsUsers param

08/25/2023 AST: Added logic to avoid running into duplicate KW if the cursor brings a scrape that has
been already converted into a KW. This could happen due to the repetition of news in the scrapes.

09/17/2023 AST: Adding the source table (WEB_SCRAPE_RAW_L, WEB_SCRAPE_RAW) so that the same STD process
can be used on the regular scrapes also.

10/10/2023 AST: Changing the SCRAPE_TO_DISC --> instead of the Comment1 getting the news URL, the post 
(discussion) itself will get the news_url. This is because we want to change the way the showInitialKWs 
is shown on the screen - we want more visually attractive popup screen. This will require the image.

10/20/2023 Adding SCRAPE_SOURCE and SCRAPE_TYPE to the INSERT into POST statement
Also addi8ng URL_TITLE  to the insert - this is because it gets used in the post search proc
*/

declare  orig_uid, MATCHKID, POSTID, CBYUID1, CBYUID2, KWEXIST INT;
DECLARE UNAME,fromTable, COMMENTER1, COMMENTER2, scr_src, scr_topic, scr_type VARCHAR(30) ;
DECLARE UUID VARCHAR(50) ;
DECLARE SUSPUSER, LIKECODE VARCHAR(5) ;
DECLARE URL, newsTitle, newsExcrpt varchar(1000) ;

/*
SET MATCHKID = (SELECT CASE WHEN tid = 1 then 105087
WHEN tid = 2 THEN 105654
WHEN tid = 3 THEN 105108
WHEN tid = 4 THEN 105653 
WHEN tid = 5 THEN 105655
WHEN tid = 8 THEN 80005
WHEN tid = 10 AND country_code = 'IND' THEN 105088
WHEN tid = 10 AND country_code <> 'IND' THEN 105089 END ) ; */

SET LIKECODE = (SELECT CASE WHEN CARTVAL = 'L' THEN 'L1' ELSE 'H1' END) ;

SELECT USERID, USERNAME, USER_UUID INTO orig_uid, UNAME, UUID FROM OPN_MAIN_BOTS 
WHERE CCODE = country_code AND TOPICID = tid ORDER BY RAND() LIMIT 1 ;

-- SELECT UNAME ;

-- LEAVE thisProc ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, UUID, NOW(), 'createBOTDiscussion', CONCAT(tid,'-',country_code));

/* end of use action tracking */

CASE WHEN CREATION_TYPE = 'ORIG_DISCUSSION' THEN

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG, STP_PROC_NAME)
VALUES (tid, NOW(), orig_uid, message, 'N', '', 'N', country_code, '', 'N', 'ORIG_DISCUSSION');

SELECT MAX(POST_ID) INTO POSTID FROM OPN_POSTS WHERE POST_BY_USERID = orig_uid AND STP_PROC_NAME = 'ORIG_DISCUSSION'
AND POST_CONTENT = message ;

CALL userActionCommon(UUID, 'POST', 'L1', POSTID) ;

SELECT USERID, USERNAME INTO CBYUID1, COMMENTER1 FROM OPN_MAIN_BOTS 
WHERE CCODE = country_code AND TOPICID = tid  ORDER BY RAND() LIMIT 1 ;

SELECT USERID, USERNAME INTO CBYUID2, COMMENTER2 FROM OPN_MAIN_BOTS 
WHERE CCODE = country_code AND TOPICID = tid  ORDER BY RAND() LIMIT 1 ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(POSTID, orig_uid, tid, 1, cmnt1, CBYUID1, COMMENTER1
, cmnt1, CBYUID1, COMMENTER1, ''
, 'N', NOW()
, now(), '', 'N', 'CONP', '', 'N');

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(POSTID, orig_uid, tid, 1, cmnt2, CBYUID2, COMMENTER2
, cmnt2, CBYUID2, COMMENTER2, ''
, 'N', NOW()
, now(), '', 'N', 'CONP', '', 'N');

WHEN CREATION_TYPE = 'SCRAPE_TO_DISC' THEN

SELECT NEWS_URL, NEWS_HEADLINE, 	IFNULL(NEWS_EXCERPT, "This is a great discussion. I agree with it in principle. Will post more comments shortly")
, SCRAPE_SOURCE, SCRAPE_TOPIC, IFNULL(NEWS_TAGS, 'PYSCRAPE') into URL, newsTitle, newsExcrpt, scr_src, scr_topic, scr_type
FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

SET KWEXIST = (SELECT COUNT(1) FROM OPN_P_KW WHERE TOPICID = tid AND KEYWORDS LIKE CONCAT(SUBSTR(newsTitle, 1, 150), '%') );

CASE WHEN KWEXIST = 0 THEN 

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG, URL_TITLE, URL_EXCERPT
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG, STP_PROC_NAME, SCRAPE_SOURCE, SCRAPE_TYPE)
VALUES (tid, NOW(), orig_uid, URL, 'N',newsTitle, newsExcrpt, '', 'N', country_code, '', 'N', 'SCRAPE_TO_DISC', scr_src, scr_type);

SELECT MAX(POST_ID) INTO POSTID FROM OPN_POSTS WHERE POST_BY_USERID = orig_uid AND STP_PROC_NAME = 'SCRAPE_TO_DISC'
AND POST_CONTENT = URL ;

CALL userActionCommon(UUID, 'POST', LIKECODE, POSTID) ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(POSTID, orig_uid, tid, 1, URL, orig_uid, UNAME
, newsTitle, orig_uid, UNAME, ''
, 'N', NOW()
, now(), '', 'N', 'CONP', '', 'N');

SELECT USERID, USERNAME INTO CBYUID1, COMMENTER1 FROM OPN_MAIN_BOTS 
WHERE CCODE = country_code AND TOPICID = tid  ORDER BY RAND() LIMIT 1 ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(POSTID, orig_uid, tid, 1, newsExcrpt, CBYUID1, COMMENTER1
, newsExcrpt, CBYUID1, COMMENTER1, ''
, 'N', NOW()
, now(), '', 'N', 'CONP', '', 'N');

INSERT INTO WSR_CONVERTED(SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, COUNTRY_CODE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_TAG1, STP_PROCESS, NEWS_TAGS) 
VALUES(CURRENT_DATE(), scr_src, scr_topic, country_code, URL, newsTitle, newsExcrpt
, CONCAT('POST_ID=', POSTID, ' PBUID=', orig_uid, ' CBYUID=', CBYUID1), 'SCRAPE_TO_DISC', 'PYSCRAPE') ;

DELETE FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

WHEN KWEXIST > 0 THEN 

INSERT INTO WSR_CONVERTED(SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, COUNTRY_CODE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_TAG1, STP_PROCESS) 
VALUES(CURRENT_DATE(), scr_src, scr_topic, country_code, URL, newsTitle, newsExcrpt
, CONCAT('POST_ID=', POSTID, ' PBUID=', orig_uid, ' CBYUID=', CBYUID1), 'STD_DUPE_REJECT') ;

DELETE FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;
LEAVE thisproc ;

END CASE ;

WHEN CREATION_TYPE = 'STD_NO_EXCRPT' THEN

SELECT NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_SOURCE, SCRAPE_TOPIC, IFNULL(NEWS_TAGS, 'PYSCRAPE')
into URL, newsTitle, newsExcrpt, scr_src, scr_topic, scr_type
FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG, URL_TITLE, URL_EXCERPT
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG, STP_PROC_NAME, SCRAPE_SOURCE, SCRAPE_TYPE)
VALUES (tid, NOW(), orig_uid, newsTitle, 'N',newsTitle, newsExcrpt, '', 'N', country_code, '', 'N', 'STD_NO_EXCRPT', scr_src, scr_type);

SELECT MAX(POST_ID) INTO POSTID FROM OPN_POSTS WHERE POST_BY_USERID = orig_uid AND STP_PROC_NAME = 'STD_NO_EXCRPT'
AND POST_CONTENT = newsTitle ;

CALL userActionCommon(UUID, 'POST', LIKECODE, POSTID) ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(POSTID, orig_uid, tid, 1, URL, orig_uid, UNAME
, URL, orig_uid, UNAME, ''
, 'N', NOW()
, now(), '', 'N', 'CONP', '', 'N');

INSERT INTO WSR_CONVERTED(SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, COUNTRY_CODE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_TAG1, STP_PROCESS) 
VALUES(CURRENT_DATE(), scr_src, scr_topic, country_code, URL, newsTitle, newsExcrpt, CONCAT('POST_ID=', POSTID, ' PBUID=', orig_uid), 'STD_NO_EXCRPT') ;

DELETE FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

WHEN CREATION_TYPE = 'STD_ONLY_DISC' THEN

SELECT NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_SOURCE, SCRAPE_TOPIC into URL, newsTitle, newsExcrpt, scr_src, scr_topic 
FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG, STP_PROC_NAME)
VALUES (tid, NOW(), orig_uid, URL, 'N', '', 'N', country_code, '', 'N', 'STD_ONLY_DISC');

SELECT MAX(POST_ID) INTO POSTID FROM OPN_POSTS WHERE POST_BY_USERID = orig_uid AND STP_PROC_NAME = 'STD_ONLY_DISC'
AND POST_CONTENT = URL ;

CALL userActionCommon(UUID, 'POST', LIKECODE, POSTID) ;

INSERT INTO WSR_CONVERTED(SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, COUNTRY_CODE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT, SCRAPE_TAG1, STP_PROCESS) 
VALUES(CURRENT_DATE(), scr_src, scr_topic, country_code, URL, newsTitle, newsExcrpt, CONCAT('POST_ID=', POSTID, ' PBUID=', orig_uid), 'STD_ONLY_DISC') ;

DELETE FROM WEB_SCRAPE_RAW_L WHERE ROW_ID = source_row_id ;

END CASE ;

END; //
 DELIMITER ;
 
 -- 
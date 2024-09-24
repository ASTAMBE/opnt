
-- WSRL_DEDUPE_ALL

 DELIMITER //
DROP PROCEDURE IF EXISTS WSRL_DEDUPE_ALL //
CREATE PROCEDURE WSRL_DEDUPE_ALL()
thisProc: BEGIN

/* 10/15/2020 AST: Confirmed  

	09/23/2024 AST: Changing this proc completely to handle the dedupe in a single shot and also dedupe from the previous posts 
    The previous posts will be stored for 30 days in the OPN_30DAYS_POST_CONTENT table.
    After the dedupe is complete, it will insert the deduped URLs into OPN_30DAYS_POST_CONTENT and delete data > 30 days old)
    Then it will load back into WSRL and delete from WEB_SCRAPE_DEDUPE table

*/

-- Step 1: Takes the MAX(ROW_ID) for each URL and joins back on that with WSRL to get a single row for each scrape URL

INSERT INTO WEB_SCRAPE_DEDUPE(ROW_ID, SCRAPE_DATE, NEWS_DTM_RAW, NEWS_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT
, MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3, TAG_DONE_FLAG) 
SELECT ROW_ID, SCRAPE_DATE, NEWS_DTM_RAW, NEWS_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT
, 'N' MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3, 'N' TAG_DONE_FLAG FROM (
SELECT W.ROW_ID, W.NEWS_URL, W.NEWS_PIC_URL, W.NEWS_HEADLINE, W.NEWS_EXCERPT, W.SCRAPE_SOURCE, W.SCRAPE_TOPIC, W.NEWS_TAGS
,W.SCRAPE_DATE, W.NEWS_DTM_RAW, NEWS_DATE, W.COUNTRY_CODE, W.SCRAPE_TAG1, W.SCRAPE_TAG2, W.SCRAPE_TAG3 
FROM WEB_SCRAPE_RAW_L W,  (SELECT NEWS_URL, MAX(ROW_ID) MAXID FROM WEB_SCRAPE_RAW_L GROUP BY NEWS_URL) G1
WHERE W.ROW_ID = G1.MAXID)D ;

-- Step 2: Dedupes by using OPN_30DAYS_POST_CONTENT

DELETE FROM WEB_SCRAPE_DEDUPE WHERE NEWS_URL IN (SELECT POST_CONTENT FROM OPN_30DAYS_POST_CONTENT) ;

-- Step 3: DELETE from WSRL and INSERT back into it from WEB_SCRAPE_DEDUPE

TRUNCATE TABLE WEB_SCRAPE_RAW_L ;

INSERT INTO WEB_SCRAPE_RAW_L(SCRAPE_DATE, NEWS_DTM_RAW, NEWS_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT
, MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3, TAG_DONE_FLAG) 
SELECT SCRAPE_DATE, NEWS_DTM_RAW, NEWS_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT
, MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3, TAG_DONE_FLAG FROM WEB_SCRAPE_DEDUPE ;

-- Step 4: DELETE from OPN_30DAYS_POST_CONTENT where LOAD_DATE < 30 DAYS

DELETE FROM OPN_30DAYS_POST_CONTENT WHERE LOAD_DTM < NOW() - INTERVAL 30 DAY ;

-- Step 5: INSERT into OPN_30DAYS_POST_CONTENT from WEB_SCRAPE_DEDUPE and then TRUNCATE it
 
INSERT INTO OPN_30DAYS_POST_CONTENT(POST_CONTENT, LOAD_DTM) SELECT NEWS_URL, NEWS_DATE FROM WEB_SCRAPE_DEDUPE ;

TRUNCATE TABLE WEB_SCRAPE_DEDUPE ;

-- End of dedupe of WSRL


END //
DELIMITER ;

-- 
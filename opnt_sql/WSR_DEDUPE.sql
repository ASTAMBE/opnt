
-- WSR_DEDUPE

 DELIMITER //
DROP PROCEDURE IF EXISTS WSR_DEDUPE //
CREATE PROCEDURE WSR_DEDUPE(SCRAPESRC varchar(45))
BEGIN

/* 12/12/2018 AST: Added NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT to the dedupe logic  
 12/18/2018 ADDED  SCRAPE_DATE, NEW_DATE 
 
 06/16/2019 AST:  Added the case sts below to replace the blanks in NEWS_HEADLINE AND NEWS_EXCERPT
 
 07/29/2019 AST: Added SUBSTR(XYZ, 1, 300) for all the major scraped columns - this is because some of them sometimes came in too big and caused 
 error in INSERT
 
 10/15/2020 AST: Rebuilding this proc to ensure: 1. The scrapes with no NDTM are given an older date
					2. dedupe is done without losing the NDTM info
 06/23/2024 AST: This proc was completely missing all data due to the absence of IFNULL for the MOVED_TO_POST_FLAG
 Now fixed IFNULL(MOVED_TO_POST_FLAG, 'N')
 
 */
 
 SET SQL_SAFE_UPDATES = 0;

DELETE FROM WEB_SCRAPE_DEDUPE WHERE SCRAPE_SOURCE = SCRAPESRC ;
-- DELETE FROM WSR_DEDUPE_NDTM WHERE SCRAPE_SOURCE = SCRAPESRC ;

UPDATE WEB_SCRAPE_RAW SET NEWS_DTM_RAW = NOW() - INTERVAL 3 DAY WHERE SCRAPE_SOURCE = SCRAPESRC
AND LENGTH(NEWS_DTM_RAW) < 3 OR SCRAPE_DATE IS NULL OR SCRAPE_DATE = '0000-00-00 00:00:00';

INSERT INTO WEB_SCRAPE_DEDUPE(SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL
, NEWS_HEADLINE, NEWS_EXCERPT, MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT DISTINCT SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL
, SUBSTR(NEWS_HEADLINE, 1, 500), SUBSTR(NEWS_EXCERPT, 1, 300), MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WEB_SCRAPE_RAW WHERE IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' AND SCRAPE_SOURCE = SCRAPESRC  ;

/*INSERT INTO WSR_DEDUPE_NDTM(SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NDTM)
SELECT SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, MIN(NEWS_DTM_RAW)
FROM WEB_SCRAPE_RAW WHERE IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' AND SCRAPE_SOURCE = SCRAPESRC
GROUP BY SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL ; */

DELETE FROM WEB_SCRAPE_RAW WHERE SCRAPE_SOURCE = SCRAPESRC ;

INSERT INTO WEB_SCRAPE_RAW(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, NEWS_DATE
, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT, MOVED_TO_POST_FLAG
, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT SCRAPE_SOURCE, SCRAPE_TOPIC, NOW() - INTERVAL FLOOR(10 + (RAND() * (300 - 10))) MINUTE
, NOW() - INTERVAL FLOOR(10 + (RAND() * (300 - 10))) MINUTE
, NEWS_URL, NEWS_PIC_URL
, (CASE WHEN LENGTH(NEWS_HEADLINE) < 5 AND LENGTH(NEWS_EXCERPT) < 5 THEN REPLACE(SUBSTRING_INDEX(NEWS_URL, '/', -1), '-', ' ') 
WHEN LENGTH(NEWS_HEADLINE) < 5 AND LENGTH(NEWS_EXCERPT) > 5 THEN SUBSTRING(NEWS_EXCERPT, 1, 300)
WHEN LENGTH(NEWS_HEADLINE) > 4 THEN SUBSTRING(NEWS_HEADLINE, 1, 300) END ) NEWS_HEADLINE
, (CASE WHEN LENGTH(NEWS_EXCERPT) < 5 AND LENGTH(NEWS_HEADLINE) < 5 THEN REPLACE(SUBSTRING_INDEX(NEWS_URL, '/', -1), '-', ' ') 
WHEN LENGTH(NEWS_EXCERPT) < 5 AND LENGTH(NEWS_HEADLINE) > 5 THEN NEWS_HEADLINE
WHEN LENGTH(NEWS_EXCERPT) > 4 THEN NEWS_EXCERPT END ) NEWS_EXCERPT
, MOVED_TO_POST_FLAG
, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WEB_SCRAPE_DEDUPE WHERE IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' AND SCRAPE_SOURCE = SCRAPESRC ;

-- UPDATE WEB_SCRAPE_RAW R, WSR_DEDUPE_NDTM N SET R.NEWS_DTM_RAW = N.NDTM WHERE R.NEWS_URL = N.NEWS_URL ;

DELETE FROM WEB_SCRAPE_RAW  WHERE NEWS_URL IN (SELECT NEWS_URL FROM WSR_CONVERTED WHERE SCRAPE_SOURCE = SCRAPESRC ) ;
-- DELETE FROM WSR_DEDUPE_NDTM WHERE SCRAPE_SOURCE = SCRAPESRC ;

/* INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT
, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_URL NOT IN (SELECT WEB_URL FROM OPN_WEB_LINKS) 
AND NEWS_PIC_URL IS NOT NULL AND SCRAPE_SOURCE = SCRAPESRC ;
*/


END //
DELIMITER ;

-- 
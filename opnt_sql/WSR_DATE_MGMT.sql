-- WSR_DATE_MGMT

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS WSR_DATE_MGMT //
CREATE PROCEDURE WSR_DATE_MGMT()
THISPROC: BEGIN

/* 
09/16/2024: AST: This proc will be used to pre-process the variety of known date formats that 
are brought in by the python scrapers. The variety causes many downstream issues that result 
into STP process failing or not converting any scrapes to posts

*/

SET SQL_SAFE_UPDATES = 0;

DELETE FROM WEB_SCRAPE_RAW_L where LENGTH(IFNULL(NEWS_URL, 'NULLSCRAPE')) < 50 ;

UPDATE WEB_SCRAPE_RAW_L SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%b %d, %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 21 ;
UPDATE WEB_SCRAPE_RAW_L SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%a, %d %b %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 29 ;
UPDATE WEB_SCRAPE_RAW_L SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%a, %d %b %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 31 ;

UPDATE WEB_SCRAPE_RAW SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%b %d, %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 21 ;
UPDATE WEB_SCRAPE_RAW SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%a, %d %b %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 29 ;
UPDATE WEB_SCRAPE_RAW SET NEWS_DATE = DATE_FORMAT(STR_TO_DATE(NEWS_DTM_RAW, '%a, %d %b %Y %H:%i:%s'), '%Y-%m-%d %H:%i:%s') WHERE LENGTH(NEWS_DTM_RAW) = 31 ;




END //
DELIMITER ;

-- 
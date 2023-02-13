
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T5USA //
CREATE PROCEDURE STP_GRAND_T5USA()
THISPROC: BEGIN

/* 
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
    09/19/2020 AST: Adding the tagging of 25 untagged scrapes to entertainmentnews5 KW
    10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAENT', SCRAPE_TAG2 = 'USAENT', SCRAPE_TAG3 = 'USAENT'  
WHERE COUNTRY_CODE = 'USA' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'ENT') AND MOVED_TO_POST_FLAG = 'N' 
AND SCRAPE_TOPIC IN ('ENT', 'CELEB');
  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blackpanther', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%PANTHER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blackpanther', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%PANTHER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gamenight', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%NIGHT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gamenight', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%NIGHT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'redsparrow', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%RED%SPARROW%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'redsparrow', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%RED%SPARROW%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'annihilation', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ANNIHIL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'annihilation', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ANNIHIL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'peterrabbit', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%PETER%RABBIT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'peterrabbit', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%PETER%RABBIT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jumanji', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JUMANJI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jumanji', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JUMANJI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'everyday', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVERY%DAY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'everyday', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVERY%DAY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tgshowman', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GREAT%SHOWMAN%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tgshowman', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GREAT%SHOWMAN%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deathwish', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DEATH%WISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deathwish', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DEATH%WISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '50freed', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%SHADES%FREED%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '50freed', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%SHADES%FREED%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'darkest', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DARKEST%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'darkest', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DARKEST%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tonya', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TONYA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tonya', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TONYA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tombraider', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TOMB%RAIDER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tombraider', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TOMB%RAIDER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'entebbe', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ENTEBBE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'entebbe', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ENTEBBE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'journey', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JOURNEY%END%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'journey', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JOURNEY%END%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jjones', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JESS%JONES%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jjones', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JESS%JONES%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'counterpart', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%COUNTERPART%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'counterpart', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%COUNTERPART%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '7sec', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%7%SEC%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '7sec', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%7%SEC%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altcarbon', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ALTER%CARBON%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altcarbon', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ALTER%CARBON%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'atlanta', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ATLANTA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'atlanta', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ATLANTA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'homeland', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%HOMELAND%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'homeland', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%HOMELAND%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gothrones', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%THRONE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gothrones', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%THRONE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blightning', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%LIGHT%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blightning', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%LIGHT%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'chi', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%THE%CHI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'chi', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%THE%CHI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'versace', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CRIME%STORY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'versace', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CRIME%STORY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'endofworld', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%END%WORLD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'endofworld', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%END%WORLD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'corporate', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CORPORATE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'corporate', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CORPORATE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'goodgirls', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GOOD%GIRL%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'goodgirls', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GOOD%GIRL%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'grownish', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GROWN%ISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'grownish', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GROWN%ISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'willgrace', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%WILL%GRACE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'willgrace', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%WILL%GRACE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'idol', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%AMERI%IDOL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'idol', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE 'AMERI%IDOL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'evildead', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVIL%DEAD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'evildead', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVIL%DEAD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'dp2', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%DEADPOOL%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'dp2', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%DEADPOOL%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'infiwar', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%AVENGERS%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'infiwar', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%AVENGERS%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'quiet', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%QUIET%PLACE%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'quiet', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%QUIET%PLACE%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oboard', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%OVERBOARD%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oboard', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%OVERBOARD%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bookclub', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%BOOK%CLUB%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bookclub', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%BOOK%CLUB%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG1_1KW(5, 'USAENT', 'USA') ;

-- CALL STP_STAG23_1KWINSERT('bookclub','L',1) ;
CALL STP_STAG23_MICRO('bookclub','L') ;
-- CALL STP_STAG23_1KWINSERT('bookclub','H',1) ;
CALL STP_STAG23_MICRO('bookclub','H') ;

-- CALL STP_STAG23_1KWINSERT('oboard','L',1) ;
CALL STP_STAG23_MICRO('oboard','L') ;
-- CALL STP_STAG23_1KWINSERT('oboard','H',1) ;
CALL STP_STAG23_MICRO('oboard','H') ;

-- CALL STP_STAG23_1KWINSERT('quiet','L',1) ;
CALL STP_STAG23_MICRO('quiet','L') ;
-- CALL STP_STAG23_1KWINSERT('quiet','H',1) ;
CALL STP_STAG23_MICRO('quiet','H') ;

-- CALL STP_STAG23_1KWINSERT('infiwar','L',1) ;
CALL STP_STAG23_MICRO('infiwar','L') ;
-- CALL STP_STAG23_1KWINSERT('infiwar','H',1) ;
CALL STP_STAG23_MICRO('infiwar','H') ;

-- CALL STP_STAG23_1KWINSERT('dp2','L',1) ;
CALL STP_STAG23_MICRO('dp2','L') ;
-- CALL STP_STAG23_1KWINSERT('dp2','H',1) ;
CALL STP_STAG23_MICRO('dp2','H') ;

-- CALL STP_STAG23_1KWINSERT('blackpanther','L',1) ;
CALL STP_STAG23_MICRO('blackpanther','L') ;
-- CALL STP_STAG23_1KWINSERT('blackpanther','H',1) ;
CALL STP_STAG23_MICRO('blackpanther','H') ;
-- CALL STP_STAG23_1KWINSERT('gamenight','L',1) ;
CALL STP_STAG23_MICRO('gamenight','L') ;
-- CALL STP_STAG23_1KWINSERT('gamenight','H',1) ;
CALL STP_STAG23_MICRO('gamenight','H') ;
-- CALL STP_STAG23_1KWINSERT('redsparrow','L',1) ;
CALL STP_STAG23_MICRO('redsparrow','L') ;
-- CALL STP_STAG23_1KWINSERT('redsparrow','H',1) ;
CALL STP_STAG23_MICRO('redsparrow','H') ;
-- CALL STP_STAG23_1KWINSERT('annihilation','L',1) ;
CALL STP_STAG23_MICRO('annihilation','L') ;
-- CALL STP_STAG23_1KWINSERT('annihilation','H',1) ;
CALL STP_STAG23_MICRO('annihilation','H') ;
-- CALL STP_STAG23_1KWINSERT('peterrabbit','L',1) ;
CALL STP_STAG23_MICRO('peterrabbit','L') ;
-- CALL STP_STAG23_1KWINSERT('peterrabbit','H',1) ;
CALL STP_STAG23_MICRO('peterrabbit','H') ;
-- CALL STP_STAG23_1KWINSERT('jumanji','L',1) ;
CALL STP_STAG23_MICRO('jumanji','L') ;
-- CALL STP_STAG23_1KWINSERT('jumanji','H',1) ;
CALL STP_STAG23_MICRO('jumanji','H') ;
-- CALL STP_STAG23_1KWINSERT('everyday','L',1) ;
CALL STP_STAG23_MICRO('everyday','L') ;
-- CALL STP_STAG23_1KWINSERT('everyday','H',1) ;
CALL STP_STAG23_MICRO('everyday','H') ;
-- CALL STP_STAG23_1KWINSERT('tgshowman','L',1) ;
CALL STP_STAG23_MICRO('tgshowman','L') ;
-- CALL STP_STAG23_1KWINSERT('tgshowman','H',1) ;
CALL STP_STAG23_MICRO('tgshowman','H') ;
-- CALL STP_STAG23_1KWINSERT('deathwish','L',1) ;
CALL STP_STAG23_MICRO('deathwish','L') ;
-- CALL STP_STAG23_1KWINSERT('deathwish','H',1) ;
CALL STP_STAG23_MICRO('deathwish','H') ;
-- CALL STP_STAG23_1KWINSERT('50freed','L',1) ;
CALL STP_STAG23_MICRO('50freed','L') ;
-- CALL STP_STAG23_1KWINSERT('50freed','H',1) ;
CALL STP_STAG23_MICRO('50freed','H') ;
-- CALL STP_STAG23_1KWINSERT('darkest','L',1) ;
CALL STP_STAG23_MICRO('darkest','L') ;
-- CALL STP_STAG23_1KWINSERT('darkest','H',1) ;
CALL STP_STAG23_MICRO('darkest','H') ;
-- CALL STP_STAG23_1KWINSERT('tonya','L',1) ;
CALL STP_STAG23_MICRO('tonya','L') ;
-- CALL STP_STAG23_1KWINSERT('tonya','H',1) ;
CALL STP_STAG23_MICRO('tonya','H') ;
-- CALL STP_STAG23_1KWINSERT('tombraider','L',1) ;
CALL STP_STAG23_MICRO('tombraider','L') ;
-- CALL STP_STAG23_1KWINSERT('tombraider','H',1) ;
CALL STP_STAG23_MICRO('tombraider','H') ;
-- CALL STP_STAG23_1KWINSERT('entebbe','L',1) ;
CALL STP_STAG23_MICRO('entebbe','L') ;
-- CALL STP_STAG23_1KWINSERT('entebbe','H',1) ;
CALL STP_STAG23_MICRO('entebbe','H') ;
-- CALL STP_STAG23_1KWINSERT('journey','L',1) ;
CALL STP_STAG23_MICRO('journey','L') ;
-- CALL STP_STAG23_1KWINSERT('journey','H',1) ;
CALL STP_STAG23_MICRO('journey','H') ;
-- CALL STP_STAG23_1KWINSERT('jjones','L',1) ;
CALL STP_STAG23_MICRO('jjones','L') ;
-- CALL STP_STAG23_1KWINSERT('jjones','H',1) ;
CALL STP_STAG23_MICRO('jjones','H') ;
-- CALL STP_STAG23_1KWINSERT('counterpart','L',1) ;
CALL STP_STAG23_MICRO('counterpart','L') ;
-- CALL STP_STAG23_1KWINSERT('counterpart','H',1) ;
CALL STP_STAG23_MICRO('counterpart','H') ;
-- CALL STP_STAG23_1KWINSERT('7sec','L',1) ;
CALL STP_STAG23_MICRO('7sec','L') ;
-- CALL STP_STAG23_1KWINSERT('7sec','H',1) ;
CALL STP_STAG23_MICRO('7sec','H') ;
-- CALL STP_STAG23_1KWINSERT('altcarbon','L',1) ;
CALL STP_STAG23_MICRO('altcarbon','L') ;
-- CALL STP_STAG23_1KWINSERT('altcarbon','H',1) ;
CALL STP_STAG23_MICRO('altcarbon','H') ;
-- CALL STP_STAG23_1KWINSERT('atlanta','L',1) ;
CALL STP_STAG23_MICRO('atlanta','L') ;
-- CALL STP_STAG23_1KWINSERT('atlanta','H',1) ;
CALL STP_STAG23_MICRO('atlanta','H') ;
-- CALL STP_STAG23_1KWINSERT('homeland','L',1) ;
CALL STP_STAG23_MICRO('homeland','L') ;
-- CALL STP_STAG23_1KWINSERT('homeland','H',1) ;
CALL STP_STAG23_MICRO('homeland','H') ;
-- CALL STP_STAG23_1KWINSERT('gothrones','L',1) ;
CALL STP_STAG23_MICRO('gothrones','L') ;
-- CALL STP_STAG23_1KWINSERT('gothrones','H',1) ;
CALL STP_STAG23_MICRO('gothrones','H') ;
-- CALL STP_STAG23_1KWINSERT('walkdead','L',1) ;
CALL STP_STAG23_MICRO('walkdead','L') ;
-- CALL STP_STAG23_1KWINSERT('walkdead','H',1) ;
CALL STP_STAG23_MICRO('walkdead','H') ;
-- CALL STP_STAG23_1KWINSERT('blightning','L',1) ;
CALL STP_STAG23_MICRO('blightning','L') ;
-- CALL STP_STAG23_1KWINSERT('blightning','H',1) ;
CALL STP_STAG23_MICRO('blightning','H') ;
-- CALL STP_STAG23_1KWINSERT('chi','L',1) ;
CALL STP_STAG23_MICRO('chi','L') ;
-- CALL STP_STAG23_1KWINSERT('chi','H',1) ;
CALL STP_STAG23_MICRO('chi','H') ;
-- CALL STP_STAG23_1KWINSERT('sneaky','L',1) ;
CALL STP_STAG23_MICRO('sneaky','L') ;
-- CALL STP_STAG23_1KWINSERT('sneaky','H',1) ;
CALL STP_STAG23_MICRO('sneaky','H') ;
-- CALL STP_STAG23_1KWINSERT('versace','L',1) ;
CALL STP_STAG23_MICRO('versace','L') ;
-- CALL STP_STAG23_1KWINSERT('versace','H',1) ;
CALL STP_STAG23_MICRO('versace','H') ;
-- CALL STP_STAG23_1KWINSERT('endofworld','L',1) ;
CALL STP_STAG23_MICRO('endofworld','L') ;
-- CALL STP_STAG23_1KWINSERT('endofworld','H',1) ;
CALL STP_STAG23_MICRO('endofworld','H') ;
-- CALL STP_STAG23_1KWINSERT('corporate','L',1) ;
CALL STP_STAG23_MICRO('corporate','L') ;
-- CALL STP_STAG23_1KWINSERT('corporate','H',1) ;
CALL STP_STAG23_MICRO('corporate','H') ;
-- CALL STP_STAG23_1KWINSERT('queer','L',1) ;
CALL STP_STAG23_MICRO('queer','L') ;
-- CALL STP_STAG23_1KWINSERT('queer','H',1) ;
CALL STP_STAG23_MICRO('queer','H') ;
-- CALL STP_STAG23_1KWINSERT('goodgirls','L',1) ;
CALL STP_STAG23_MICRO('goodgirls','L') ;
-- CALL STP_STAG23_1KWINSERT('goodgirls','H',1) ;
CALL STP_STAG23_MICRO('goodgirls','H') ;
-- CALL STP_STAG23_1KWINSERT('grownish','L',1) ;
CALL STP_STAG23_MICRO('grownish','L') ;
-- CALL STP_STAG23_1KWINSERT('grownish','H',1) ;
CALL STP_STAG23_MICRO('grownish','H') ;
-- CALL STP_STAG23_1KWINSERT('willgrace','L',1) ;
CALL STP_STAG23_MICRO('willgrace','L') ;
-- CALL STP_STAG23_1KWINSERT('willgrace','H',1) ;
CALL STP_STAG23_MICRO('willgrace','H') ;
-- CALL STP_STAG23_1KWINSERT('idol','L',1) ;
CALL STP_STAG23_MICRO('idol','L') ;
-- CALL STP_STAG23_1KWINSERT('idol','H',1) ;
CALL STP_STAG23_MICRO('idol','H') ;
-- CALL STP_STAG23_1KWINSERT('evildead','L',1) ;
CALL STP_STAG23_MICRO('evildead','L') ;
-- CALL STP_STAG23_1KWINSERT('evildead','H',1) ;
CALL STP_STAG23_MICRO('evildead','H') ;

/*  Completing the entertainmentnews5 addition with STp MICRo call  */

CALL STP_STAG23_MICRO('entertainmentnews5', 'H') ;

CALL STP_STAG23_MICRO('entertainmentnews5', 'L') ;

/*  END OF Completing the entertainmentnews5 addition with STp MICRo call  */

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T5USA', 'ENT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */




  
  
END; //
 DELIMITER ;
 
 -- 
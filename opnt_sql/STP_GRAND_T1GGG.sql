-- STP_GRAND_T1GGG

DROP PROCEDURE IF EXISTS `STP_GRAND_T1GGG`;
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `STP_GRAND_T1GGG`()
THISPROC: BEGIN

/* 

80007	Theresa May	tmay	H	1008004	OU1008004
80007	Theresa May	tmay	L	1008003	OU1008003
80008	Jeremy Corbyn	corbyn	H	1008006	OU1008006
80008	Jeremy Corbyn	corbyn	L	1008005	OU1008005
80009	Justin Trudeau	trudeau	H	1008008	OU1008008
80009	Justin Trudeau	trudeau	L	1008007	OU1008007
80010	Emmanuel Macron	macron	H	1008010	OU1008010
80010	Emmanuel Macron	macron	L	1008009	OU1008009
80011	Marine Le Pen	lepen	H	1008014	OU1008014
80011	Marine Le Pen	lepen	L	1008013	OU1008013
80012	Xi Jinping	xi	H	1020606	GGST1020606
80012	Xi Jinping	xi	L	1008011	OU1008011
80013	Vladimir Putin	putin	H	1008016	OU1008016
80013	Vladimir Putin	putin	L	1008015	OU1008015
80014	Benjamin Netanyahu	netanyahu	H	1008002	OU1008002
80014	Benjamin Netanyahu	netanyahu	L	1008001	OU1008001
80015	Mahmoud Abbas	abbas	H	1020609	GGST1020609
80015	Mahmoud Abbas	abbas	L	1008017	OU1008017
80016	Angela Merkel	merkel	H	1008012	OU1008012
80016	Angela Merkel	merkel	L	1020620	GGST1020620

04/25/2019 AST: Removing the CALL STP_STAG1_1KW(1, 'GPOL', 'GGG')  because it is not productive 

	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
    06/24/2023: AST: Introducing the STP_REMAINDER proc 

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'GPOL' ,SCRAPE_TAG2 = 'GPOL', SCRAPE_TAG3 = 'GPOL' 
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tmay'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THERESA%MAY%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'corbyn'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CORBYN%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tmay'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THERESA%MAY%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'corbyn'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CORBYN%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'trudeau'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TRUDEAU%' 
OR UPPER(NEWS_URL) LIKE     '%CANADA%%'  OR UPPER(NEWS_URL) LIKE     'CANADI%'
OR UPPER(NEWS_URL) LIKE     '%OTTAWA%' )     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'trudeau'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TRUDEAU%' 
OR UPPER(NEWS_URL) LIKE     '%CANADA%%'  OR UPPER(NEWS_URL) LIKE     'CANADI%'
OR UPPER(NEWS_URL) LIKE     '%OTTAWA%' )     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;  

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macron'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MACRON%' 
OR UPPER(NEWS_URL) LIKE     '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lepen'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LE%PEN%' 
OR UPPER(NEWS_URL) LIKE      '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%') 
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macron'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MACRON%' 
OR UPPER(NEWS_URL) LIKE     '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lepen'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LE%PEN%' ) 
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'xi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%XI%' 
OR UPPER(NEWS_URL) LIKE     '%JINPING%%'  OR UPPER(NEWS_URL) LIKE     '%CHINA%'
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%YUAN%'  
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%RENMIN%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'xi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%XI%' 
OR UPPER(NEWS_URL) LIKE     '%JINPING%%'  OR UPPER(NEWS_URL) LIKE     '%CHINA%'
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%YUAN%'  
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%RENMIN%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'putin'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PUTIN%' 
OR UPPER(NEWS_URL) LIKE     '%RUSSIA%%'  OR UPPER(NEWS_URL) LIKE     '%UKRAIN%'
 OR UPPER(NEWS_URL) LIKE     '%CRIMEA%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'putin'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PUTIN%' 
OR UPPER(NEWS_URL) LIKE     '%RUSSIA%%'  OR UPPER(NEWS_URL) LIKE     '%UKRAIN%'
 OR UPPER(NEWS_URL) LIKE     '%CRIMEA%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'netanyahu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NETANYAH%' OR UPPER(NEWS_URL) LIKE     '%ISRAEL%%'   )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'netanyahu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NETANYAH%' OR UPPER(NEWS_URL) LIKE     '%ISRAEL%%'   )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;       

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'abbas'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ABBAS%' 
OR UPPER(NEWS_URL) LIKE     '%PALESTIN%%'  OR UPPER(NEWS_URL) LIKE     '%GAZA%%' 
OR UPPER(NEWS_URL) LIKE     '%WEST%BANK%' OR UPPER(NEWS_URL) LIKE     '%-PLO-%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'abbas'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ABBAS%' 
OR UPPER(NEWS_URL) LIKE     '%PALESTIN%%'  OR UPPER(NEWS_URL) LIKE     '%GAZA%%' 
OR UPPER(NEWS_URL) LIKE     '%WEST%BANK%' OR UPPER(NEWS_URL) LIKE     '%-PLO-%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'merkel'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MERKEL%' 
OR UPPER(NEWS_URL) LIKE     '%GERMAN%%'  OR UPPER(NEWS_URL) LIKE     '%EURO%%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'merkel'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MERKEL%' 
OR UPPER(NEWS_URL) LIKE     '%GERMAN%%'  OR UPPER(NEWS_URL) LIKE     '%EURO%%'  )         
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

-- 

-- CALL STP_STAG1_1KW(1, 'GPOL', 'GGG') ;

-- 

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('tmay', 'H', 2) ;
CALL STP_STAG23_MICRO('tmay', 'H') ;
-- CALL STP_STAG23_1KWINSERT('tmay', 'L', 3) ;
CALL STP_STAG23_MICRO('tmay', 'L') ;

-- CALL STP_STAG23_1KWINSERT('corbyn', 'H', 2) ;
CALL STP_STAG23_MICRO('corbyn', 'H') ;
-- CALL STP_STAG23_1KWINSERT('corbyn', 'L', 3) ;
CALL STP_STAG23_MICRO('corbyn', 'L') ;

-- CALL STP_STAG23_1KWINSERT('trudeau', 'H', 2) ;
CALL STP_STAG23_MICRO('trudeau', 'H') ;
-- CALL STP_STAG23_1KWINSERT('trudeau', 'L', 3) ;
CALL STP_STAG23_MICRO('trudeau', 'L') ;

-- CALL STP_STAG23_1KWINSERT('macron', 'H', 2) ;
CALL STP_STAG23_MICRO('macron', 'H') ;
-- CALL STP_STAG23_1KWINSERT('macron', 'L', 3) ;
CALL STP_STAG23_MICRO('macron', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lepen', 'H', 2) ;
CALL STP_STAG23_MICRO('lepen', 'H') ;
-- CALL STP_STAG23_1KWINSERT('lepen', 'L', 3) ;
CALL STP_STAG23_MICRO('lepen', 'L') ;

-- CALL STP_STAG23_1KWINSERT('xi', 'H', 2) ;
CALL STP_STAG23_MICRO('xi', 'H') ;
-- CALL STP_STAG23_1KWINSERT('xi', 'L', 3) ;
CALL STP_STAG23_MICRO('xi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('putin', 'H', 2) ;
CALL STP_STAG23_MICRO('putin', 'H') ;
-- CALL STP_STAG23_1KWINSERT('putin', 'L', 3) ;
CALL STP_STAG23_MICRO('putin', 'L') ;

-- CALL STP_STAG23_1KWINSERT('netanyahu', 'H', 2) ;
CALL STP_STAG23_MICRO('netanyahu', 'H') ;
-- CALL STP_STAG23_1KWINSERT('netanyahu', 'L', 3) ;
CALL STP_STAG23_MICRO('netanyahu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('abbas', 'H', 2) ;
CALL STP_STAG23_MICRO('abbas', 'H') ;
-- CALL STP_STAG23_1KWINSERT('abbas', 'L', 3) ;
CALL STP_STAG23_MICRO('abbas', 'L') ;

-- CALL STP_STAG23_1KWINSERT('merkel', 'H', 2) ;
CALL STP_STAG23_MICRO('merkel', 'H') ;
-- CALL STP_STAG23_1KWINSERT('merkel', 'L', 3) ;
CALL STP_STAG23_MICRO('merkel', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y' ;

/* 06/24/2023: AST: Introducing the STP_REMAINDER proc - instead of sweeping the untagged 
scrapes to WSR_UNTAGGED, they will be distributed among the BOTs that have received 
KWs in their carts recently. This will change the UNTAGGED calc - it will be the 
STP_REMAINDER count.

*/

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'N') ;

CALL STP_REMAINDER('POLITICS', 1, 'GGG') ;

INSERT INTO WSR_CONVERTED(STP_PROCESS, SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT 'STP_REMAINDER', SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('POLITICS') AND COUNTRY_CODE = 'GGG'   AND MOVED_TO_POST_FLAG = 'Y' ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T1GGG', 'POLITICS', 'GGG', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP Logging addition */

  
  
END//
DELIMITER ;


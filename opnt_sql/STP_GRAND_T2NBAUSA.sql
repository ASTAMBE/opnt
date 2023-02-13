
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NBAUSA //
CREATE PROCEDURE STP_GRAND_T2NBAUSA()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%celtics-%' OR NEWS_URL LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%celtics-%' OR NEWS_URL LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nets-%' OR NEWS_URL LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nets-%' OR NEWS_URL LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%knicks-%' OR NEWS_URL LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%knicks-%' OR NEWS_URL LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%76ers-%' OR NEWS_URL LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%76ers-%' OR NEWS_URL LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raptors-%' OR NEWS_URL LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raptors-%' OR NEWS_URL LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bulls-%' OR NEWS_URL LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bulls-%' OR NEWS_URL LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cavaliers-%' OR NEWS_URL LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cavaliers-%' OR NEWS_URL LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pistons-%' OR NEWS_URL LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pistons-%' OR NEWS_URL LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pacers-%' OR NEWS_URL LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pacers-%' OR NEWS_URL LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bucks-%' OR NEWS_URL LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bucks-%' OR NEWS_URL LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hawks-%' OR NEWS_URL LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hawks-%' OR NEWS_URL LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hornets-%' OR NEWS_URL LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hornets-%' OR NEWS_URL LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%heat-%' OR NEWS_URL LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%heat-%' OR NEWS_URL LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%magic-%' OR NEWS_URL LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%magic-%' OR NEWS_URL LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%wizards-%' OR NEWS_URL LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%wizards-%' OR NEWS_URL LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nuggets-%' OR NEWS_URL LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nuggets-%' OR NEWS_URL LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%timberwolves-%' OR NEWS_URL LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%timberwolves-%' OR NEWS_URL LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%thunder-%' OR NEWS_URL LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%thunder-%' OR NEWS_URL LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%blazers-%' OR NEWS_URL LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%blazers-%' OR NEWS_URL LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jazz-%' OR NEWS_URL LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jazz-%' OR NEWS_URL LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%clippers-%' OR NEWS_URL LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%clippers-%' OR NEWS_URL LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lakers-%' OR NEWS_URL LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lakers-%' OR NEWS_URL LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%suns-%' OR NEWS_URL LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%suns-%' OR NEWS_URL LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%kings-%' OR NEWS_URL LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%kings-%' OR NEWS_URL LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mavericks-%' OR NEWS_URL LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mavericks-%' OR NEWS_URL LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockets-%' OR NEWS_URL LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockets-%' OR NEWS_URL LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%grizzlies-%' OR NEWS_URL LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%grizzlies-%' OR NEWS_URL LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pelicans-%' OR NEWS_URL LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pelicans-%' OR NEWS_URL LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%NBA-%' OR NEWS_URL LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%NBA-%' OR NEWS_URL LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'L') ;


-- CALL STP_STAG23_1KWINSERT('NBA', 'H', 5) ;
CALL STP_STAG23_MICRO('NBA', 'H') ;

-- CALL STP_STAG23_1KWINSERT('NBA', 'L', 5) ;
CALL STP_STAG23_MICRO('NBA', 'L') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'H', 3) ;
CALL STP_STAG23_MICRO('celtics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'L', 3) ;
CALL STP_STAG23_MICRO('celtics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'H', 3) ;
CALL STP_STAG23_MICRO('raptors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'L', 3) ;
CALL STP_STAG23_MICRO('raptors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'H', 3) ;
CALL STP_STAG23_MICRO('nets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'L', 3) ;
CALL STP_STAG23_MICRO('nets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'H', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'L', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'H', 3) ;
CALL STP_STAG23_MICRO('suns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'L', 3) ;
CALL STP_STAG23_MICRO('suns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'H', 3) ;
CALL STP_STAG23_MICRO('knicks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'L', 3) ;
CALL STP_STAG23_MICRO('knicks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'H', 3) ;
CALL STP_STAG23_MICRO('wizards', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'L', 3) ;
CALL STP_STAG23_MICRO('wizards', 'L') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'H', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'L', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockets', 'H', 3) ;
CALL STP_STAG23_MICRO('rockets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockets', 'L', 3) ;
CALL STP_STAG23_MICRO('rockets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'H', 3) ;
CALL STP_STAG23_MICRO('kings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'L', 3) ;
CALL STP_STAG23_MICRO('kings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'H', 3) ;
CALL STP_STAG23_MICRO('pacers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'L', 3) ;
CALL STP_STAG23_MICRO('pacers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'H', 3) ;
CALL STP_STAG23_MICRO('jazz', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'L', 3) ;
CALL STP_STAG23_MICRO('jazz', 'L') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'H', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'L', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'H', 3) ;
CALL STP_STAG23_MICRO('clippers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'L', 3) ;
CALL STP_STAG23_MICRO('clippers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'H', 3) ;
CALL STP_STAG23_MICRO('hornets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'L', 3) ;
CALL STP_STAG23_MICRO('hornets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'H', 3) ;
CALL STP_STAG23_MICRO('warriors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'L', 3) ;
CALL STP_STAG23_MICRO('warriors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'H', 3) ;
CALL STP_STAG23_MICRO('bucks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'L', 3) ;
CALL STP_STAG23_MICRO('bucks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'H', 3) ;
CALL STP_STAG23_MICRO('blazers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'L', 3) ;
CALL STP_STAG23_MICRO('blazers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'H', 3) ;
CALL STP_STAG23_MICRO('bulls', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'L', 3) ;
CALL STP_STAG23_MICRO('bulls', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'H', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'L', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'H', 3) ;
CALL STP_STAG23_MICRO('heat', 'H') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'L', 3) ;
CALL STP_STAG23_MICRO('heat', 'L') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'H', 3) ;
CALL STP_STAG23_MICRO('thunder', 'H') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'L', 3) ;
CALL STP_STAG23_MICRO('thunder', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'H', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'L', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'H', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'L', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('lakers', 'H', 3) ;
CALL STP_STAG23_MICRO('lakers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lakers', 'L', 3) ;
CALL STP_STAG23_MICRO('lakers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'H', 3) ;
CALL STP_STAG23_MICRO('magic', 'H') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'L', 3) ;
CALL STP_STAG23_MICRO('magic', 'L') ;


-- CALL STP_STAG23_1KWINSERT('76ers', 'H', 3) ;
CALL STP_STAG23_MICRO('76ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('76ers', 'L', 3) ;
CALL STP_STAG23_MICRO('76ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'H', 3) ;
CALL STP_STAG23_MICRO('pistons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'L', 3) ;
CALL STP_STAG23_MICRO('pistons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'H', 3) ;
CALL STP_STAG23_MICRO('hawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'L', 3) ;
CALL STP_STAG23_MICRO('hawks', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NBAUSA', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
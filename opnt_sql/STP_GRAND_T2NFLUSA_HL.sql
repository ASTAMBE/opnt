
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NFLUSA_HL //
CREATE PROCEDURE STP_GRAND_T2NFLUSA_HL()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
        09/19/2020 AST: Adding the tagging of 25 untagged scrapes to sportsnews2 KW
        10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
            10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%ravens%' OR NEWS_HEADLINE LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%ravens%' OR NEWS_HEADLINE LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bengals%' OR NEWS_HEADLINE LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bengals%' OR NEWS_HEADLINE LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%browns%' OR NEWS_HEADLINE LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%browns%' OR NEWS_HEADLINE LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%steelers%' OR NEWS_HEADLINE LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%steelers%' OR NEWS_HEADLINE LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bears%' OR NEWS_HEADLINE LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bears%' OR NEWS_HEADLINE LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lions%' OR NEWS_HEADLINE LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lions%' OR NEWS_HEADLINE LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%packers%' OR NEWS_HEADLINE LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%packers%' OR NEWS_HEADLINE LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%texans%' OR NEWS_HEADLINE LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%texans%' OR NEWS_HEADLINE LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%colts%' OR NEWS_HEADLINE LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%colts%' OR NEWS_HEADLINE LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jaguars%' OR NEWS_HEADLINE LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jaguars%' OR NEWS_HEADLINE LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%titans%' OR NEWS_HEADLINE LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%titans%' OR NEWS_HEADLINE LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%falcons%' OR NEWS_HEADLINE LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%falcons%' OR NEWS_HEADLINE LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%panthers%' OR NEWS_HEADLINE LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%panthers%' OR NEWS_HEADLINE LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%saints%' OR NEWS_HEADLINE LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%saints%' OR NEWS_HEADLINE LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%buccaneers%' OR NEWS_HEADLINE LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%buccaneers%' OR NEWS_HEADLINE LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bills%' OR NEWS_HEADLINE LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bills%' OR NEWS_HEADLINE LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dolphins%' OR NEWS_HEADLINE LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dolphins%' OR NEWS_HEADLINE LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%patriots%' OR NEWS_HEADLINE LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%patriots%' OR NEWS_HEADLINE LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jets%' OR NEWS_HEADLINE LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jets%' OR NEWS_HEADLINE LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cowboys%' OR NEWS_HEADLINE LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cowboys%' OR NEWS_HEADLINE LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%eagles%' OR NEWS_HEADLINE LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%eagles%' OR NEWS_HEADLINE LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%redskins%' OR NEWS_HEADLINE LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%redskins%' OR NEWS_HEADLINE LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%broncos%' OR NEWS_HEADLINE LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%broncos%' OR NEWS_HEADLINE LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chiefs%' OR NEWS_HEADLINE LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chiefs%' OR NEWS_HEADLINE LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raiders%' OR NEWS_HEADLINE LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raiders%' OR NEWS_HEADLINE LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chargers%' OR NEWS_HEADLINE LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chargers%' OR NEWS_HEADLINE LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rams%' OR NEWS_HEADLINE LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rams%' OR NEWS_HEADLINE LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%49ers%' OR NEWS_HEADLINE LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%49ers%' OR NEWS_HEADLINE LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%seahawks%' OR NEWS_HEADLINE LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%seahawks%' OR NEWS_HEADLINE LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%vikings%' OR NEWS_HEADLINE LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%vikings%' OR NEWS_HEADLINE LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('ravens', 'H', 3) ;
CALL STP_STAG23_MICRO('ravens', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ravens', 'L', 3) ;
CALL STP_STAG23_MICRO('ravens', 'L') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'H', 3) ;
CALL STP_STAG23_MICRO('49ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'L', 3) ;
CALL STP_STAG23_MICRO('49ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'H', 3) ;
CALL STP_STAG23_MICRO('bears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'L', 3) ;
CALL STP_STAG23_MICRO('bears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'H', 3) ;
CALL STP_STAG23_MICRO('bengals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'L', 3) ;
CALL STP_STAG23_MICRO('bengals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'H', 3) ;
CALL STP_STAG23_MICRO('bills', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'L', 3) ;
CALL STP_STAG23_MICRO('bills', 'L') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'H', 3) ;
CALL STP_STAG23_MICRO('broncos', 'H') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'L', 3) ;
CALL STP_STAG23_MICRO('broncos', 'L') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'H', 3) ;
CALL STP_STAG23_MICRO('browns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'L', 3) ;
CALL STP_STAG23_MICRO('browns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'H', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'L', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'L') ;


-- CALL STP_STAG23_1KWINSERT('chargers', 'H', 3) ;
CALL STP_STAG23_MICRO('chargers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chargers', 'L', 3) ;
CALL STP_STAG23_MICRO('chargers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'H', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'L', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'H', 3) ;
CALL STP_STAG23_MICRO('colts', 'H') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'L', 3) ;
CALL STP_STAG23_MICRO('colts', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'H', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'L', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'H', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'L', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'H', 3) ;
CALL STP_STAG23_MICRO('eagles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'L', 3) ;
CALL STP_STAG23_MICRO('eagles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'H', 3) ;
CALL STP_STAG23_MICRO('falcons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'L', 3) ;
CALL STP_STAG23_MICRO('falcons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'H', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'L', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'H', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'L', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'H', 3) ;
CALL STP_STAG23_MICRO('jets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'L', 3) ;
CALL STP_STAG23_MICRO('jets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'H', 3) ;
CALL STP_STAG23_MICRO('lions', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'L', 3) ;
CALL STP_STAG23_MICRO('lions', 'L') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'H', 3) ;
CALL STP_STAG23_MICRO('packers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'L', 3) ;
CALL STP_STAG23_MICRO('packers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'H', 3) ;
CALL STP_STAG23_MICRO('panthers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'L', 3) ;
CALL STP_STAG23_MICRO('panthers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'H', 3) ;
CALL STP_STAG23_MICRO('patriots', 'H') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'L', 3) ;
CALL STP_STAG23_MICRO('patriots', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'H', 3) ;
CALL STP_STAG23_MICRO('raiders', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'L', 3) ;
CALL STP_STAG23_MICRO('raiders', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'H', 3) ;
CALL STP_STAG23_MICRO('rams', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'L', 3) ;
CALL STP_STAG23_MICRO('rams', 'L') ;


-- CALL STP_STAG23_1KWINSERT('redskins', 'H', 3) ;
CALL STP_STAG23_MICRO('redskins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('redskins', 'L', 3) ;
CALL STP_STAG23_MICRO('redskins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'H', 3) ;
CALL STP_STAG23_MICRO('saints', 'H') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'L', 3) ;
CALL STP_STAG23_MICRO('saints', 'L') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'H', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'L', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'H', 3) ;
CALL STP_STAG23_MICRO('steelers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'L', 3) ;
CALL STP_STAG23_MICRO('steelers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'H', 3) ;
CALL STP_STAG23_MICRO('texans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'L', 3) ;
CALL STP_STAG23_MICRO('texans', 'L') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'H', 3) ;
CALL STP_STAG23_MICRO('titans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'L', 3) ;
CALL STP_STAG23_MICRO('titans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('vikings', 'H', 3) ;
CALL STP_STAG23_MICRO('vikings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('vikings', 'L', 3) ;
CALL STP_STAG23_MICRO('vikings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'H', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'L', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'L') ;


/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;


/* 06/24/2023: AST: Introducing the STP_REMAINDER proc - instead of sweeping the untagged 
scrapes to WSR_UNTAGGED, they will be distributed among the BOTs that have received 
KWs in their carts recently. This will change the UNTAGGED calc - it will be the 
STP_REMAINDER count.

*/

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SPORTS') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N') ;

CALL STP_REMAINDER('SPORTS', 2, 'USA') ;

INSERT INTO WSR_CONVERTED(STP_PROCESS, SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT 'STP_REMAINDER', SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SPORTS') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'  AND MOVED_TO_POST_FLAG = 'Y' ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SPORTS') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NFLUSA_HL', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
-- STP_MONITOR_IND

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS STP_MONITOR_IND //
CREATE PROCEDURE STP_MONITOR_IND(WSR_FILE VARCHAR(300))
THISPROC: BEGIN

/* 
07/19/2019 AST: This proc is for calling all the UKW and STP GRAND procs and logging the WSR and POST counts at each stage
03/04/2020 AST: Removed WFD from inputs and turned it into a var
08/11/2020 Kapil: Confirmed
10/11/2020 AST: Adding the STP_GRAND_XYZNEWS portion
*/


DECLARE SPC, SWC, DWC, DPC, R_ID INT;
DECLARE WSR_TO_POST_RATIO DOUBLE;
DECLARE CDTM DATETIME ;
DECLARE WFD DATE ;

SET SQL_SAFE_UPDATES = 0;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
SET CDTM = NOW() ;
SET WFD = CURRENT_DATE() ;

DELETE FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD ;
  
INSERT INTO OPN_STP_MONITOR(WSR_FILE_NAME, WSR_FILE_DATE, STP_MONITOR_PROCESS
, STARTING_POST_COUNT, STARTING_WSR_COUNT, CREATION_DTM)
VALUES(WSR_FILE, WFD, 'INITIAL_WSR_LOAD', SPC, SWC, CDTM);

INSERT INTO OPN_STP_MONITOR(WSR_FILE_NAME, WSR_FILE_DATE, STP_MONITOR_PROCESS, CREATION_DTM)
VALUES (WSR_FILE, WFD, 'STP_GRAND_XYZNEWS', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(10)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(5)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(9)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(4)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(1)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(2)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(3)', CDTM)
-- , (WSR_FILE, WFD, 'STP_GRAND_USA()', CDTM)
, (WSR_FILE, WFD, 'STP_GRAND_IND()', CDTM)
-- , (WSR_FILE, WFD, 'STP_GRAND_GGG()', CDTM)
;

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' AND CREATION_DTM = CDTM) ;
CALL WSR_DEDUPE_ALL() ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR M SET M.DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = SPC WHERE M.ROW_ID = R_ID ;

-- Adding the STP_GRAND_XYZNEWS 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_XYZNEWS' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_XYZNEWS_IND() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;


-- End of STP_GRAND_XYZNEWS -- Starting TID 10

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(10)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(10) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 10 - Starting TID 5 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(5)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(5) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 5 - Starting TID 9 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(9)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(9) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 9 - Starting TID 4 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(1)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(1) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 4 - Starting TID 1 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(4)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(4) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 1 - Starting TID 2 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(2)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(2) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 2 - Starting TID 3

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(3)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(3) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 3 - Starting USA

/*
SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_USA()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_USA() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

*/

-- End of USA - Starting IND

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_IND()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_IND() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of IND - Starting GGG

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_GGG()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_GGG() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

UPDATE OPN_STP_MONITOR SET DEDUPED_POST_COUNT = DPC WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' ;
UPDATE OPN_STP_MONITOR SET POST_COUNT = (DEDUPED_POST_COUNT - STARTING_POST_COUNT) WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD ;
UPDATE OPN_STP_MONITOR SET POST_TO_WSR_RATIO = ROUND(POST_COUNT*100/DEDUPED_WSR_COUNT, 2)
WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' ;


END //
DELIMITER ;

-- 

-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T4IND //
CREATE PROCEDURE STP_GRAND_T4IND()
THISPROC: BEGIN

/* 
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/19/2020 AST: Adding BUSINESSNEWS4 STP steps
10/04/2020 AST: adding filter to BUSINESSNEWS4 to avoid: old news, stock market update
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'INDBIZ', SCRAPE_TAG2 = 'INDBIZ', SCRAPE_TAG3 = 'INDBIZ' WHERE COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC = 'BUSINESS'
AND (SCRAPE_SOURCE LIKE 'ET%' OR UPPER(SCRAPE_SOURCE) LIKE 'INDIAN%' OR SCRAPE_SOURCE LIKE 'DP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ril'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIL-%'  OR UPPER(NEWS_URL) LIKE     '%RELIANCE%' 
OR UPPER(NEWS_URL) LIKE     '%MUKESH%'  OR UPPER(NEWS_URL) LIKE     '%JIO-%') AND  UPPER(NEWS_URL) NOT LIKE '%APRIL%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ril'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIL-%'  OR UPPER(NEWS_URL) LIKE     '%RELIANCE%' 
OR UPPER(NEWS_URL) LIKE     '%MUKESH%'  OR UPPER(NEWS_URL) LIKE     '%JIO-%') AND  UPPER(NEWS_URL) NOT LIKE '%APRIL%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tata'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TATA%'  OR UPPER(NEWS_URL) LIKE     '%DOCOMO%' 
) AND  UPPER(NEWS_URL) NOT LIKE '%TCS%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tata'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TATA%'  OR UPPER(NEWS_URL) LIKE     '%DOCOMO%' 
) AND  UPPER(NEWS_URL) NOT LIKE '%TCS%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'birla', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%BIRLA%' OR UPPER(NEWS_URL) LIKE '%GRASIM%' 
OR UPPER(NEWS_URL) LIKE  '%HINDALCO%' OR UPPER(NEWS_URL) LIKE '%IDEA-%' OR UPPER(NEWS_URL) LIKE  '%ULTRATECH%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'birla', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%BIRLA%' OR UPPER(NEWS_URL) LIKE '%GRASIM%' 
OR UPPER(NEWS_URL) LIKE  '%HINDALCO%' OR UPPER(NEWS_URL) LIKE '%IDEA-%' OR UPPER(NEWS_URL) LIKE  '%ULTRATECH%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anilambani'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RELIANCE%'  OR UPPER(NEWS_URL) LIKE     '%BSES%' 
OR UPPER(NEWS_URL) LIKE     '%ANIL%AMBANI%' ) AND  UPPER(NEWS_URL) NOT LIKE '%-RIL-%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anilambani'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RELIANCE%'  OR UPPER(NEWS_URL) LIKE     '%BSES%' 
OR UPPER(NEWS_URL) LIKE     '%ANIL%AMBANI%' ) AND  UPPER(NEWS_URL) NOT LIKE '%-RIL-%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airtel'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AIRTEL%'  OR UPPER(NEWS_URL) LIKE     '%BHARTI-%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airtel'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AIRTEL%'  OR UPPER(NEWS_URL) LIKE     '%BHARTI-%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'infy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INFOSYS%'  OR UPPER(NEWS_URL) LIKE     '%NARAY%MURTHY%' 
OR UPPER(NEWS_URL) LIKE     '%INFY%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'infy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INFOSYS%'  OR UPPER(NEWS_URL) LIKE     '%NARAY%MURTHY%' 
OR UPPER(NEWS_URL) LIKE     '%INFY%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tcs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TCS%'  OR UPPER(NEWS_URL) LIKE     '%TATA%CONSULT%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tcs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TCS%'  OR UPPER(NEWS_URL) LIKE     '%TATA%CONSULT%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wipro'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%WIPRO%'  OR UPPER(NEWS_URL) LIKE     '%PREMJI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wipro'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%WIPRO%'  OR UPPER(NEWS_URL) LIKE     '%PREMJI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cogni'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%COGNIZ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cogni'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%COGNIZ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'itc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ITC-%' 
OR UPPER(NEWS_URL) LIKE     '%-ITC%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'itc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ITC-%' 
OR UPPER(NEWS_URL) LIKE     '%-ITC%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'icici'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ICICI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'icici'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ICICI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sbi'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SBI%' 
OR UPPER(NEWS_URL) LIKE     '%STATE%BANK%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sbi'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SBI%' 
OR UPPER(NEWS_URL) LIKE     '%STATE%BANK%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bajaj'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BAJAJ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bajaj'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BAJAJ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mahindra'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MAHINDRA%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mahindra'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MAHINDRA%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hdfc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HDFC%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hdfc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HDFC%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'spice'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SPICE%JET%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'spice'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SPICE%JET%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indigo'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INDIGO%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indigo'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INDIGO%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('indigo', 'H', 2) ;
CALL STP_STAG23_MICRO('indigo', 'H') ;

-- CALL STP_STAG23_1KWINSERT('indigo', 'L', 2) ;
CALL STP_STAG23_MICRO('indigo', 'L') ;

-- CALL STP_STAG23_1KWINSERT('spice', 'H', 2) ;
CALL STP_STAG23_MICRO('spice', 'H') ;

-- CALL STP_STAG23_1KWINSERT('spice', 'L', 2) ;
CALL STP_STAG23_MICRO('spice', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hdfc', 'H', 2) ;
CALL STP_STAG23_MICRO('hdfc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hdfc', 'L', 2) ;
CALL STP_STAG23_MICRO('hdfc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mahindra', 'H', 2) ;
CALL STP_STAG23_MICRO('mahindra', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mahindra', 'L', 2) ;
CALL STP_STAG23_MICRO('mahindra', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bajaj', 'H', 2) ;
CALL STP_STAG23_MICRO('bajaj', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bajaj', 'L', 2) ;
CALL STP_STAG23_MICRO('bajaj', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sbi', 'H', 2) ;
CALL STP_STAG23_MICRO('sbi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sbi', 'L', 2) ;
CALL STP_STAG23_MICRO('sbi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('icici', 'H', 2) ;
CALL STP_STAG23_MICRO('icici', 'H') ;

-- CALL STP_STAG23_1KWINSERT('icici', 'L', 2) ;
CALL STP_STAG23_MICRO('icici', 'L') ;

-- CALL STP_STAG23_1KWINSERT('itc', 'H', 2) ;
CALL STP_STAG23_MICRO('itc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('itc', 'L', 2) ;
CALL STP_STAG23_MICRO('itc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cogni', 'H', 2) ;
CALL STP_STAG23_MICRO('cogni', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cogni', 'L', 2) ;
CALL STP_STAG23_MICRO('cogni', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wipro', 'H', 2) ;
CALL STP_STAG23_MICRO('wipro', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wipro', 'L', 2) ;
CALL STP_STAG23_MICRO('wipro', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tcs', 'H', 2) ;
CALL STP_STAG23_MICRO('tcs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tcs', 'L', 2) ;
CALL STP_STAG23_MICRO('tcs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('infy', 'H', 2) ;
CALL STP_STAG23_MICRO('infy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('infy', 'L', 2) ;
CALL STP_STAG23_MICRO('infy', 'L') ;

-- CALL STP_STAG23_1KWINSERT('airtel', 'H', 2) ;
CALL STP_STAG23_MICRO('airtel', 'H') ;

-- CALL STP_STAG23_1KWINSERT('airtel', 'L', 2) ;
CALL STP_STAG23_MICRO('airtel', 'L') ;

-- CALL STP_STAG23_1KWINSERT('anilambani', 'H', 2) ;
CALL STP_STAG23_MICRO('anilambani', 'H') ;

-- CALL STP_STAG23_1KWINSERT('anilambani', 'L', 2) ;
CALL STP_STAG23_MICRO('anilambani', 'L') ;

-- CALL STP_STAG23_1KWINSERT('birla', 'H', 2) ;
CALL STP_STAG23_MICRO('birla', 'H') ;

-- CALL STP_STAG23_1KWINSERT('birla', 'L', 2) ;
CALL STP_STAG23_MICRO('birla', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ril', 'H', 2) ;
CALL STP_STAG23_MICRO('ril', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ril', 'L', 2) ;
CALL STP_STAG23_MICRO('ril', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tata', 'H', 3) ;
CALL STP_STAG23_MICRO('tata', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tata', 'L', 3) ;
CALL STP_STAG23_MICRO('tata', 'L') ;

/* 091920 AST: COMPLETING THE ADDITION OF BUSINESSNEWS4 */

CALL STP_STAG23_MICRO('businessnews4', 'L') ;

CALL STP_STAG23_MICRO('businessnews4', 'H') ;



/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T4IND', 'BUSINESS', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
  
END; //
 DELIMITER ;
 
 -- 
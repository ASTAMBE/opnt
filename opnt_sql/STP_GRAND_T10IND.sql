
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T10IND //
CREATE PROCEDURE STP_GRAND_T10IND()
THISPROC: BEGIN

/* 

05/07/2019 AST: replaced   AND SCRAPE_TAG1 = 'BOLLYWOOD'   with  AND SCRAPE_TOPIC IN ('CELEB', 'ENT')  
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/05/2020 AST: Adding the tagging of 25 untagged scrapes to CELEB NEWS KW
10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'srk'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHAH-RUKH%'     
OR UPPER(NEWS_URL) LIKE     '%SRK%' OR UPPER(NEWS_URL) LIKE     '%SHAH%RUKH%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'srk'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHAH-RUKH%'     
OR UPPER(NEWS_URL) LIKE     '%SRK%' OR UPPER(NEWS_URL) LIKE     '%SHAH%RUKH%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kangana'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KANGANA%'     
OR UPPER(NEWS_URL) LIKE     '%RANAUT%' ) AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')        AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kangana'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KANGANA%'     
OR UPPER(NEWS_URL) LIKE     '%RANAUT%' ) AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')        AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'salman'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALMAN%'     
OR UPPER(NEWS_URL) LIKE     '%SALLU%' OR UPPER(NEWS_URL) LIKE     '%TIGER%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'salman'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALMAN%'     
OR UPPER(NEWS_URL) LIKE     '%SALLU%'  OR UPPER(NEWS_URL) LIKE     '%TIGER%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aamir'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AAMIR%'     
OR UPPER(NEWS_URL) LIKE     '%AAMIR%KHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aamir'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AAMIR%'     
OR UPPER(NEWS_URL) LIKE     '%AAMIR%KHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'akshay'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AKSHAY%'     
OR UPPER(NEWS_URL) LIKE     '%AKSHAY%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'akshay'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AKSHAY%'     
OR UPPER(NEWS_URL) LIKE     '%AKSHAY%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'deepika'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEEPIKA%'     
OR UPPER(NEWS_URL) LIKE     '%PADUKON%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'deepika'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEEPIKA%'     
OR UPPER(NEWS_URL) LIKE     '%PADUKON%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hritik'    , SCRAPE_TAG3 = 'L'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HRITHIK%'     
OR UPPER(NEWS_URL) LIKE     '%ROSHAN%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hritik'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HRITHIK%'     
OR UPPER(NEWS_URL) LIKE     '%ROSHAN%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anushka'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ANUSHKA%'     
OR UPPER(NEWS_URL) LIKE     '%USHKA%%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anushka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ANUSHKA%'     
OR UPPER(NEWS_URL) LIKE     '%USHKA%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranveer'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANVEER%'     
OR UPPER(NEWS_URL) LIKE     '%RANVEER%%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranveer'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANVEER%'     
OR UPPER(NEWS_URL) LIKE     '%RANVEER%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'priyanka'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PRIYANKA%'     
OR UPPER(NEWS_URL) LIKE     '%PC%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'priyanka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PRIYANKA%'     
OR UPPER(NEWS_URL) LIKE     '%PC%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranbeer'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANBEER%'     
OR UPPER(NEWS_URL) LIKE     '%RAN%KAPOOR%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranbeer'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANBEER%'     
OR UPPER(NEWS_URL) LIKE     '%RAN%KAPOOR%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'alia'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ALIA%'     
OR UPPER(NEWS_URL) LIKE     '%BHATT%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'alia'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ALIA%'     
OR UPPER(NEWS_URL) LIKE     '%BHATT%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitabh'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMITABH%'     
OR UPPER(NEWS_URL) LIKE     '%BACHCHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitabh'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMITABH%'     
OR UPPER(NEWS_URL) LIKE     '%BACHCHAN%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'madhuri'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MADHURI%'     
OR UPPER(NEWS_URL) LIKE     '%MADHURI%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'madhuri'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MADHURI%'     
OR UPPER(NEWS_URL) LIKE     '%MADHURI%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dharam'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DHARMENDRA%'     
OR UPPER(NEWS_URL) LIKE     '%DEOL%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dharam'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DHARMENDRA%'     
OR UPPER(NEWS_URL) LIKE     '%DEOL%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aish'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AISHWA%'     
OR UPPER(NEWS_URL) LIKE     '%ABHISHEK%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aish'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AISHWA%'     
OR UPPER(NEWS_URL) LIKE     '%ABHISHEK%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'katrina'    , SCRAPE_TAG3 = 'L'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATRINA%'     
OR UPPER(NEWS_URL) LIKE     '%KAIF%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'katrina'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATRINA%'     
OR UPPER(NEWS_URL) LIKE     '%KAIF%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */


-- CALL STP_STAG23_1KWINSERT('srk', 'H', 2) ;
CALL STP_STAG23_MICRO('srk', 'H') ;

-- CALL STP_STAG23_1KWINSERT('srk', 'L', 3) ;
CALL STP_STAG23_MICRO('srk', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kangana', 'H', 2) ;
CALL STP_STAG23_MICRO('kangana', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kangana', 'L', 1) ;
CALL STP_STAG23_MICRO('kangana', 'L') ;

-- CALL STP_STAG23_1KWINSERT('salman', 'H', 3) ;
CALL STP_STAG23_MICRO('salman', 'H') ;

-- CALL STP_STAG23_1KWINSERT('salman', 'L', 3) ;
CALL STP_STAG23_MICRO('salman', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aamir', 'H', 3) ;
CALL STP_STAG23_MICRO('aamir', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aamir', 'L', 3) ;
CALL STP_STAG23_MICRO('aamir', 'L') ;

-- CALL STP_STAG23_1KWINSERT('akshay', 'H', 3) ;
CALL STP_STAG23_MICRO('akshay', 'H') ;

-- CALL STP_STAG23_1KWINSERT('akshay', 'L', 3) ;
CALL STP_STAG23_MICRO('akshay', 'L') ;

-- CALL STP_STAG23_1KWINSERT('deepika', 'H', 3) ;
CALL STP_STAG23_MICRO('deepika', 'H') ;

-- CALL STP_STAG23_1KWINSERT('deepika', 'L', 3) ;
CALL STP_STAG23_MICRO('deepika', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hritik', 'H', 3) ;
CALL STP_STAG23_MICRO('hritik', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hritik', 'L', 3) ;
CALL STP_STAG23_MICRO('hritik', 'L') ;

-- CALL STP_STAG23_1KWINSERT('anushka', 'H', 3) ;
CALL STP_STAG23_MICRO('anushka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('anushka', 'L', 3) ;
CALL STP_STAG23_MICRO('anushka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ranveer', 'H', 1) ;
CALL STP_STAG23_MICRO('ranveer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ranveer', 'L', 1) ;
CALL STP_STAG23_MICRO('ranveer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('priyanka', 'H', 1) ;
CALL STP_STAG23_MICRO('priyanka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('priyanka', 'L', 1) ;
CALL STP_STAG23_MICRO('priyanka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ranbeer', 'H', 1) ;
CALL STP_STAG23_MICRO('ranbeer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ranbeer', 'L', 1) ;
CALL STP_STAG23_MICRO('ranbeer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('alia', 'H', 1) ;
CALL STP_STAG23_MICRO('alia', 'H') ;

-- CALL STP_STAG23_1KWINSERT('alia', 'L', 1) ;
CALL STP_STAG23_MICRO('alia', 'L') ;

-- CALL STP_STAG23_1KWINSERT('amitabh', 'H', 1) ;
CALL STP_STAG23_MICRO('amitabh', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amitabh', 'L', 1) ;
CALL STP_STAG23_MICRO('amitabh', 'L') ;

-- CALL STP_STAG23_1KWINSERT('madhuri', 'H', 1) ;
CALL STP_STAG23_MICRO('madhuri', 'H') ;

-- CALL STP_STAG23_1KWINSERT('madhuri', 'L', 1) ;
CALL STP_STAG23_MICRO('madhuri', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dharam', 'H', 1) ;
CALL STP_STAG23_MICRO('dharam', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dharam', 'L', 1) ;
CALL STP_STAG23_MICRO('dharam', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aish', 'H', 1) ;
CALL STP_STAG23_MICRO('aish', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aish', 'L', 1) ;
CALL STP_STAG23_MICRO('aish', 'L') ;

-- CALL STP_STAG23_1KWINSERT('katrina', 'H', 1) ;
CALL STP_STAG23_MICRO('katrina', 'H') ;

-- CALL STP_STAG23_1KWINSERT('katrina', 'L', 1) ;
CALL STP_STAG23_MICRO('katrina', 'L') ;

/*  Completing the POLNEWS addition with STp MICRo call  */

CALL STP_STAG23_MICRO('CELEBNEWS', 'H') ;

CALL STP_STAG23_MICRO('CELEBNEWS', 'L') ;

/*  END OF Completing the POLNEWS addition with STp MICRo call  */



  
  
  
END; //
 DELIMITER ;
 
 -- 
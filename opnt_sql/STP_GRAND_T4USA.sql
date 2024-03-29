
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T4USA //
CREATE PROCEDURE STP_GRAND_T4USA()
THISPROC: BEGIN

/* 
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

        09/19/2020 AST: Adding BUSINESSNEWS4 STP steps
        10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

-- 

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USABIZ', SCRAPE_TAG2 = 'USABIZ', SCRAPE_TAG3 = 'USABIZ' WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' ;
 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'apple', SCRAPE_TAG3 = 'L'  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%APPLE%'     
OR UPPER(NEWS_URL) LIKE     '%TIM%COOK%'     OR UPPER(NEWS_URL) LIKE     '%IPHONE%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'apple', SCRAPE_TAG3 = 'H'  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%APPLE%'     
OR UPPER(NEWS_URL) LIKE     '%TIM%COOK%'     OR UPPER(NEWS_URL) LIKE     '%IPHONE%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'auto', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TOPIC = 'BUSINESS' AND ( NEWS_URL LIKE '%AUTO%' OR NEWS_URL LIKE '%TOYO%' OR NEWS_URL LIKE '%HOND%' OR NEWS_URL LIKE '%BMW%'
OR NEWS_URL LIKE '%MERC%' OR NEWS_URL LIKE '%-FORD%' OR NEWS_URL LIKE '%GM%' OR NEWS_URL LIKE '%CHRYS%' OR NEWS_URL LIKE '%KIA%'
OR NEWS_URL LIKE '%HYND%' OR NEWS_URL LIKE '%-AUDI-%' OR NEWS_URL LIKE '%PORSCH%' OR NEWS_URL LIKE '%FERRAR%' OR NEWS_URL LIKE '%LAMBORG%' OR NEWS_URL LIKE '%MASERA%'
  OR NEWS_URL LIKE '%NISSAN%' OR NEWS_URL LIKE '%MAZDA%' OR NEWS_URL LIKE '%-CAR-%' OR NEWS_URL LIKE '%VEHICL%' OR NEWS_URL LIKE '%GEN%MOTO%'
  OR NEWS_URL LIKE '%VOLK%' OR NEWS_URL LIKE '%VW%' OR NEWS_URL LIKE '%-AUTOMO%') AND MOD(ROW_ID, 2) = 1;
 
  UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'auto', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TOPIC = 'BUSINESS' AND ( NEWS_URL LIKE '%AUTO%' OR NEWS_URL LIKE '%TOYO%' OR NEWS_URL LIKE '%HOND%' OR NEWS_URL LIKE '%BMW%'
OR NEWS_URL LIKE '%MERC%' OR NEWS_URL LIKE '%-FORD%' OR NEWS_URL LIKE '%GM%' OR NEWS_URL LIKE '%CHRYS%' OR NEWS_URL LIKE '%KIA%'
OR NEWS_URL LIKE '%HYND%' OR NEWS_URL LIKE '%-AUDI-%' OR NEWS_URL LIKE '%PORSCH%' OR NEWS_URL LIKE '%FERRAR%' OR NEWS_URL LIKE '%LAMBORG%' OR NEWS_URL LIKE '%MASERA%'
  OR NEWS_URL LIKE '%NISSAN%' OR NEWS_URL LIKE '%MAZDA%' OR NEWS_URL LIKE '%-CAR-%' OR NEWS_URL LIKE '%VEHICL%' OR NEWS_URL LIKE '%GEN%MOTO%'
  OR NEWS_URL LIKE '%VOLK%' OR NEWS_URL LIKE '%VW%' OR NEWS_URL LIKE '%-AUTOMO%') AND MOD(ROW_ID, 2) = 0;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'msft'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MICROSOFT%'     
OR UPPER(NEWS_URL) LIKE     '%NADEL%'     OR UPPER(NEWS_URL) LIKE     '%LINKEDIN%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'msft'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MICROSOFT%'     
OR UPPER(NEWS_URL) LIKE     '%NADEL%'     OR UPPER(NEWS_URL) LIKE     '%LINKEDIN%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fb'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%FACEBOOK%'     
OR UPPER(NEWS_URL) LIKE     '%ZUCKER%'     OR UPPER(NEWS_URL) LIKE     '%INSTAG%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fb'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%FACEBOOK%'     
OR UPPER(NEWS_URL) LIKE     '%ZUCKER%'     OR UPPER(NEWS_URL) LIKE     '%INSTAG%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'google'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%GOOGLE%'     
OR UPPER(NEWS_URL) LIKE     '%PICHAI%'     OR UPPER(NEWS_URL) LIKE     '%ALPHABET%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'google'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%GOOGLE%'     
OR UPPER(NEWS_URL) LIKE     '%PICHAI%'     OR UPPER(NEWS_URL) LIKE     '%ALPHABET%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orcl'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ORACLE%'     
OR UPPER(NEWS_URL) LIKE     '%LARRY%ELLI%'     OR UPPER(NEWS_URL) LIKE     '%ORCL%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orcl'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ORACLE%'     
OR UPPER(NEWS_URL) LIKE     '%LARRY%ELLI%'     OR UPPER(NEWS_URL) LIKE     '%ORCL%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfdc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALES%FORCE%'     
OR UPPER(NEWS_URL) LIKE     '%BENIOF%'     OR UPPER(NEWS_URL) LIKE     '%CRM%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfdc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALES%FORCE%'     
OR UPPER(NEWS_URL) LIKE     '%BENIOF%'     OR UPPER(NEWS_URL) LIKE     '%CRM%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oil', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TOPIC = 'BUSINESS' AND MOVED_TO_POST_FLAG = 'N' AND
( NEWS_URL LIKE '%OIL%' OR NEWS_URL LIKE '%ENERYGY%' OR NEWS_URL LIKE '%EXXON%' OR NEWS_URL LIKE '%CHEVRON%'
OR NEWS_URL LIKE '%CONOCO%' OR NEWS_URL LIKE '%-SHELL-%' OR NEWS_URL LIKE '%VALERO%' OR NEWS_URL LIKE '%REFINER%' OR NEWS_URL LIKE '%CRUDE%OIL%'
) AND MOD(ROW_ID, 2) = 1;
 
  UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oil', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TOPIC = 'BUSINESS' AND MOVED_TO_POST_FLAG = 'N' AND
( NEWS_URL LIKE '%OIL%' OR NEWS_URL LIKE '%ENERYGY%' OR NEWS_URL LIKE '%EXXON%' OR NEWS_URL LIKE '%CHEVRON%'
OR NEWS_URL LIKE '%CONOCO%' OR NEWS_URL LIKE '%-SHELL-%' OR NEWS_URL LIKE '%VALERO%' OR NEWS_URL LIKE '%REFINER%' OR NEWS_URL LIKE '%CRUDE%OIL%'
) AND MOD(ROW_ID, 2) = 0;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'att'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ATT-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('ATT-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ATT-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'att'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ATT-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('ATT-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ATT-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ccast'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-COMCAST-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-COMCAST%')     OR UPPER(NEWS_URL) LIKE     UPPER('%COMCAST-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ccast'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-COMCAST-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-COMCAST%')     OR UPPER(NEWS_URL) LIKE     UPPER('%COMCAST-%') )      AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'biotech'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-biotech-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-bio%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bio-%') OR UPPER(NEWS_URL) LIKE UPPER('%amgen%') OR UPPER(NEWS_URL) LIKE UPPER('%genen%'))     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'biotech'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-biotech-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-bio%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bio-%') OR UPPER(NEWS_URL) LIKE UPPER('%amgen%') OR UPPER(NEWS_URL) LIKE UPPER('%genen%'))        
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'health'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-health-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%DRUG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%PHARMA%') OR UPPER(NEWS_URL) LIKE UPPER('%MEDICINE%') OR UPPER(NEWS_URL) LIKE UPPER('%MERCK%')
OR UPPER(NEWS_URL) LIKE     UPPER('%PFIZER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%NOVARTIS%') OR UPPER(NEWS_URL) LIKE UPPER('%GLAXO%') OR UPPER(NEWS_URL) LIKE UPPER('%NOVO%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ALLARG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ASTRA%') OR UPPER(NEWS_URL) LIKE UPPER('%RECKITT%') OR UPPER(NEWS_URL) LIKE UPPER('%ROCHE%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ABBOT%')     OR UPPER(NEWS_URL) LIKE     UPPER('%SANOFI%') OR UPPER(NEWS_URL) LIKE UPPER('%JOHN%JOHN%') OR UPPER(NEWS_URL) LIKE UPPER('%LILLY%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'health'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-health-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%DRUG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%PHARMA%') OR UPPER(NEWS_URL) LIKE UPPER('%MEDICINE%') OR UPPER(NEWS_URL) LIKE UPPER('%MERCK%')
OR UPPER(NEWS_URL) LIKE     UPPER('%PFIZER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%NOVARTIS%') OR UPPER(NEWS_URL) LIKE UPPER('%GLAXO%') OR UPPER(NEWS_URL) LIKE UPPER('%NOVO%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ALLARG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ASTRA%') OR UPPER(NEWS_URL) LIKE UPPER('%RECKITT%') OR UPPER(NEWS_URL) LIKE UPPER('%ROCHE%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ABBOT%')     OR UPPER(NEWS_URL) LIKE     UPPER('%SANOFI%') OR UPPER(NEWS_URL) LIKE UPPER('%JOHN%JOHN%') OR UPPER(NEWS_URL) LIKE UPPER('%LILLY%'))        
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'coke'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-coke-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%coca%')     OR UPPER(NEWS_URL) LIKE     UPPER('%cola%') OR UPPER(NEWS_URL) LIKE UPPER('%pepsi%') OR UPPER(NEWS_URL) LIKE UPPER('%beverage%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'coke'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-coke-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%coca%')     OR UPPER(NEWS_URL) LIKE     UPPER('%cola%') OR UPPER(NEWS_URL) LIKE UPPER('%pepsi%') OR UPPER(NEWS_URL) LIKE UPPER('%beverage%'))         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'insurance'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-insurance-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aig-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-aig%') OR UPPER(NEWS_URL) LIKE UPPER('%INSUR%') OR UPPER(NEWS_URL) LIKE UPPER('%state%farm%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'insurance'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-insurance-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aig-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-aig%') OR UPPER(NEWS_URL) LIKE UPPER('%INSUR%') OR UPPER(NEWS_URL) LIKE UPPER('%state%farm%'))         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twtr'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-twtr-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%TWITTER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%DORSEY%') OR UPPER(NEWS_URL) LIKE UPPER('%TWEET%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twtr'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-twtr-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%TWITTER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%DORSEY%') OR UPPER(NEWS_URL) LIKE UPPER('%TWEET%') )         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amzn'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-amzn-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amazon%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bezos%') OR UPPER(NEWS_URL) LIKE UPPER('%whole%food%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amzn'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-amzn-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amazon%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bezos%') OR UPPER(NEWS_URL) LIKE UPPER('%whole%food%') )          
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'disney'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-disney-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%pixar%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-iger-%') OR UPPER(NEWS_URL) LIKE UPPER('%netflix%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'disney'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-disney-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%pixar%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-iger-%') OR UPPER(NEWS_URL) LIKE UPPER('%netflix%') )       
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mcd'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-mcd-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%mcdonald%')     OR UPPER(NEWS_URL) LIKE     UPPER('%fast%food%') OR UPPER(NEWS_URL) LIKE UPPER('%burger%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mcd'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-mcd-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%mcdonald%')     OR UPPER(NEWS_URL) LIKE     UPPER('%fast%food%') OR UPPER(NEWS_URL) LIKE UPPER('%burger%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ge'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ge-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%general%electric%')     OR UPPER(NEWS_URL) LIKE     UPPER('%flannery%') OR UPPER(NEWS_URL) LIKE UPPER('%siemens%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%honeywell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%mmm%') OR UPPER(NEWS_URL) LIKE UPPER('%danaher%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ge'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ge-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%general%electric%')     OR UPPER(NEWS_URL) LIKE     UPPER('%flannery%') OR UPPER(NEWS_URL) LIKE UPPER('%siemens%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%honeywell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%mmm%') OR UPPER(NEWS_URL) LIKE UPPER('%danaher%'))      
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ibm'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ibm-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%dell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ibm-%') OR UPPER(NEWS_URL) LIKE UPPER('%-ibm%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ibm'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ibm-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%dell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ibm-%') OR UPPER(NEWS_URL) LIKE UPPER('%-ibm%') ) 
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tesla'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-tesla-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%musc%')     OR UPPER(NEWS_URL) LIKE     UPPER('%tesla-%') OR UPPER(NEWS_URL) LIKE UPPER('%-tesla%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tesla'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-tesla-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%musc%')     OR UPPER(NEWS_URL) LIKE     UPPER('%tesla-%') OR UPPER(NEWS_URL) LIKE UPPER('%-tesla%') )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'boeing'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-boeing-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aircraft%')     OR UPPER(NEWS_URL) LIKE     UPPER('%boeing-%') OR UPPER(NEWS_URL) LIKE UPPER('%-boeing%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'boeing'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-boeing-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aircraft%')     OR UPPER(NEWS_URL) LIKE     UPPER('%boeing-%') OR UPPER(NEWS_URL) LIKE UPPER('%-boeing%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airline'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-airline-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%air%travel%')     OR UPPER(NEWS_URL) LIKE     UPPER('%airline-%') OR UPPER(NEWS_URL) LIKE UPPER('%-airline%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%united%')     OR UPPER(NEWS_URL) LIKE     UPPER('%southwest%') OR UPPER(NEWS_URL) LIKE UPPER('%delta%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%american%air%')     OR UPPER(NEWS_URL) LIKE     UPPER('%jetblue%') OR UPPER(NEWS_URL) LIKE UPPER('%alaska%air%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airline'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-airline-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%air%travel%')     OR UPPER(NEWS_URL) LIKE     UPPER('%airline-%') OR UPPER(NEWS_URL) LIKE UPPER('%-airline%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%united%')     OR UPPER(NEWS_URL) LIKE     UPPER('%southwest%') OR UPPER(NEWS_URL) LIKE UPPER('%delta%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%american%air%')     OR UPPER(NEWS_URL) LIKE     UPPER('%jetblue%') OR UPPER(NEWS_URL) LIKE UPPER('%alaska%air%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'visa'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-visa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amer%express%')     OR UPPER(NEWS_URL) LIKE     UPPER('%visa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-visa%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'visa'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-visa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amer%express%')     OR UPPER(NEWS_URL) LIKE     UPPER('%visa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-visa%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nike'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-nike-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%footwear%')     OR UPPER(NEWS_URL) LIKE     UPPER('%nike-%') OR UPPER(NEWS_URL) LIKE UPPER('%-nike%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%sporting%')     OR UPPER(NEWS_URL) LIKE     UPPER('%lulu%') OR UPPER(NEWS_URL) LIKE UPPER('%under%armour%')
OR UPPER(NEWS_URL) LIKE     UPPER('%adidas%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nike'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-nike-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%footwear%')     OR UPPER(NEWS_URL) LIKE     UPPER('%nike-%') OR UPPER(NEWS_URL) LIKE UPPER('%-nike%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%sporting%')     OR UPPER(NEWS_URL) LIKE     UPPER('%lulu%') OR UPPER(NEWS_URL) LIKE UPPER('%under%armour%')
OR UPPER(NEWS_URL) LIKE     UPPER('%adidas%')  )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wells'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-wells-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%fargo%')     OR UPPER(NEWS_URL) LIKE     UPPER('%wells-%') OR UPPER(NEWS_URL) LIKE UPPER('%-wells%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%-bank-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%banking%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wells'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-wells-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%fargo%')     OR UPPER(NEWS_URL) LIKE     UPPER('%wells-%') OR UPPER(NEWS_URL) LIKE UPPER('%-wells%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%-bank-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%banking%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bofa'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-bofa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%bank%ameri%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bofa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-bofa%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bofa'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-bofa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%bank%ameri%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bofa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-bofa%') ) 
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chase'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-chase-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%j%morgan%')     OR UPPER(NEWS_URL) LIKE     UPPER('%chase-%') OR UPPER(NEWS_URL) LIKE UPPER('%-chase%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chase'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-chase-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%j%morgan%')     OR UPPER(NEWS_URL) LIKE     UPPER('%chase-%') OR UPPER(NEWS_URL) LIKE UPPER('%-chase%') )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'citi'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-citi-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%citibank%') OR UPPER(NEWS_URL) LIKE  UPPER('%citi-%') OR UPPER(NEWS_URL) LIKE UPPER('%-citi%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'citi'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-citi-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%citibank%') OR UPPER(NEWS_URL) LIKE  UPPER('%citi-%') OR UPPER(NEWS_URL) LIKE UPPER('%-citi%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dupont'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-dupont-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%chemical%') OR UPPER(NEWS_URL) LIKE  UPPER('%dupont-%') OR UPPER(NEWS_URL) LIKE UPPER('%-dupont%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dupont'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-dupont-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%chemical%') OR UPPER(NEWS_URL) LIKE  UPPER('%dupont-%') OR UPPER(NEWS_URL) LIKE UPPER('%-dupont%') )       
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pg'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-proctor-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-gamble-%') OR UPPER(NEWS_URL) LIKE  UPPER('%clorox%') OR UPPER(NEWS_URL) LIKE UPPER('%lever%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pg'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-proctor-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-gamble-%') OR UPPER(NEWS_URL) LIKE  UPPER('%clorox%') OR UPPER(NEWS_URL) LIKE UPPER('%lever%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-macy-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-retail-%') OR UPPER(NEWS_URL) LIKE  UPPER('%penney%') OR UPPER(NEWS_URL) LIKE UPPER('%shopper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-macy-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-retail-%') OR UPPER(NEWS_URL) LIKE  UPPER('%penney%') OR UPPER(NEWS_URL) LIKE UPPER('%shopper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-sears-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-k-mart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%kmart%') OR UPPER(NEWS_URL) LIKE UPPER('%kenmore%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-sears-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-k-mart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%kmart%') OR UPPER(NEWS_URL) LIKE UPPER('%kenmore%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wmt'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-wmt-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-walmart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%walton%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wmt'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-wmt-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-walmart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%walton%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cisco'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-cisco-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-networking-%') OR UPPER(NEWS_URL) LIKE  UPPER('%juniper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cisco'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-cisco-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-networking-%') OR UPPER(NEWS_URL) LIKE  UPPER('%juniper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'snap'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-snap-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-snapchat-%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'snap'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-snap-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-snapchat-%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;



/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('snap', 'L', 1) ;
CALL STP_STAG23_MICRO('snap', 'L') ;

-- CALL STP_STAG23_1KWINSERT('snap', 'H', 1) ;
CALL STP_STAG23_MICRO('snap', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cisco', 'L', 1) ;
CALL STP_STAG23_MICRO('cisco', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cisco', 'H', 1) ;
CALL STP_STAG23_MICRO('cisco', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wmt', 'L', 1) ;
CALL STP_STAG23_MICRO('wmt', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wmt', 'H', 1) ;
CALL STP_STAG23_MICRO('wmt', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sears', 'L', 1) ;
CALL STP_STAG23_MICRO('sears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sears', 'H', 1) ;
CALL STP_STAG23_MICRO('sears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('macy', 'L', 1) ;
CALL STP_STAG23_MICRO('macy', 'L') ;

-- CALL STP_STAG23_1KWINSERT('macy', 'H', 1) ;
CALL STP_STAG23_MICRO('macy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pg', 'L', 1) ;
CALL STP_STAG23_MICRO('pg', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pg', 'H', 1) ;
CALL STP_STAG23_MICRO('pg', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dupont', 'L', 1) ;
CALL STP_STAG23_MICRO('dupont', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dupont', 'H', 1) ;
CALL STP_STAG23_MICRO('dupont', 'H') ;

-- CALL STP_STAG23_1KWINSERT('citi', 'L', 1) ;
CALL STP_STAG23_MICRO('citi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('citi', 'H', 1) ;
CALL STP_STAG23_MICRO('citi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chase', 'L', 1) ;
CALL STP_STAG23_MICRO('chase', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chase', 'H', 1) ;
CALL STP_STAG23_MICRO('chase', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bofa', 'L', 1) ;
CALL STP_STAG23_MICRO('bofa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bofa', 'H', 1) ;
CALL STP_STAG23_MICRO('bofa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wells', 'L', 1) ;
CALL STP_STAG23_MICRO('wells', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wells', 'H', 1) ;
CALL STP_STAG23_MICRO('wells', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nike', 'L', 1) ;
CALL STP_STAG23_MICRO('nike', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nike', 'H', 1) ;
CALL STP_STAG23_MICRO('nike', 'H') ;

-- CALL STP_STAG23_1KWINSERT('visa', 'L', 1) ;
CALL STP_STAG23_MICRO('visa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('visa', 'H', 1) ;
CALL STP_STAG23_MICRO('visa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('airline', 'L', 1) ;
CALL STP_STAG23_MICRO('airline', 'L') ;

-- CALL STP_STAG23_1KWINSERT('airline', 'H', 1) ;
CALL STP_STAG23_MICRO('airline', 'H') ;

-- CALL STP_STAG23_1KWINSERT('boeing', 'L', 1) ;
CALL STP_STAG23_MICRO('boeing', 'L') ;

-- CALL STP_STAG23_1KWINSERT('boeing', 'H', 1) ;
CALL STP_STAG23_MICRO('boeing', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tesla', 'L', 1) ;
CALL STP_STAG23_MICRO('tesla', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tesla', 'H', 1) ;
CALL STP_STAG23_MICRO('tesla', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ibm', 'L', 1) ;
CALL STP_STAG23_MICRO('ibm', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ibm', 'H', 1) ;
CALL STP_STAG23_MICRO('ibm', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ge', 'L', 1) ;
CALL STP_STAG23_MICRO('ge', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ge', 'H', 1) ;
CALL STP_STAG23_MICRO('ge', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mcd', 'L', 1) ;
CALL STP_STAG23_MICRO('mcd', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mcd', 'H', 1) ;
CALL STP_STAG23_MICRO('mcd', 'H') ;

-- CALL STP_STAG23_1KWINSERT('disney', 'L', 1) ;
CALL STP_STAG23_MICRO('disney', 'L') ;

-- CALL STP_STAG23_1KWINSERT('disney', 'H', 1) ;
CALL STP_STAG23_MICRO('disney', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amzn', 'L', 1) ;
CALL STP_STAG23_MICRO('amzn', 'L') ;

-- CALL STP_STAG23_1KWINSERT('amzn', 'H', 1) ;
CALL STP_STAG23_MICRO('amzn', 'H') ;

-- CALL STP_STAG23_1KWINSERT('twtr', 'L', 1) ;
CALL STP_STAG23_MICRO('twtr', 'L') ;

-- CALL STP_STAG23_1KWINSERT('twtr', 'H', 1) ;
CALL STP_STAG23_MICRO('twtr', 'H') ;

-- CALL STP_STAG23_1KWINSERT('insurance', 'L', 1) ;
CALL STP_STAG23_MICRO('insurance', 'L') ;

-- CALL STP_STAG23_1KWINSERT('insurance', 'H', 1) ;
CALL STP_STAG23_MICRO('insurance', 'H') ;

-- CALL STP_STAG23_1KWINSERT('coke', 'L', 1) ;
CALL STP_STAG23_MICRO('coke', 'L') ;

-- CALL STP_STAG23_1KWINSERT('coke', 'H', 1) ;
CALL STP_STAG23_MICRO('coke', 'H') ;

-- CALL STP_STAG23_1KWINSERT('health', 'L', 1) ;
CALL STP_STAG23_MICRO('health', 'L') ;

-- CALL STP_STAG23_1KWINSERT('health', 'H', 1) ;
CALL STP_STAG23_MICRO('health', 'H') ;

-- CALL STP_STAG23_1KWINSERT('biotech', 'L', 1) ;
CALL STP_STAG23_MICRO('biotech', 'L') ;

-- CALL STP_STAG23_1KWINSERT('biotech', 'H', 1) ;
CALL STP_STAG23_MICRO('biotech', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ccast', 'H', 3) ;
CALL STP_STAG23_MICRO('ccast', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ccast', 'L', 3) ;
CALL STP_STAG23_MICRO('ccast', 'L') ;

-- CALL STP_STAG23_1KWINSERT('att', 'H', 3) ;
CALL STP_STAG23_MICRO('att', 'H') ;

-- CALL STP_STAG23_1KWINSERT('att', 'L', 3) ;
CALL STP_STAG23_MICRO('att', 'L') ;

-- CALL STP_STAG23_1KWINSERT('apple', 'L', 1) ;
CALL STP_STAG23_MICRO('apple', 'L') ;

-- CALL STP_STAG23_1KWINSERT('apple', 'H', 1) ;
CALL STP_STAG23_MICRO('apple', 'H') ;
 
-- CALL STP_STAG23_1KWINSERT('auto', 'L', 1) ;
CALL STP_STAG23_MICRO('auto', 'L') ;

-- CALL STP_STAG23_1KWINSERT('auto', 'H', 1) ;
CALL STP_STAG23_MICRO('auto', 'H') ;

-- CALL STP_STAG23_1KWINSERT('msft', 'L', 1) ;
CALL STP_STAG23_MICRO('msft', 'L') ;

-- CALL STP_STAG23_1KWINSERT('msft', 'H', 1) ;
CALL STP_STAG23_MICRO('msft', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fb', 'L', 1) ;
CALL STP_STAG23_MICRO('fb', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fb', 'H', 1) ;
CALL STP_STAG23_MICRO('fb', 'H') ;

-- CALL STP_STAG23_1KWINSERT('google', 'L', 1) ;
CALL STP_STAG23_MICRO('google', 'L') ;

-- CALL STP_STAG23_1KWINSERT('google', 'H', 1) ;
CALL STP_STAG23_MICRO('google', 'H') ;

-- CALL STP_STAG23_1KWINSERT('orcl', 'L', 1) ;
CALL STP_STAG23_MICRO('orcl', 'L') ;

-- CALL STP_STAG23_1KWINSERT('orcl', 'H', 1) ;
CALL STP_STAG23_MICRO('orcl', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sfdc', 'L', 1) ;
CALL STP_STAG23_MICRO('sfdc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sfdc', 'H', 1) ;
CALL STP_STAG23_MICRO('sfdc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('oil', 'L', 1) ;
CALL STP_STAG23_MICRO('oil', 'L') ;

-- CALL STP_STAG23_1KWINSERT('oil', 'H', 1) ;
CALL STP_STAG23_MICRO('oil', 'H') ;

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
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T4USA', 'BUSINESS', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
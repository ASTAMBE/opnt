-- TO CHECK THE SCRAPE COUNTS IN WSRL 
SET SQL_SAFE_UPDATES = 0;
SELECT SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1) FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 1 DAY GROUP BY SCRAPE_TOPIC, COUNTRY_CODE ;
SELECT SCRAPE_DATE, SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW_L GROUP BY SCRAPE_DATE, SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1, 2 DESC ;

-- THEN CHECK THE DETAILS OF A SPECIFIC COMBO
SELECT * FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 1 DAY AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC = 'SPORTS' ORDER BY ROW_ID DESC ;


-- TO COMPARE THE PROC LENGTH AND RECENCY - BETN PROD AND DEV AND TO COMPARE THE TABLE STRUCTURES

SELECT ROUTINE_TYPE, ROUTINE_NAME, LAST_ALTERED, LENGTH(ROUTINE_DEFINITION) RLEN FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' ORDER BY 2 DESC  ;
SELECT TRIGGER_NAME, EVENT_OBJECT_TABLE, CREATED, LENGTH(ACTION_STATEMENT) TLEN FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = 'opntprod' ORDER BY 1 ;

SELECT TABLE_NAME, COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'opntprod' GROUP BY TABLE_NAME ORDER BY 1 DESC ;
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'opntprod' AND TABLE_NAME = 'WEB_SCRAPE_RAW_L' ORDER BY 1 ;

SELECT * FROM OPN_USERLIST WHERE USERNAME LIKE 'ANDRAST%' ;
DELETE FROM WEB_SCRAPE_RAW_L WHERE SCRAPE_DATE < '2023-12-17' ;
-- 

CALL showInitialKWs(bringUUID(1026625), 1, 0, 20) ;
CALL showInitialDiscussions(bringUUID(1026625), 1, 0, 20) ;

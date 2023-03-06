SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;

SELECT ROUTINE_TYPE, ROUTINE_NAME, LAST_ALTERED, LENGTH(ROUTINE_DEFINITION) LPROC 
FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' ORDER BY 3 DESC ;

SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, LENGTH(ACTION_STATEMENT) LTRIG
FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = 'opntprod' ;

SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' AND ROUTINE_NAME = 'createSearchKW' ;

UPDATE INFORMATION_SCHEMA.ROUTINES SET DEFINER = 'root' where ROUTINE_SCHEMA = 'opntprod' AND ROUTINE_NAME = 'createSearchKW' ;

SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' LIMIT 1000 ;

SELECT ROUTINE_TYPE, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod'
AND ROUTINE_DEFINITION LIKE '%networkUpdate%' ;

SELECT ROUTINE_TYPE, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod'
AND ROUTINE_DEFINITION LIKE '%80005%' ;

SELECT TRIGGER_NAME, EVENT_MANIPULATION TTYPE, EVENT_OBJECT_TABLE TTABLE, LENGTH(ACTION_STATEMENT) LTRIG
FROM INFORMATION_SCHEMA.TRIGGERS WHERE TRIGGER_SCHEMA = 'opntprod' ;

SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 	'opntprod' 
AND TABLE_NAME IN ('OPN_POSTS', 'OPN_P_KW', 'OPN_KW_TAGS', 'OPN_USER_POST_ACTION', 'OPN_USER_BHV_LOG', 'OPN_RAW_LOGS') ORDER BY 1,3;
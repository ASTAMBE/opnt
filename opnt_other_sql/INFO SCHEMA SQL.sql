SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;

SELECT ROUTINE_TYPE, ROUTINE_NAME, LENGTH(ROUTINE_DEFINITION) LPROC 
FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'charcha' ORDER BY 2 ;

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

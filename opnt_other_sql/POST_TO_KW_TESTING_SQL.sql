-- Debugging the Post to KW process

-- Documenting the existing post L/H process:
SELECT * FROM OPN_USER_POST_ACTION ORDER BY ROW_ID DESC ; -- 43338/1172403/actionby 1020345
SELECT * FROM OPN_USER_BHV_LOG ORDER BY ROW_ID DESC ; -- 250167
-- now canceling the L for that post (43338 was deleted)
SELECT * FROM OPN_UPA_DELETED ORDER BY ROW_ID DESC ; -- 1284/ THIS TABLE STORES ALL THE DATA ABOUT THE DELETED ACTION (! AM I SMART OR WHAT)
-- NOW WE DO L FOR THE SAME POST AGAIN : OUPA: 43339 OUBL: 250169:CONCAT 1020345 - POST -L1 FOR POST_ID = 1172403
-- NOW WE WILL DO A SWITCH FROM H TO L : OUPA: 43340, OUBL: TWO ROWS: 1020345 - POST -L0 FOR POST_ID = 1172403 AND 1020345 - POST -H1 FOR POST_ID = 1172403
-- OUD: 1285: 43339 GOT DELETED AND LOGGED IN THIS TABLE
-- The old functionality is working fine in the Store version

-- Now let's turn on the POST TO KW  functionality

/* step 1: check if the following objects are identical in prod and dev
OPN_POSTS, OPN_P_KW, OPN_KW_TAGS, OPN_USER_POST_ACTION, OPN_USER_BHV_LOG, OPN_RAW_LOGS
*/
ALTER TABLE `opntprod`.`OPN_KW_TAGS` ADD COLUMN `KW_URL` LONGTEXT NULL AFTER `KW_EXT` ;
ALTER TABLE `opntprod`.`OPN_P_KW` ADD COLUMN `KW_URL` LONGTEXT NULL AFTER `KW_EXT` ;

ALTER TABLE `opntprod`.`OPN_KW_TAGS` 
CHANGE COLUMN `KEYWORDS` `KEYWORDS` VARCHAR(160) NULL DEFAULT NULL ,
CHANGE COLUMN `KW_TRIM` `KW_TRIM` VARCHAR(160) NULL DEFAULT NULL ;
/* step 2: Now that both the databases have identical structures for the key tables
2.1. We change or create the Procs: userActionCommon, convertPostToKW, getUserCarts
2.2. we change/build the triggers: POST_TO_KW_INSERT, POST_ACTION_DELETE

*/

SELECT ROUTINE_TYPE, ROUTINE_NAME, LAST_ALTERED, LENGTH(ROUTINE_DEFINITION) LPROC 
FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' ORDER BY 3 DESC ;

SELECT ROUTINE_TYPE, ROUTINE_NAME, LAST_ALTERED, LENGTH(ROUTINE_DEFINITION) LPROC 
FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'opntprod' ORDER BY 3 DESC ;


-- 1. click L on any new post (so that it is not already turned into a kw) in the instream in Politics then check if:

-- 1.1. The OPN_USER_POST_ACTION has a new row with KEYID NULL - Note down the ROW_ID
SELECT * FROM OPN_USER_POST_ACTION ORDER BY ROW_ID DESC ; -- 44172/1147784
-- 1.2. OPN_USER_BHV_LOG has 2 new rows - One for userPostLH (userActionCommon) and one for convertPostToKW
SELECT * FROM OPN_USER_BHV_LOG ORDER BY ROW_ID DESC ; -- 164939
-- 1.3. OPN_RAW_LOGS has 4 new rows
SELECT * FROM OPN_RAW_LOGS ORDER BY ROW_ID DESC ;
-- 1.4. OPN_USER_CARTS  has 1 new row
SELECT * FROM OPN_USER_CARTS WHERE USERID = 1020345 AND TOPICID = 10  ;  -- CART IS NULL ;
SELECT * FROM OPN_POSTS WHERE POST_ID IN (1172319) ; -- KID 107624
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;
SELECT * FROM OPN_KW_TAGS ORDER BY KEYID DESC ;

-- 2. Canceling an existing L/H from a post
/*  When this happens, the POST TO KW would have already happened. This action should only delete rows from
OPN_USER_POST_ACTION and OPN_USER_CARTS */




CALL userActionCommon(bringUUID(1020162), 'POST', 'H1', 1154780) ; 

SELECT * FROM OPN_POSTS WHERE POST_ID IN (1155270,1155281,1154913,1154905,1154893,1154891, 1155279, 1155266, 1147784) ;
SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;
SELECT * FROM OPN_KW_TAGS ORDER BY KEYID DESC ;
UPDATE OPN_USER_CARTS SET CART = 'H' WHERE CART IS NULL ;
SELECT * FROM OPN_RAW_LOGS ORDER BY ROW_ID DESC ;

SELECT * FROM OPN_USER_CARTS WHERE USERID = 1020162 AND TOPICID = 1  ;  -- CART IS NULL ;

/* 1. when user clicks H/L for a post for the first time:
 the action from the app will call userActionCommon : confirm that

 1.1: OPN_P_KW amd OPN_KW_TAGS get new rows
 1.2: OPN_RAW_LOGS and OPN_USER_BHV_LOG get new rows
 1.3: whether the OPN_USER_POST_ACTION GETS A NEW ROW
 1.4: POST_TO_KW trgigger gets fired --> this should add one more row in OPN_RAW_LOGS
 1.5: 
 
 
 
 */
 
 CALL getInstreamNW(bringUUID(1020162), 1, 0, 60) ; 
 
 CALL userActionCommon(bringUUID(1020162), 'POST', 'H1', 1154913) ;  -- 1154905
 

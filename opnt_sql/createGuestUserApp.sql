-- 

DROP PROCEDURE IF EXISTS `createGuestUserApp`;
DELIMITER //
CREATE   PROCEDURE `createGuestUserApp`(devicename varchar(600), country_code varchar(5), device_serial VARCHAR(40), tcc varchar(5))
BEGIN

/*    10172020 AST: Recreated with Default Cart assignment 

            01/24/2023 AST: Commented out the XYZ News insertion - for Dev only
            03/27/2023 AST: Adding tcc (TRUE_COUNTRY_CODE) to start logging the actual country code of the thousands of the GGG users

*/


DECLARE RND4DIGIT, RND6DIGIT, DNAMEOK, G1OK, G2OK INT ;
DECLARE GUESTUNAME1, GUESTUNAME2 VARCHAR(30) ;
/* 04012018 AST: The below portion is added in order to track the device_serial of the user */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

/* 04012018 AST: End of device_serial addition for declarations */
/*
SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;
*/
SET RND4DIGIT = FLOOR(RAND()* (9999-1000) +1000);
SET RND6DIGIT = FLOOR(RAND()* (999999-100000) +100000);

SET GUESTUNAME1 = CONCAT(SUBSTR(devicename,1,6), RND4DIGIT);
SET GUESTUNAME2 = CONCAT(SUBSTR(devicename,1,6), RND6DIGIT);

SET DNAMEOK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6));
SET G1OK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1);
-- SET G2OK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2);

CASE WHEN DNAMEOK = 0 THEN

INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE, TRUE_COUNTRY_CODEE) 
VALUES (SUBSTR(devicename,1,6), AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST', tcc);

/* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6) )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6) ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case DNAMEOK = 0 */

/* 10172020 AST: Adding the default Cart below */

/*
INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

*/

/* 10172020 AST: END OF : Adding the default Cart */

SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6);

WHEN DNAMEOK = 1 THEN

	CASE WHEN G1OK = 0 THEN
    
    INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE, TRUE_COUNTRY_CODE) 
	VALUES (GUESTUNAME1, AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST', tcc);
    
    /* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1 )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1 ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case G1OK = 0 */

/* 10172020 AST: Adding the default Cart below */

/*

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

*/

/* 10172020 AST: END OF : Adding the default Cart */
    
    SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1;
    
		WHEN G1OK = 1 THEN 
            
            INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE, TRUE_COUNTRY_CODE) 
			VALUES (GUESTUNAME2, AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST', tcc);
            
                /* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2 )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2 ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case G1OK = 1 */

/* 10172020 AST: Adding the default Cart below */

/*

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;
*/

/* 10172020 AST: END OF : Adding the default Cart */
            
                SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2;
            
            END CASE;
            
		END CASE ;

END//
DELIMITER ;

-- 
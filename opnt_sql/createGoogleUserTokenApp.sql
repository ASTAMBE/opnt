-- createGoogleUserTokenApp

 DELIMITER //
DROP PROCEDURE IF EXISTS createGoogleUserTokenApp //
CREATE PROCEDURE createGoogleUserTokenApp(username varchar(30), country_code varchar(5), fname varchar(150)
, lname varchar(150), google_email varchar(250), dp_url varchar(500) 
, Google_username varchar(100), Google_userid varchar(45), device_serial VARCHAR(40))
BEGIN

/* 04012018 AST: Added insret into proc log 
    Added insert into device log 
    
    10172020 AST: Recreated with Default Cart assignment 
        		12102020 AST: Default Cart is done through vars now - instead of hard -code
        This is to ensure that the ptoc will work in any db instance
        
	09/29/2021 AST: Changed the 'POLNEWS' to 'politicsnews1'
    
    */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'politicsnews1' ) ;
/*
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;
*/

CASE WHEN Google_userid IS NOT NULL THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('createGoogleUserTokenApp', NOW(), 'USERNAME', username) ;

INSERT INTO OPN_USERLIST(USERNAME, USER_UUID, CREATION_DATE, COUNTRY_CODE, FIRST_NAME
, LAST_NAME, EMAIL_ADDR, G_UNAME, G_USERID, FB_USER_FLAG, DP_URL)
VALUES (username, UUID(), NOW(), country_code, fname, lname, google_email, Google_username, Google_userid, 'G' , dp_url);

SET DEVICE_UUID = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = username);

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUseridFromUsername(username), DEVICE_UUID, NOW(), device_serial, 'Y');

END CASE;

/* 10172020 AST: Adding the default Cart below */

set UID = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USERNAME = username) ;

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW())
/*, (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
*/
;

/* 10172020 AST: END OF : Adding the default Cart */

SELECT U.USER_UUID AS USERID, U.USERNAME, U.COUNTRY_CODE FROM OPN_USERLIST U WHERE U.USERNAME = username;

END //
DELIMITER ;

-- 


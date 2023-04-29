-- createGoogleUserTokenApp

 DELIMITER //
DROP PROCEDURE IF EXISTS createGoogleUserTokenApp //
CREATE PROCEDURE createGoogleUserTokenApp(username varchar(30), country_code varchar(5), fname varchar(150)
, lname varchar(150), google_email varchar(250), dp_url varchar(500) 
, Google_username varchar(100), Google_userid varchar(45), device_serial VARCHAR(40) -- , tcc varchar(5)
)
BEGIN

/* 04012018 AST: Added insret into proc log 
    Added insert into device log 
    
    10172020 AST: Recreated with Default Cart assignment 
        		12102020 AST: Default Cart is done through vars now - instead of hard -code
        This is to ensure that the ptoc will work in any db instance
        
	09/29/2021 AST: Changed the 'POLNEWS' to 'politicsnews1'
    
            01/24/2023 AST: Commented out the XYZ News insertion - for Dev only
            03/27/2023 AST: Adding tcc (TRUE_COUNTRY_CODE) to start logging the actual country code of the thousands of the GGG users
            
	04/24/2023 AST: Adding CASE to accept non-GGG country codes
    
    */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;
declare ccode, tcc varchar(5) ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'politicsnews1' ) ;

SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;


CASE WHEN country_code IN ('GGG', 'IND', 'USA') THEN SET ccode = country_code ;
SET tcc = country_code ;
WHEN country_code NOT IN ('GGG', 'IND', 'USA') THEN SET ccode = 'GGG' ;
SET tcc = country_code ;

END CASE ;

CASE WHEN Google_userid IS NOT NULL THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('createGoogleUserTokenApp', NOW(), 'USERNAME', username) ;

INSERT INTO OPN_USERLIST(USERNAME, USER_UUID, CREATION_DATE, COUNTRY_CODE, FIRST_NAME
, LAST_NAME, EMAIL_ADDR, G_UNAME, G_USERID, FB_USER_FLAG, DP_URL, TRUE_COUNTRY_CODE)
VALUES (username, UUID(), NOW(), ccode, fname, lname, google_email, Google_username, Google_userid, 'G' , dp_url, tcc);

-- VALUES (username, UUID(), NOW(), ccode, fname, lname, google_email, Google_username, Google_userid, 'G' , dp_url, tcc);

SET DEVICE_UUID = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = username);

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUseridFromUsername(username), DEVICE_UUID, NOW(), device_serial, 'Y');

END CASE;




set UID = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USERNAME = username) ;


INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW())
, (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;





SELECT U.USER_UUID AS USERID, U.USERNAME, U.COUNTRY_CODE FROM OPN_USERLIST U WHERE U.USERNAME = username;

END //
DELIMITER ;

-- 


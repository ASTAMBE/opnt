-- postCleaner

DELIMITER //
DROP PROCEDURE IF EXISTS postCleaner //
CREATE PROCEDURE postCleaner(postid INT )
BEGIN

/*

01/06/2022 : Initial Creation AST: 

This script is created in order to turn an unclean post into a clean post. This is to be used only as 
part of admin duties. Only those posts that have been deemed unclean because the domain in them is not 
whitelisted yet, but is actually a clean domain.

*/

DECLARE POSTCONTENT VARCHAR(2000) ;

SELECT POST_CONTENT INTO POSTCONTENT FROM OPN_POSTS_RAW WHERE POST_ID = postid ;

UPDATE OPN_POSTS SET POST_CONTENT = POSTCONTENT, CLEAN_POST_FLAG = 'Y' WHERE POST_ID = postid ;

INSERT INTO OPN_ADMIN_ACTIONS(ADMIN_UNAME, ACTION_DATE, API_CALL, SQL_PASSED)
VALUES('DEFAULT_ADMIN',  CURRENT_DATE(), 'CALL postCleaner(postid)'
, CONCAT("UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' WHERE POST_ID = ", postid) ) ;
  
  
END; //
 DELIMITER ;
 
 -- 
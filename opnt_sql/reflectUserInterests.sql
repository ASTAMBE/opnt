-- reflectUserInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS reflectUserInterests //
CREATE PROCEDURE reflectUserInterests(uuid varchar(45))
BEGIN

/* 	

09/19/2024 AST: This proc is created as the aftermath of the saveUserInterests so that the changes made 
by the user in the interest selection can be reflected in the carts and any other downstream objects.
At least, the interests that were dropped by the user have to be removed from the user's cart.
Also the networkUpdate should be reflecting the latest cart situation after the interest changes

*/

declare  orig_uid, pbuid INT;
declare uname, intName varchar(40) ;
declare intCode varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USERNAME INTO orig_uid, uname FROM OPN_USERLIST WHERE USER_UUID = uuid ;

-- DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid ;

DELETE FROM OPN_USER_CARTS WHERE USERID = orig_uid
AND TOPICID NOT IN (SELECT INTEREST_ID FROM OPN_USER_INTERESTS WHERE USERID = orig_uid) ;


END //
DELIMITER ;

-- 
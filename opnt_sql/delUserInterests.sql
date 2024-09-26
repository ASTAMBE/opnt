-- delUserInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS delUserInterests //
CREATE PROCEDURE delUserInterests(userid varchar(45))
BEGIN
/*  
 09/18/2024 AST: This proc is created equivalent to the insertCartDelQ. To delete the user interests 
 after every save button click on the cart screen. This will be done prior to the saveUserInterests
 */
declare  orig_uid, pbuid INT;

SET orig_uid = (SELECT  bringUserid(userid));
-- SET @Ppbuid := (SELECT bringUseridFromUsername(postuserid));

DELETE FROM OPN_USER_INTERESTS OSU WHERE OSU.USERID = orig_uid ;  

END //
DELIMITER ;

-- 
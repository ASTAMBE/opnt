-- TCC complete testing - including sfc, disucssion clicks, adding/removing interests, new user etc

-- case 1: Creating a new user:

SELECT * FROM OPN_USERLIST ORDER BY USERID DESC ;
SELECT * FROM OPN_USER_BHV_LOG ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_USER_INTERESTS WHERE USERID IN ()  ;
SELECT * FROM OPN_USER_CARTS WHERE USERID IN ()   ;
SELECT TOPICID, COUNT(1) FROM OPN_USER_CARTS WHERE USERID IN ()   ;
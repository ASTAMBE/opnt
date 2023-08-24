-- POST_NW_NOTIF_TRIGGER

DELIMITER $$
DROP TRIGGER IF EXISTS POST_NW_NOTIF_TRIGGER $$
CREATE TRIGGER POST_NW_NOTIF_TRIGGER
AFTER INSERT ON OPN_POSTS for each row
begin

/* WITHOUT TOKEN EXIST FILTER

INSERT INTO OPN_PUSH_LAUNCH(USERID, USER_UUID, APP_TOKEN, USER_PLATFORM, PUSH_TYPE, PUSH_COUNT)
SELECT USERID, USER_UUID, IDENTIFIER_TOKEN, LAST_USED_PLATFORM, 'POST', 1  FROM OPN_USERLIST WHERE USERID IN 
(SELECT DISTINCT USERID FROM OPN_NC_CLUSTERS WHERE CLUSTER_ID IN 
(SELECT RELATED_CLUSTER_ID FROM OPN_CLUSTER_RELATIONSHIPS WHERE CLUSTER_ID IN 
(SELECT CLUSTER_ID FROM OPN_NC_CLUSTERS WHERE USERID = NEW.POST_BY_USERID AND TOPICID = NEW.TOPICID)));

	06/14/2020 AST: Added WHEN NEW.TOPICID = 11 THEN SET POSTTOPIC = 'Health' ;
    06/17/2020 AST: Fixed the NW to use the true network
    06/25/2020 AST: Added DISTINCT to the NW query
    
    07/14/2020 AST: Adding the INSERT for the post search infra
    07/23/2020 AST: Added POST_BY_UNAME to the search string
    08/27/2020 AST: added SOURCE_ID AND PUSH_TITLE 
    
    08/12/2023 AST: Commenting out the OPN_PUSH_LAUNCH INSERT portion because thetable has become runaway.

*/

DECLARE POSTTOPIC, PBYUNAME VARCHAR(30) ;
DECLARE POST_EXCRPT VARCHAR(150) ;
DECLARE KW VARCHAR(300) ;



CASE WHEN NEW.TOPICID = 1 THEN SET POSTTOPIC = 'Politics' ;
WHEN NEW.TOPICID = 2 THEN SET POSTTOPIC = 'Sports/Games' ;
WHEN NEW.TOPICID = 3 THEN SET POSTTOPIC = 'Science/Tech' ;
WHEN NEW.TOPICID = 4 THEN SET POSTTOPIC = 'Business' ;
WHEN NEW.TOPICID = 5 THEN SET POSTTOPIC = 'Media/Ent.' ;
WHEN NEW.TOPICID = 6 THEN SET POSTTOPIC = 'Religion' ;
WHEN NEW.TOPICID = 7 THEN SET POSTTOPIC = 'Life' ;
WHEN NEW.TOPICID = 8 THEN SET POSTTOPIC = 'Miscellaneous' ;
WHEN NEW.TOPICID = 9 THEN SET POSTTOPIC = 'Trending' ;
WHEN NEW.TOPICID = 10 THEN SET POSTTOPIC = 'Celebrities' ;
WHEN NEW.TOPICID = 11 THEN SET POSTTOPIC = 'Health' ;

END CASE;

SET POST_EXCRPT = (SELECT substring(NEW.POST_CONTENT, 1, 140));

CASE WHEN NEW.TAG1_KEYID IS NULL THEN 

SET KW = NULL ;

WHEN NEW.TAG1_KEYID IS NOT NULL THEN 

SET KW = (SELECT KEYWORDS FROM OPN_P_KW WHERE KEYID = NEW.TAG1_KEYID) ;

END CASE ;

SET PBYUNAME = (SELECT USERNAME FROM OPN_USERLIST WHERE USERID = NEW.POST_BY_USERID) ;

/* Commenting out the OPN_PUSH_LAUNCH INSERT portion because thetable has become runaway. */

INSERT INTO OPN_PUSH_LAUNCH(USERID, USER_UUID, APP_TOKEN, USER_PLATFORM, PUSH_TYPE
, PUSH_COUNT, PUSH_TOPIC, SOURCE_ID, POST_EXCERPT, PUSH_TITLE)
SELECT U.USERID, U.USER_UUID, U.IDENTIFIER_TOKEN, U.LAST_USED_PLATFORM, 'POST'
, 1 , POSTTOPIC, NEW.TOPICID, POST_EXCRPT, 'New post/s added in'
FROM OPN_USERLIST U, ( SELECT DISTINCT B.USERID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = NEW.POST_BY_USERID AND C1.TOPICID = NEW.TOPICID) A ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = NEW.TOPICID AND 
C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = NEW.POST_BY_USERID 
AND OUUA.TOPICID = NEW.TOPICID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.CART = B.CART AND A.KEYID = B.KEYID ) NW
WHERE U.IDENTIFIER_TOKEN IS NOT NULL 
AND U.USERID = NW.USERID ;

/* Commenting out the OPN_PUSH_LAUNCH INSERT portion because thetable has become runaway. */

INSERT INTO OPN_POST_SEARCH_T(TOPICID, POST_ID, POST_BY_UID, POST_BY_UNAME, POSTOR_CCODE
, POST_CONTENT, URL_TITLE, TAG1_KEYID, TAG1_KW, SEARCH_STRING, POST_DTM)
VALUES(NEW.TOPICID, NEW.POST_ID, NEW.POST_BY_USERID, PBYUNAME, NEW.POSTOR_COUNTRY_CODE
, NEW.POST_CONTENT, NEW.URL_TITLE, NEW.TAG1_KEYID, KW
, CONCAT(PBYUNAME, '-',IFNULL(KW,''), '-', SUBSTR(NEW.POST_CONTENT, 1, 1000)
, '-', IFNULL(NEW.URL_TITLE, ''))
, NEW.POST_DATETIME) ;




END$$

DELIMITER ;

-- 
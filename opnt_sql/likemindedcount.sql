-- likemindedcount

DELIMITER //
DROP PROCEDURE IF EXISTS likemindedcount //
CREATE PROCEDURE likemindedcount(uuid varchar(45), topic_id varchar(20))
BEGIN

/* 26032020 Rohit: Newly created To get the Networkcount and the topic name  
after selecting the love or hate 
04/03/2020 AST: Changed the Network Count to do real time count 

08/11/2020 Kapil: Confirmed
 */
DECLARE ISGUEST INT;
DECLARE UID INT;
DECLARE CNT INT;
DECLARE TOPICNAME varchar(30);
DECLARE TCODE varchar(3);
SET UID= (SELECT bringUserid(uuid));
SET CNT= (SELECT COUNT(DISTINCT U2.USERID)
FROM OPN_USER_CARTS U1, OPN_USER_CARTS U2
WHERE U1.USERID = UID AND U1.TOPICID = topic_id
AND U1.KEYID = U2.KEYID AND U1.TOPICID = U2.TOPICID 
AND U1.CART = U2.CART 
AND U2.USERID NOT IN (SELECT UU.ON_USERID FROM OPN_USER_USER_ACTION UU
WHERE UU.BY_USERID = UID AND UU.TOPICID = topic_id AND UU.ACTION_TYPE = 'KO'));

SET TOPICNAME= (select T.TOPIC from OPN_TOPICS T WHERE T.TOPICID = topic_id);
SELECT CNT,TOPICNAME;

END //
DELIMITER ;

-- 
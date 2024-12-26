-- cartUpsert

 DELIMITER //
DROP PROCEDURE IF EXISTS cartUpsert //
CREATE PROCEDURE cartUpsert(uuid varchar(45), tid INT, kid INT, cartv varchar(3))
THISPROC:BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */
declare  orig_uid, pbuid INT;
declare orig_cart varchar(3);

SET orig_uid = (SELECT  bringUserid(uuid));
SET orig_cart = (SELECT COALESCE((SELECT CART FROM OUC_TEST WHERE USERID = orig_uid AND TOPICID = tid AND KEYID = kid), 'NC')) ;

CASE WHEN orig_cart = 'NC' then 

INSERT INTO OUC_TEST(TOPICID, USERID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (tid, orig_uid, kid, cartv, NOW(), NOW());

WHEN orig_cart <> 'NC' AND orig_cart <> cartv THEN 
UPDATE OUC_TEST SET CART = cartv where USERID = orig_uid AND TOPICID = tid AND KEYID = kid ;

WHEN orig_cart <> 'NC' AND orig_cart = cartv THEN 
leave THISPROC ;

END CASE ;


END //
DELIMITER ;

-- 
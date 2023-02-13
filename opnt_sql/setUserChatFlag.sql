-- setUserChatFlag

 DELIMITER //
DROP PROCEDURE IF EXISTS setUserChatFlag //
CREATE PROCEDURE setUserChatFlag(UUID varchar(45), chatflag varchar(5))
BEGIN

/* 08/24/2020 Kapil: Enable Disable user Chat  */

declare  orig_uid INT;

SET orig_uid := (SELECT  bringUserid(UUID));

UPDATE OPN_USERLIST U SET U.CHAT_FLAG = chatflag  WHERE U.USERID = orig_uid ;

END  //
DELIMITER ;

-- 
-- unblockPost

 DELIMITER //
DROP PROCEDURE IF EXISTS unblockPost //
CREATE PROCEDURE unblockPost(entrykey VARCHAR(10), postid INT, puuid VARCHAR(45) )
thisproc: BEGIN

/* 01/15/2021 AST: Initial Creation: To unblock a post that has been flagged as CLEAN_POST_FLAG = 'N' */
SET SQL_SAFE_UPDATES = 0;

CASE WHEN entrykey <> 'kalyan' THEN LEAVE thisproc;

WHEN entrykey = 'kalyan' THEN
UPDATE OPN_POSTS_RAW R, OPN_POSTS P
SET P.POST_CONTENT = R.POST_CONTENT WHERE P.POST_ID = R.POST_ID
AND P.POST_BY_USERID = bringUserid(puuid) 
AND P.POST_ID = postid AND R.POST_ID = postid;

UPDATE OPN_POSTS P2 SET P2.CLEAN_POST_FLAG = 'Y' WHERE P2.POST_ID = postid ;

END CASE ;

END //
DELIMITER ;

-- 
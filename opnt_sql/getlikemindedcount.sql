-- getlikemindedcount

DELIMITER //
DROP FUNCTION IF EXISTS getlikemindedcount //
CREATE FUNCTION getlikemindedcount(uuid varchar(45), topicid varchar(20)) RETURNS int(11) 
BEGIN

/* 08/23/2020 AST: Being copied as part of clean-up - not sure if this function is 
	actually used any more */

DECLARE userid INT;
DECLARE count INT;
SET userid= (SELECT bringUserid(uuid));

SET count = (select getNetworkCount(userid,topicid));

  RETURN count;
  
END;//

-- 
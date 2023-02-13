-- bringTopicfromTID

DELIMITER //
DROP FUNCTION IF EXISTS bringTopicfromTID //
CREATE FUNCTION bringTopicfromTID(tid INT) RETURNS varchar(60)
BEGIN

/* 01/05/2021 AST: Built for easily bringing Topic Name without a join with OPN_TOPICS */

  DECLARE tName varchar(60) ;

SET tName = (SELECT T.TOPIC FROM OPN_TOPICS T WHERE T.TOPICID = tid);

  RETURN tName;
  
END

;//

-- 


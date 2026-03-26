-- tryTableParam

 DELIMITER //
DROP PROCEDURE IF EXISTS tryTableParam //
CREATE PROCEDURE tryTableParam(tid INT, tname varchar(50), cnt int)
BEGIN

/*
	Testing whether table name cna be passed as a param to be used in a sql inside the proc
*/
DECLARE TBL VARCHAR(50) ;
SET TBL = tname ;

SELECT * FROM TBL WHERE TOPICID = tid LIMIT cnt ;


END //
DELIMITER ;

-- 

-- DROP FUNCTION wordcount ;

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `wordcount`(str TEXT) RETURNS int(11)
    NO SQL
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 SELECT wordcount(STR TEXT) 
 
 SELECT wordcount('COUNT THE NUMBER OF WORDS IN THIS') = 7
  */

    DECLARE wordCnt, idx, maxIdx INT DEFAULT 0;
    DECLARE currChar, prevChar BOOL DEFAULT 0;
    SET maxIdx=char_length(str);
    WHILE idx < maxIdx DO
        SET currChar=SUBSTRING(str, idx, 1) RLIKE '[[:alnum:]]';
        IF NOT prevChar AND currChar THEN
            SET wordCnt=wordCnt+1;
        END IF;
        SET prevChar=currChar;
        SET idx=idx+1;
    END WHILE;
    RETURN wordCnt;
  END$$
DELIMITER ;

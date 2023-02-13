-- getPostCounts

DELIMITER //
DROP PROCEDURE IF EXISTS getPostCounts //
CREATE PROCEDURE getPostCounts( UUID varchar(45), TID INT )

BEGIN

/* 05042020 AST: Post Counts for any USER + TOPIC combo

CALL getPostCounts( UUID varchar(45), TID INT )

06/18/2020 AST: Switched the counts to introduce the ANTI - needs to be fixed from App & php
08/11/2020 Kapil: Confirmed
 */

SELECT bringPostCountNW(UUID, TID) NW_POST_COUNT,  bringPostCountANTI(UUID, TID) ANTI_POST_COUNT ;
  
END//
DELIMITER ;

-- 
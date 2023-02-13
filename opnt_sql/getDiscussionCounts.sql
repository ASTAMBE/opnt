-- getDiscussionCounts

DELIMITER //
DROP PROCEDURE IF EXISTS getDiscussionCounts //
CREATE PROCEDURE getDiscussionCounts( UUID varchar(45), TID INT )

BEGIN

/* 05042020 AST: Post Counts for any USER + TOPIC combo

CALL getPostCounts( UUID varchar(45), TID INT )

06/18/2020 AST: Switched the counts to introduce the ANTI - needs to be fixed from App & php
08/11/2020 Kapil: Confirmed
 */

SELECT bringDiscussionCountNW(UUID, TID) NW_DISC_COUNT,  bringDiscussionCountANTI(UUID, TID) ANTI_DISC_COUNT ;
  
END//
DELIMITER ;

-- 
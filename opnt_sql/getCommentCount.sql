-- getCommentCount

DELIMITER //
DROP PROCEDURE IF EXISTS getCommentCount //
CREATE PROCEDURE getCommentCount(UUID VARCHAR(45),  postID INT)
BEGIN

/* 	06/18/2020 AST: Adding countANTI - replacing countALL with countANTI - for the time being 
08/11/2020 Kapil: Confirmed
*/

declare countALL,countNW, countANTI INT;

SET countALL= (select bringCommentCountALL(UUID,postID));
SET countNW= (select bringCommentCountNW(UUID,postID));
SET countANTI= (select bringCommentCountANTI(UUID,postID));

-- SET countALL = countNW ;
-- SET countNW = countANTI ;

select countALL, countNW, countANTI;

END //
DELIMITER ;

-- 

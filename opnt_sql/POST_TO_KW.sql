-- POST_TO_KW_INSERT

-- TRIGGER TO CONVERT POSTS INTO KW

DELIMITER $$
DROP TRIGGER IF EXISTS POST_TO_KW_INSERT $$
CREATE TRIGGER POST_TO_KW_INSERT 
AFTER INSERT ON OPN_USER_POST_ACTION for each row
begin

/*

	02/18/2023 AST: This trigger will convert a Post into a Keyword when any user declares L/H for the post
    
    Things to remember:
    1. Only Posts can get converted to KWs (this table is used for L/H on comments also - but that functionality
    is not yet turned on. If it gets turned on, this trugger will have to be modified.
    2. The post turns into KW only once, the very first time any user gives L/H to the post
    3. Along with turning it into KW, the trigger also needs to add this KID to the user's cart
    4. SInce the user can change or even cancel the L/H anytime, we need to ensure that the KID disappears 
    from the user's cart if the user does NOT have l/h for the post.
    5. This may require a DELETE trigger also on this table - just to delete the entry in the user's cart
    6. Both the actions are best handled by dedicated Procs - the trigger will simply call those procs.
    7. The procs themselves will handle the duplicates and deletions etc. They will also handle the size of 
    the post to KW conversion
       

*/

CALL convertPostToKW(NEW.CAUSE_POST_ID, NEW.TOPICID, NEW.ACTION_BY_USERID, NOW(), NEW.ACTION_TYPE, IFNULL(NEW.KEYID, 0) ) ;

END$$

DELIMITER ; 

-- 
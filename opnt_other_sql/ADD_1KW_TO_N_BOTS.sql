-- 

DELIMITER //
DROP PROCEDURE IF EXISTS ADD_1KW_TO_N_BOTS //
CREATE PROCEDURE ADD_1KW_TO_N_BOTS(TID1 INT, CCODE VARCHAR(5), CARTV VARCHAR(3),  KID1 INT, NUMBOTS INT)
/* 07/01/2023 AST:
This proc is for adding a specific keyword (KID1) for specified TID, CART, CCODE combo bot users.

This proc was necessitated by the following observation:
- In order to provide enough content for the GGG users, we started the STP_REMAINDER process (this proc distributes the
UNTAGGED scrapes for the INTEREST + CCODE combo to the BOT users)
- It was found that there were only a handful of BOTs that had the politicsnews1 KW (50 in GGG and USA and 100 in IND)
- This small number is not sufficient to distribute the STP_REMAINDER in a broad enough manner - in order to 
have most non-BOT users get some new GGG posts.
- Hence, we are going to use this proc to add the specific XYZ News KWs to a large number of BOT users.
- This will allow the STP_REMAINDER to have a large enough population to distribute the new scrapes

*/


thisProc: BEGIN
  DECLARE  UID INT ;

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_2L CURSOR FOR SELECT A.USERID FROM OPN_USERLIST A 
WHERE A.COUNTRY_CODE = CCODE AND A.BOT_FLAG = 'Y'
AND A.USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE TOPICID = TID1 AND KEYID = KID1) ORDER BY RAND() LIMIT NUMBOTS ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_2L;
   READ_LOOP: LOOP
    FETCH CURSOR_2L INTO UID;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

/* SET LCNT = FLOOR(RAND()* (KMAX-KMIN) +KMIN) ;

ADD A CASE STATEMENT HERE TO MAKE SURE THAT IF THE CURSOR IS EMPTY, THEN THE PROC SHOULD TERMINATE. ELSE IT INSERTS ROWS USING THE OLD VALUES OF UID THAT IT HAS RETAINED FROM SOME OLD RUN
INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('ADD_1KW_TO_N_BOTS', NOW(), 'UID', UID) ;

*/

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( CARTV, KID1, UID, TID1, NOW(), NOW() )  ;

        END LOOP;
  CLOSE CURSOR_2L;
   
 
END; //
 DELIMITER ;
 
 -- 
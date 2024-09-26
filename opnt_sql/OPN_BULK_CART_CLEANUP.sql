-- OPN_BULK_CART_CLEANUP

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BULK_CART_CLEANUP //
CREATE PROCEDURE OPN_BULK_CART_CLEANUP(TID INT)
thisProc: BEGIN
  DECLARE KID, UCNT, ICNT, GCNT, UDCNT, IDCNT, GDCNT INT;

/* 06/30/2024 AST: This proc is being created due to the following reasons:
- The OPN_USER_CARTS has become huge ~ 10 mn rows
- Each bot now has over 120 KWs in the cart in each interest - this is too much
- As of now, there is little traffic and all the scrapes that are converted to
discussions or posts are now converted into KWs and each KW is assigned to about
150 bots
- The end goal is to bring the cart size of each bot to < 25 KWs
- This will be done by removing the older KWs from the bot carts
- We will keep 50% of the bots for the KW's native ccode and only 25% for 
the other ccodes.

Explanation of the proc: The Declare has two types of counts:
UCNT, ICNT, GCNT are the number of BOTs that this keyword (KID) has for USA, IND and GGG
The UDCNT, IDCNT AND GDCNT are the target numbers of BOTs to be reduced form the KID cart

*/

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR 
SELECT KEYID, USA, IND, GGG FROM TEMP_KEYID4_CLEANUP ORDER BY RAND() LIMIT 1000 ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO KID, UCNT, ICNT, GCNT ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

/*

*/

IF UCNT > 8 THEN SET UDCNT = UCNT - 8 ;
DELETE FROM OPN_USER_CARTS WHERE KEYID = KID AND TOPICID = TID AND USERID IN 
(SELECT USERID FROM OPN_USERLIST U WHERE U.COUNTRY_CODE = 'USA' AND U.BOT_FLAG = 'Y') ORDER BY RAND() LIMIT UDCNT ;
END IF;

IF ICNT > 8 THEN SET IDCNT = ICNT - 8 ;
DELETE FROM OPN_USER_CARTS WHERE KEYID = KID AND TOPICID = TID AND USERID IN 
(SELECT USERID FROM OPN_USERLIST U WHERE U.COUNTRY_CODE = 'IND' AND U.BOT_FLAG = 'Y') ORDER BY RAND() LIMIT IDCNT ;
END IF ;

IF GCNT > 8 THEN SET GDCNT = GCNT - 8 ;
DELETE FROM OPN_USER_CARTS WHERE KEYID = KID AND TOPICID = TID AND USERID IN 
(SELECT USERID FROM OPN_USERLIST U WHERE U.COUNTRY_CODE = 'GGG' AND U.BOT_FLAG = 'Y') ORDER BY RAND() LIMIT GDCNT ;
END IF ;

DELETE FROM TEMP_KEYID4_CLEANUP WHERE KEYID = KID ;

 
        END LOOP;
  CLOSE CURSOR_I;
 
END

; //
 DELIMITER ;
 
 -- 

 -- 
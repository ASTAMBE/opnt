-- OPN_BULK_CART_CLEANUP

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BULK_CART_CLEANUP //
CREATE PROCEDURE STP_REMAINDER(TID INT, ccode VARCHAR(5), numdays INT, Keycount INT)
thisProc: BEGIN
  DECLARE KID, UCNT, ICNT, GCNT, UDCNT, IDCNT, GDCNT INT;
  DECLARE SCRAPEURL, URLTITLE, NEWSDESC VARCHAR(1000);
  DECLARE CCODEVAR VARCHAR(5) ;
  DECLARE SCRPTPC VARCHAR(30) ;
  DECLARE SCRDATE DATETIME ;

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
SELECT C.KEYID, SUM(CASE WHEN U.COUNTRY_CODE = 'USA' THEN 1 ELSE 0 END) USA, SUM(CASE WHEN U.COUNTRY_CODE = 'IND' THEN 1 ELSE 0 END) IND
, SUM(CASE WHEN U.COUNTRY_CODE = 'GGG' THEN 1 ELSE 0 END) GGG FROM OPN_USER_CARTS C, OPN_USERLIST U, OPN_P_KW K 
WHERE C.USERID = U.USERID AND C.KEYID = K.KEYID AND U.BOT_FLAG = 'Y' AND C.TOPICID = TID AND K.COUNTRY_CODE = ccode 
AND IFNULL(K.BOT_CART_MANAGED_FLAG, 'N') = 'N' AND K.CREATION_DTM < CURRENT_DATE() - INTERVAL numdays DAY 
GROUP BY C.KEYID ORDER BY RAND() LIMIT Keycount ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO KID, UCNT, ICNT, GCNT ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

/*

*/

CASE WHEN 

 
        END LOOP;
  CLOSE CURSOR_I;
 
END

; //
 DELIMITER ;
 
 -- END OF STP_STAG23_MICRO

 -- 
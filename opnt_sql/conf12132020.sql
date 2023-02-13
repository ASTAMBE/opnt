-- 

DELIMITER //
DROP PROCEDURE IF EXISTS ADD_NUSERS_4K1 //
CREATE PROCEDURE ADD_NUSERS_4K1(K1 INT, CCODE VARCHAR(5),  TID INT)


thisProc: BEGIN

/* for loading demo users carts with the new KW that is crated by a user

07/24/2019 AST: Changing the random user KW->cart assignment logic - 
replacing AND USERID < 1020000 AND TAILORED_USER_FLAG = 'N' with BOT_FLAG = 'Y'

	07/01/2020 AST: Adding the steps where each new KW will create some BOT users
    in all the CCODES - not just the CCODE of the origin user.

*/

DECLARE  HCOUNT, LCOUNT INT ;

/* Added on 07/01/2020 AST */

DECLARE CCD2, CCD3 VARCHAR(5) ;

CASE WHEN CCODE = 'USA' THEN SET CCD2 = 'IND' ;
	SET CCD3 = 'GGG' ;
    WHEN CCODE = 'IND' THEN SET CCD2 = 'USA' ;
	SET CCD3 = 'GGG' ;
    WHEN CCODE = 'GGG' THEN SET CCD2 = 'IND' ;
	SET CCD3 = 'USA' ;
    
    END CASE ;

/* End of 07/01/2020 addition */

SET HCOUNT = FLOOR(RAND()* (25-15) +15) ;

SET LCOUNT = FLOOR(RAND()* (40-25) +25) ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCODE) ORDER BY RAND() LIMIT HCOUNT)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCODE) ORDER BY RAND() LIMIT LCOUNT)Q ;

-- CALL NEWCART_TOP_NOTAILOR(UUID, TID1) ;

/* Added on 07/01/2020 AST */

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCD2) ORDER BY RAND() LIMIT HCOUNT )Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCD2) ORDER BY RAND() LIMIT LCOUNT )Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'H', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCD3) ORDER BY RAND() LIMIT HCOUNT)Q ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
SELECT 'L', K1, USERID, TID, NOW(), NOW() FROM 
(SELECT USERID FROM OPN_USERLIST 
  WHERE USERID NOT IN (SELECT DISTINCT USERID FROM OPN_USER_CARTS WHERE KEYID  IN (K1))
AND BOT_FLAG = 'Y' AND COUNTRY_CODE IN (CCD3) ORDER BY RAND() LIMIT LCOUNT)Q ;

/* End of 07/01/2020 addition */

 
END; //
 DELIMITER ;
 
 -- -- CLEAN_COMMENT_FLG
 
 --
 
 DELIMITER //
DROP PROCEDURE IF EXISTS CLEAN_COMMENT_FLG //
CREATE PROCEDURE CLEAN_COMMENT_FLG(COMMENTID INT)
BEGIN

 /* 08/14/2019 AST: changed the URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-5), '/',1), '.',-2))
 earlier it was URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) 
 
	10/30/2020 AST: Changing the ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N'
  to
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  
  11/06/2020 AST: Changing the entire logic of clean domain detection to expect just the domain part in the 
		inputs - instead of the complete URL 
 
 
 
    DECLARE EMB, URL1, URL2, URL3, URL4, URL5 TEXT;
  declare CID, CUID, UCNT, CPID, CPUID INT;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT CAUSE_POST_ID, POST_BY_USERID, COMMENT_ID, COMMENT_BY_USERID, EMBEDDED_CONTENT
  , IFNULL(ROUND ((LENGTH(EMBEDDED_CONTENT)- LENGTH( REPLACE ( EMBEDDED_CONTENT, "://", ""))) / LENGTH("://")),0) AS count
  FROM OPN_POST_COMMENTS_RAW where COMMENT_ID = COMMENTID;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO CPID, CPUID, CID, CUID, EMB, UCNT;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
CASE WHEN UCNT = 0 THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
WHERE COMMENT_ID = CID;

WHEN UCNT = 1 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) ;
 if URL1 IN (select U_DOMAIN from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()  WHERE COMMENT_ID = CID;
  ELSE UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN, CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL NOT IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
 END IF;
 
 WHEN UCNT = 2 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));
 
 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) ) THEN
 -- THIS DOES NOT ADDRESS THE CASE WHERE BOTH THE URLS ARE FROM THE SAME, CLEAN DOMAIN
 -- FIX THAT
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
    WHEN UCNT = 3 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
       WHEN UCNT = 4 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-4), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
    SET URL4 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
        ,(CPID, CPUID, URL4, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST');
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
          WHEN UCNT = 5 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-5), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-4), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2));
    SET URL4 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
        SET URL5 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
      ,(CPID, CPUID, URL4, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL5, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST');
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
   WHEN UCNT > 5 THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y'
   , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
   , COMMENT_PROCESSED_DTM = NOW() WHERE COMMENT_ID = CID;
     INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
  
    END CASE;
        END LOOP;
  CLOSE CURSOR_I;
  
   End of COPY of the previous code */
   
       DECLARE EMB, URL1, URL2, URL3, URL4, URL5 TEXT;
  declare CID, CUID, UCNT, CPID, CPUID INT;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT CAUSE_POST_ID, POST_BY_USERID, COMMENT_ID, COMMENT_BY_USERID, EMBEDDED_CONTENT
  ,LENGTH(EMBEDDED_CONTENT) - LENGTH(REPLACE(EMBEDDED_CONTENT, ',', ''))+1 AS count
  FROM OPN_POST_COMMENTS_RAW where COMMENT_ID = COMMENTID;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO CPID, CPUID, CID, CUID, EMB, UCNT;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
CASE WHEN UCNT = 0 THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
WHERE COMMENT_ID = CID;

WHEN UCNT = 1 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1)) ;
 if URL1 IN (select U_DOMAIN from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()  WHERE COMMENT_ID = CID;
  ELSE UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN, CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL NOT IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
 END IF;
 
 WHEN UCNT = 2 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1)) ;
 SET URL2 = TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
 
 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) ) THEN
 -- THIS DOES NOT ADDRESS THE CASE WHERE BOTH THE URLS ARE FROM THE SAME, CLEAN DOMAIN
 -- FIX THAT
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
    WHEN UCNT = 3 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1))  ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1)) ;

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
       WHEN UCNT = 4 THEN SET URL1 =   TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1)) ;

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
        ,(CPID, CPUID, URL4, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST');
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
          WHEN UCNT = 5 THEN SET URL1 =   TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1) );
        SET URL5 = TRIM(substring_index(substring_index(EMB, ',', 5), ',', -1) );
        
 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN
 UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
 , COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW()
  WHERE COMMENT_ID = CID;
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y', COMMENT_PROCESSED_DTM = NOW() 
  , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE COMMENT_ID = CID;
  INSERT INTO OPN_REJECTED_DOMAINS(CAUSE_POST_ID, POST_BY_USERID, REJECTED_DOMAIN
  , CAUSE_COMMENT_ID, REJECT_PROC_DTM, COMMENT_BY_USERID, REJECT_COMMENT)
  VALUES (CPID, CPUID, URL1, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(CPID, CPUID, URL2, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL3, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
      ,(CPID, CPUID, URL4, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST')
    ,(CPID, CPUID, URL5, CID, NOW(), CUID, 'URL MAY NOT BE IN CLEAN URL LIST');
    INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
   END IF;
  
   WHEN UCNT > 5 THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'N', COMMENT_PROCESSED_FLAG = 'Y'
   , COMMENT_CONTENT = 'This comment has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
   , COMMENT_PROCESSED_DTM = NOW() WHERE COMMENT_ID = CID;
     INSERT INTO OPN_REJECTED_COMMENTS(COMMENT_ID, CAUSE_POST_ID, POST_BY_USERID, COMMENT_BY_USERID, EMBEDDED_CONTENT, COMMENT_PROCESSED_DTM)
  VALUES(CID, CPID, CPUID, CUID, EMB, NOW());
  
    END CASE;
        END LOOP;
  CLOSE CURSOR_I;
  
END

; //
 DELIMITER ;
 
 -- 
-- START CLEANING 
 
 --
 
 -- CLEAN_POST_FLG
 
 /* 08/14/2019 AST: changed the URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-5), '/',1), '.',-2))
 earlier it was URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) 
 
		10/30/2020 AST: Changing the ELSE
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N'
  to
  ELSE
  UPDATE OPN_POST_COMMENTS SET CLEAN_POST_FLAG = 'N', POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
 
 */
 
 -- 
 
 DELIMITER //
DROP PROCEDURE IF EXISTS CLEAN_POST_FLG //
CREATE PROCEDURE CLEAN_POST_FLG(POSTID INT)
BEGIN

 /* 	11/06/2020 AST: Changing the entire logic of clean domain detection to expect just the domain part in the 
		inputs - instead of the complete URL */
        
            /*  Start of COPY of the previous code */
            
            /*
        
   DECLARE EMB, URL1, URL2, URL3, URL4, URL5 TEXT;
  declare PID, PUID, UCNT INT;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT POST_ID, POST_BY_USERID, EMBEDDED_CONTENT
  , IFNULL(ROUND ((LENGTH(EMBEDDED_CONTENT)- LENGTH( REPLACE ( EMBEDDED_CONTENT, "://", ""))) / LENGTH("://")),0) AS count
  FROM OPN_POSTS_RAW where post_id = POSTID;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO PID, PUID, EMB, UCNT;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
CASE WHEN UCNT = 0 THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
WHERE POST_ID = PID;

WHEN UCNT = 1 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) ;
 if URL1 IN (select U_DOMAIN from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL NOT IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
 END IF;
 
 WHEN UCNT = 2 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
 
 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) ) THEN 
 
 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST'),(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
    WHEN UCNT = 3 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
       WHEN UCNT = 4 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-4), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
    SET URL4 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
        ,(URL4, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
          WHEN UCNT = 5 THEN SET URL1 =  UPPER(substring_index(substring_index(substring_index(EMB, '://',-5), '/',1), '.',-2)) ;
 SET URL2 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-4), '/',1), '.',-2));
  SET URL3 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-3), '/',1), '.',-2));
    SET URL4 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-2), '/',1), '.',-2));
        SET URL5 = UPPER(substring_index(substring_index(substring_index(EMB, '://',-1), '/',1), '.',-2));

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
      ,(URL4, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL5, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
   WHEN UCNT > 5 THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
   , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
   WHERE POST_ID = PID;
   INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   
    END CASE;
        END LOOP;
  CLOSE CURSOR_I;
  
  */
  
    /*  End of COPY of the previous code */
    
       DECLARE EMB, URL1, URL2, URL3, URL4, URL5 TEXT;
  declare PID, PUID, UCNT INT;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT POST_ID, POST_BY_USERID, EMBEDDED_CONTENT
  , LENGTH(EMBEDDED_CONTENT) - LENGTH(REPLACE(EMBEDDED_CONTENT, ',', ''))+1  AS count
  FROM OPN_POSTS_RAW where post_id = POSTID;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO PID, PUID, EMB, UCNT;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
CASE WHEN UCNT = 0 THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
WHERE POST_ID = PID;

WHEN UCNT = 1 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1)) ;
 if URL1 IN (select U_DOMAIN from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL NOT IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
 END IF;
 
 WHEN UCNT = 2 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1)) ;
 SET URL2 = TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
 
 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) ) THEN 
 
 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST'),(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
    WHEN UCNT = 3 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1))  ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1)) ;

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') ;
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
       WHEN UCNT = 4 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1)) ;

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
        ,(URL4, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
          WHEN UCNT = 5 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1) );
        SET URL5 = TRIM(substring_index(substring_index(EMB, ',', 5), ',', -1) );

 IF (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)) THEN 
 UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
 , POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW()
  WHERE POST_ID = PID; 
  ELSE 
  UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
  , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
  WHERE POST_ID = PID;
  INSERT INTO OPN_REJECTED_DOMAINS(REJECTED_DOMAIN, CAUSE_POST_ID, REJECT_PROC_DTM, POST_BY_USERID, REJECT_COMMENT)
  VALUES (URL1, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST')
  ,(URL2, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL3, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
      ,(URL4, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST') 
    ,(URL5, PID, NOW(), PUID, 'URL MAY NOT BE IN CLEAN URL LIST');
  INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   END IF;
   
   WHEN UCNT > 5 THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N', POST_PROCESSED_FLAG = 'Y', POST_PROCESSED_DTM = NOW() 
   , POST_CONTENT = 'This post has been flagged for a 
  possible violation of the Opinito Terms and Conditions. If it is indeed found to be in violation of Opinito 
  Terms and Conditions, then consider yourself warned and please desist from using inappropriate content.
  If Opinito admin finds it to be NOT in violation of the Opinito Terms and Conditions then it will be restored.'
   WHERE POST_ID = PID;
   INSERT INTO OPN_REJECTED_POSTS(POST_ID, POST_BY_USERID, EMBEDDED_CONTENT, POST_PROCESSED_DTM)
  VALUES(PID, PUID, EMB, NOW());
   
    END CASE;
        END LOOP;
  CLOSE CURSOR_I;
  
END

; //
 DELIMITER ;
 
 -- -- 

DROP PROCEDURE IF EXISTS KILL_KEYWORD ;
DELIMITER $$
CREATE  PROCEDURE `KILL_KEYWORD`(ENTRYKEY VARCHAR(10), KID INT, TID INT)
THISPROC: BEGIN

/* THIS PROC IS INTENDED TO CLEANLY REMOVE AN EXISTING KEYWORD FOR WHICH THERE ARE ALREADY CARTS, CLUSTERS ETC.

ENTRYKEY is to ensure that only I can kill a KW even if somebody knows the call
12/11/2020 AST: Added UPDATE OPN_POSTS for matching TAG1_KEYID
*/

 CASE WHEN ENTRYKEY = 'kalyan' THEN
 
DELETE FROM OPN_USER_CARTS WHERE TOPICID = TID AND KEYID = KID ;

UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'N' WHERE TAG1_KEYID = KID AND TOPICID = TID ;

DELETE FROM OPN_KW_TAGS WHERE TOPICID = TID AND KEYID = KID ;

INSERT INTO OPN_KILLED_KW SELECT * FROM OPN_P_KW WHERE TOPICID = TID AND KEYID = KID ;

UPDATE OPN_KILLED_KW SET LAST_UPDATE_DTM = NOW() WHERE TOPICID = TID AND KEYID = KID ;

DELETE FROM OPN_P_KW WHERE TOPICID = TID AND KEYID = KID; 

WHEN ENTRYKEY <> 'kalyan' THEN

SELECT 'INTRUDER ALERT' FROM DUAL ;

END CASE ;




  
  
  
END$$
DELIMITER ;

-- 
-- KOUserCommon

 DELIMITER //
DROP PROCEDURE IF EXISTS KOUserCommon //
CREATE PROCEDURE KOUserCommon(userid varchar(45), KOtype VARCHAR(10), KOSourceID INT)
BEGIN

/* 06/02/2020 AST: Adding the USR BHV Log  
08/11/2020 Kapil: Confirmed
*/


declare  ORIG_UID, causePostID, TID, causeCommentID, postByUID, commentUserid INT;

CASE WHEN KOtype = 'COMMENT' THEN

SET ORIG_UID = (SELECT  bringUserid(userid));

SELECT TOPICID, COMMENT_BY_USERID, CAUSE_POST_ID INTO TID, commentUserid, causePostID
FROM OPN_POST_COMMENTS WHERE COMMENT_ID = KOSourceID ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUID(ORIG_UID), ORIG_UID, userid, NOW(), 'KOUserCommon'
, CONCAT(ORIG_UID, ' - COMMENT KO -',commentUserid, ' FOR COMMENT_ID = ', KOSourceID));

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUID(ORIG_UID), ORIG_UID, userid, NOW(), 'KOUserCommon'
, CONCAT(commentUserid, ' - REVERSE CKO -',ORIG_UID, ' FOR COMMENT_ID = ', KOSourceID));

/* end of use action tracking */

DELETE FROM OPN_USER_USER_ACTION WHERE OPN_USER_USER_ACTION.BY_USERID = ORIG_UID 
AND OPN_USER_USER_ACTION.TOPICID = TID
AND OPN_USER_USER_ACTION.ON_USERID =  commentUserid ;

DELETE FROM OPN_USER_USER_ACTION WHERE OPN_USER_USER_ACTION.BY_USERID = commentUserid 
AND OPN_USER_USER_ACTION.TOPICID = TID
AND OPN_USER_USER_ACTION.ON_USERID =  ORIG_UID ;

INSERT INTO OPN_USER_USER_ACTION (BY_USERID, ON_USERID, ACTION_TYPE, ACTION_DTM
, CAUSE_POST_ID, CAUSE_COMMENT_ID, ACTION_COMMENT, TOPICID) 
VALUES (ORIG_UID, commentUserid, 'KO', NOW(), causePostID, KOSourceID, 'CKO', TID) ;

INSERT INTO OPN_USER_USER_ACTION (BY_USERID, ON_USERID, ACTION_TYPE, ACTION_DTM
, CAUSE_POST_ID, CAUSE_COMMENT_ID, ACTION_COMMENT, TOPICID) 
VALUES (commentUserid, ORIG_UID, 'KO', NOW(), causePostID, KOSourceID, 'RCKO', TID) ;

WHEN KOtype = 'POST' THEN

SET ORIG_UID = (SELECT  bringUserid(userid));
SELECT TOPICID, POST_BY_USERID INTO TID, postByUID FROM OPN_POSTS WHERE POST_ID = KOSourceID ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUID(ORIG_UID), ORIG_UID, userid, NOW(), 'KOUserCommon'
, CONCAT(ORIG_UID, ' - POST KO -',postByUID, ' FOR POST_ID = ', KOSourceID));

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUID(ORIG_UID), ORIG_UID, userid, NOW(), 'KOUserCommon'
, CONCAT(postByUID, ' - REVERSE PKO -',ORIG_UID, ' FOR POST_ID = ', KOSourceID));

/* end of use action tracking */

DELETE FROM OPN_USER_USER_ACTION WHERE OPN_USER_USER_ACTION.BY_USERID = ORIG_UID 
AND OPN_USER_USER_ACTION.TOPICID = TID
AND OPN_USER_USER_ACTION.ON_USERID =  postByUID ;

DELETE FROM OPN_USER_USER_ACTION WHERE OPN_USER_USER_ACTION.BY_USERID = ORIG_UID 
AND OPN_USER_USER_ACTION.TOPICID = TID
AND OPN_USER_USER_ACTION.ON_USERID =  postByUID ;

INSERT INTO OPN_USER_USER_ACTION (BY_USERID, ON_USERID, ACTION_TYPE, ACTION_DTM
, CAUSE_POST_ID, ACTION_COMMENT, TOPICID) 
VALUES (ORIG_UID, postByUID, 'KO', NOW(), KOSourceID, 'PKO', TID) ;

INSERT INTO OPN_USER_USER_ACTION (BY_USERID, ON_USERID, ACTION_TYPE, ACTION_DTM
, CAUSE_POST_ID, ACTION_COMMENT, TOPICID) 
VALUES (postByUID, ORIG_UID, 'KO', NOW(), KOSourceID,  'RPKO', TID) ;

END CASE ;

END //
DELIMITER ;

-- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST //
CREATE PROCEDURE OPN_BUILD_LLIST(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60)
, W4 varchar(60), W5 varchar(60), W6 varchar(60) )
llistproc: BEGIN

/*

05/16/2019 AST: This proc is BEING BUILT AS PART OF THE AUTOMATION OF THE NEWKW TO TAGGING TO STP PROCESS.
    It will take up to 6 words - a new topic/kw broken into sub-words. Then it will decide which sub-words need
    to be included in the OPN_SCRAPE_DESIGN_GEN - populating the LIKE1-6

    ALGORITHM:

    1. Strip out the 2/3 letter words from the OPN_SKIP_WORDS table (largewordlist)
    2. First check if any of the largewordlist exist in the current KWs
    (SELECT COUNT(*) FROM OPN_KW_TAGS WHERE LIKE1 LIKE '%TRUMP%' OR LIKE2 LIKE '%TRUMP% UP TO LIKE 6) (inOPKcnt) ;
    - IF only one of the largewordlist is in the OPK, then use that as anchor
    - If > 1 of the largewordlist exist in OPK then use the one that has the largest inOPKcnt
    - If 2 or more have the same inOPKcnt then use L1L2, L1L3, L1L4 strategy
    3. First take any words that are 5/+ letters and combine them
        2.1 The first 5/+ letter word will be the anchor
        2.2 This will give 12, 13, 14, 15, 16 as 5 combos

 */

/* STEP 1: Remove 2/3 letter words */



DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;


CASE WHEN WCNT = 1 THEN SET L1 = W1;
/* If it is just a single small word, ignore it and don't do scrape_design */
IF (SELECT LENGTH(L1)) < 5 THEN UPDATE OPN_KW_TAGS 
SET SCRAPE_DESIGN_DONE = 'R' WHERE KEYID = KID ; LEAVE llistproc ;
/* If it is just a single very large word, ignore it and don't do scrape_design */
ELSEIF (SELECT LENGTH(L1)) > 20 THEN UPDATE OPN_KW_TAGS 
SET SCRAPE_DESIGN_DONE = 'R' WHERE KEYID = KID ; LEAVE llistproc ;
/* Check if the word already exists as an LWORD. then ignore and don't do scrape design */
ELSEIF (SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE L1) > 0 THEN UPDATE OPN_KW_TAGS 
SET SCRAPE_DESIGN_DONE = 'R' WHERE KEYID = KID ; LEAVE llistproc ;

ELSE UPDATE OPN_KW_TAGS SET LIKE1 = CONCAT('%', L1, '%'), SCRAPE_DESIGN_DONE = 'Y'
, SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ;

CALL OPN_UKW_TAGGINGKW(TID, KID) ;

END IF ;

WHEN WCNT = 2 THEN SET L1 = W1; SET L2 = W2 ;
/* Check if the ONE OF THE wordS already exists as an LWORD. then replace it with % */
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%')) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L2, '%', L1, '%') ;


IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR 
(SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) )
THEN SET C1 = 'XXZQM1' ; END IF ;
IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR 
(SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) )
THEN SET C2 = 'XXZQM2' ; END IF ; 

-- SELECT C1, C2 ; 

-- SELECT L1, L2, C1, C2 ; LEAVE llistproc ;

UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, SCRAPE_DESIGN_DONE = 'Y'
, SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;

WHEN WCNT = 3 THEN SET L1 = W1; SET L2 = W2 ; SET L3 = W3 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L1, '%', L3, '%')
, C3 = CONCAT('%', L2, '%', L3, '%'), C4 = CONCAT('%', L1, '%', L2, '%', L3, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

/* Think of a KW like 'Path To Citizenship'. Here the end result should be only one LIKE values - that of '%path%citizenship%'
The ELSEIF statements below are achieving precisely that.
*/

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

-- SELECT C1,C2,C3,C4 ; -- LEAVE llistproc ;

 UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 
 
 CALL OPN_UKW_TAGGINGKW(TID, KID) ;

/*
SELECT CASE WHEN REPLACE(REPLACE('%PATH%CITIZENSHIP%', '%', ''), REPLACE('%CITIZENSHIP%', '%', ''), '') = REPLACE('%PATH%%', '%', '') THEN 'COMMON' ELSE 'NOT' END  ;
*/

WHEN WCNT = 4 THEN SET L1 = W1, L2 = W2, L3 = W3, L4 = W4 ;

CALL OPN_BUILD_LLIST44W(TID, KID, 4, L1, L2, L3, L4 ) ;
 
 WHEN WCNT = 5 THEN SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5 ;
 
 IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST44W(TID, KID, 4, L2, L3, L4, L5 ) ;  LEAVE llistproc ; END IF ;

 IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST44W(TID, KID, 4, L1, L3, L4, L5 ) ;  LEAVE llistproc ; END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST44W(TID, KID, 4, L1, L2, L4, L5 ) ;  LEAVE llistproc ;  END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST44W(TID, KID, 4, L1, L2, L3, L5 ) ;  LEAVE llistproc ; END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST44W(TID, KID, 4, L1, L2, L3, L4 ) ;  LEAVE llistproc ;  END IF ;
 
 CALL OPN_BUILD_LLIST45W(TID, KID, 5, L1, L2, L3, L4, L5 ) ;
 
  WHEN WCNT = 6 THEN SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5, L6 = W6 ;
 
 IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L2, L3, L4, L5, L6 ) ;  LEAVE llistproc ; END IF ;

 IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L1, L3, L4, L5, L6 ) ;  LEAVE llistproc ; END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L1, L2, L4, L5, L6 ) ;  LEAVE llistproc ;  END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L1, L2, L3, L5, L6 ) ;  LEAVE llistproc ; END IF ;
 
  IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L1, L2, L3, L4, L6 ) ;  LEAVE llistproc ;  END IF ;
 
   IF  (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L6, '%') ) > 0 
 THEN CALL OPN_BUILD_LLIST45W(TID, KID, 4, L1, L2, L3, L4, L5 ) ;  LEAVE llistproc ;  END IF ;
 
 CALL OPN_BUILD_LLIST46W(TID, KID, 5, L1, L2, L3, L4, L5, L6 ) ;
 
-- UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

END CASE ;

/*
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Barr whitewashed Mueller Report') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'democrats shutdown the government ') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Jussie smollette fakes attack ') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Mississipi Religious Freedom Law') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'rahul gandhi admits lying') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Trump Declares National Emergency') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'White House Climate Panel') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'American Crime Story:Versace') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', '7 Days In Entebbe') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Kasam Tere Pyar Ki') ;


*/

END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST44W //
CREATE PROCEDURE OPN_BUILD_LLIST44W(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60) )
llistproc44W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L1, '%', L3, '%'), C3 = CONCAT('%', L1, '%', L4, '%')
, C4 = CONCAT('%', L2, '%', L3, '%'),  C5 = CONCAT('%', L2, '%', L4, '%'),  C6 = CONCAT('%', L3, '%', L4, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

/* Think of a KW like 'Path To Citizenship'. Here the end result should be only one LIKE values - that of '%path%citizenship%'
The ELSEIF statements below are achieving precisely that.
*/

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L1 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L1 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L2 OR REPLACE(C4,'%', '') = L3 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L2 OR REPLACE(C5,'%', '') = L4 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C6,'%', '') = L3 OR REPLACE(C6,'%', '') = L4 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

--  SELECT C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc44W ;


UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;



END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST44W_TEST //
CREATE PROCEDURE OPN_BUILD_LLIST44W_TEST(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60) )
llistproc44W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L1, '%', L3, '%'), C3 = CONCAT('%', L1, '%', L4, '%')
, C4 = CONCAT('%', L2, '%', L3, '%'),  C5 = CONCAT('%', L2, '%', L4, '%'),  C6 = CONCAT('%', L3, '%', L4, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

/* Think of a KW like 'Path To Citizenship'. Here the end result should be only one LIKE values - that of '%path%citizenship%'
The ELSEIF statements below are achieving precisely that.
*/

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L1 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L1 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L2 OR REPLACE(C4,'%', '') = L3 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L2 OR REPLACE(C5,'%', '') = L4 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C6,'%', '') = L3 OR REPLACE(C6,'%', '') = L4 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

 SELECT C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc44W ;

/*
UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;

*/

/*
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Barr whitewashed Mueller Report') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'democrats shutdown the government ') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Jussie smollette fakes attack ') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Mississipi Religious Freedom Law') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'rahul gandhi admits lying') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Trump Declares National Emergency') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'White House Climate Panel') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'American Crime Story:Versace') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', '7 Days In Entebbe') ;
CALL OPN_SCRAPE_DESIGN_GEN(1, 2021, 'NRA', 'Kasam Tere Pyar Ki') ;


*/

END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST45W //
CREATE PROCEDURE OPN_BUILD_LLIST45W(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60), W5 varchar(60) )
llistproc45W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%')) > 0 THEN SET L5 = '%' ; END IF ;

/*
INSERT INTO OPN_LLIST_TEMP(TOPICID, KEYID, KEYWORD, SUBWORD, SUBLENGTH, SUBWNAME)
VALUES (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1)), 'L1')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1)), 'L2')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1)), 'L3')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)), 'L4')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1)), 'L5') ; 

SELECT * FROM OPN_LLIST_TEMP WHERE KEYID = KID ORDER BY SUBWNAME ;

SELECT SUBWNAME FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1' AND SUBLENGTH = (SELECT MAX(SUBLENGTH) FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1') ;
*/

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L2, '%', L3, '%'), C3 = CONCAT('%', L3, '%', L4, '%')
, C4 = CONCAT('%', L4, '%', L5, '%'),  C5 = CONCAT('%', L1, '%', L4, '%'),  C6 = CONCAT('%', L1, '%', L5, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L2 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L3 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L4 OR REPLACE(C4,'%', '') = L5 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L1 OR REPLACE(C5,'%', '') = L4 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L5 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

-- SELECT CONCAT('%', L1, '%'), CONCAT('%', L2, '%'), C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc45W ;


UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;




END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST45W_TEST //
CREATE PROCEDURE OPN_BUILD_LLIST45W_TEST(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60), W5 varchar(60) )
llistproc45W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%')) > 0 THEN SET L5 = '%' ; END IF ;

/*
INSERT INTO OPN_LLIST_TEMP(TOPICID, KEYID, KEYWORD, SUBWORD, SUBLENGTH, SUBWNAME)
VALUES (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1)), 'L1')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1)), 'L2')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1)), 'L3')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)), 'L4')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1)), 'L5') ; 

SELECT * FROM OPN_LLIST_TEMP WHERE KEYID = KID ORDER BY SUBWNAME ;

SELECT SUBWNAME FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1' AND SUBLENGTH = (SELECT MAX(SUBLENGTH) FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1') ;
*/

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L2, '%', L3, '%'), C3 = CONCAT('%', L3, '%', L4, '%')
, C4 = CONCAT('%', L4, '%', L5, '%'),  C5 = CONCAT('%', L1, '%', L4, '%'),  C6 = CONCAT('%', L1, '%', L5, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L2 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L3 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L4 OR REPLACE(C4,'%', '') = L5 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L1 OR REPLACE(C5,'%', '') = L4 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L5 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

 SELECT CONCAT('%', L1, '%'), CONCAT('%', L2, '%'), C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc45W ;

/*
UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;
*/



END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST46W //
CREATE PROCEDURE OPN_BUILD_LLIST46W(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60), W5 varchar(60), W6 varchar(60) )
llistproc46W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5, L6 = W6 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%')) > 0 THEN SET L5 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L6, '%')) > 0 THEN SET L6 = '%' ; END IF ;

/*
INSERT INTO OPN_LLIST_TEMP(TOPICID, KEYID, KEYWORD, SUBWORD, SUBLENGTH, SUBWNAME)
VALUES (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1)), 'L1')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1)), 'L2')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1)), 'L3')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)), 'L4')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1)), 'L5') ; 

SELECT * FROM OPN_LLIST_TEMP WHERE KEYID = KID ORDER BY SUBWNAME ;

SELECT SUBWNAME FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1' AND SUBLENGTH = (SELECT MAX(SUBLENGTH) FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1') ;
*/

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L2, '%', L3, '%'), C3 = CONCAT('%', L3, '%', L4, '%')
, C4 = CONCAT('%', L4, '%', L5, '%'),  C5 = CONCAT('%', L5, '%', L6, '%'),  C6 = CONCAT('%', L1, '%', L6, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L2 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L3 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L4 OR REPLACE(C4,'%', '') = L5 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L5 OR REPLACE(C5,'%', '') = L6 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C6,'%', '') = L1 OR REPLACE(C6,'%', '') = L6 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

-- SELECT C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc46W ;


UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;




END //
DELIMITER ;-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_BUILD_LLIST46W_TEST //
CREATE PROCEDURE OPN_BUILD_LLIST46W_TEST(TID INT, KID INT, WCNT INT, W1 varchar(60), W2 varchar(60), W3 varchar(60), W4 varchar(60), W5 varchar(60), W6 varchar(60) )
llistproc46W: BEGIN

/*

06/05/2019 AST: This proc is This proc is being built just for the 4 subword KW. It will be called for KWs that are > 4 KWs 
whenever one of the subwords is from SKIP_WORD

 */

DECLARE L1, L2, L3, L4, L5, L6, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10 varchar(60) ;
SET SQL_SAFE_UPDATES = 0;

SET L1 = W1, L2 = W2, L3 = W3, L4 = W4, L5 = W5, L6 = W6 ;

IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L1, '%') ) > 0 THEN SET L1 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L2, '%')) > 0 THEN SET L2 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L3, '%')) > 0 THEN SET L3 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L4, '%')) > 0 THEN SET L4 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L5, '%')) > 0 THEN SET L5 = '%' ; END IF ;
IF (SELECT COUNT(*) FROM OPN_SKIP_WORDS WHERE SKIP_WORD LIKE CONCAT('%', L6, '%')) > 0 THEN SET L6 = '%' ; END IF ;

/*
INSERT INTO OPN_LLIST_TEMP(TOPICID, KEYID, KEYWORD, SUBWORD, SUBLENGTH, SUBWNAME)
VALUES (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1)), 'L1')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1)), 'L2')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1)), 'L3')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)), 'L4')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1)), 'L5') ; 

SELECT * FROM OPN_LLIST_TEMP WHERE KEYID = KID ORDER BY SUBWNAME ;

SELECT SUBWNAME FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1' AND SUBLENGTH = (SELECT MAX(SUBLENGTH) FROM OPN_LLIST_TEMP WHERE KEYID = 105173 AND SUBWORD <> 'L1') ;
*/

SET C1 = CONCAT('%', L1, '%', L2, '%'), C2 = CONCAT('%', L2, '%', L3, '%'), C3 = CONCAT('%', L3, '%', L4, '%')
, C4 = CONCAT('%', L4, '%', L5, '%'),  C5 = CONCAT('%', L5, '%', L6, '%'),  C6 = CONCAT('%', L1, '%', L6, '%');

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C1) > 0 OR (SELECT LENGTH(REPLACE(C1, '%', '')) < 6 ) 
OR REPLACE(C1,'%', '') = L1 OR REPLACE(C1,'%', '') = L2 )
THEN SET C1 = 'XXZQMQ1' ; END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C2) > 0 OR (SELECT LENGTH(REPLACE(C2, '%', '')) < 6 ) 
OR REPLACE(C2,'%', '') = L2 OR REPLACE(C2,'%', '') = L3 )
THEN SET C2 = 'XXZQMQ2' ; 
 ELSEIF REPLACE(REPLACE(C1, '%', ''), REPLACE(C2, '%', ''), '') = REPLACE(C2, '%', '') THEN SET C2 = 'XXZQMQ3' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C3) > 0 OR (SELECT LENGTH(REPLACE(C3, '%', '')) < 6 ) 
OR REPLACE(C3,'%', '') = L3 OR REPLACE(C3,'%', '') = L4 )
THEN SET C3 = 'XXZQM4' ; 
 ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ5' ;
  ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C3, '%') THEN SET C3 = 'XXZQMQ6' ;
END IF ;

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C4) > 0 OR (SELECT LENGTH(REPLACE(C4, '%', '')) < 6 ) 
OR REPLACE(C4,'%', '') = L4 OR REPLACE(C4,'%', '') = L5 )
THEN SET C4 = 'XXZQM7' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ8' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ9' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C4, '%') THEN SET C4 = 'XXZQMQ10' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C5) > 0 OR (SELECT LENGTH(REPLACE(C5, '%', '')) < 6 ) 
OR REPLACE(C5,'%', '') = L5 OR REPLACE(C5,'%', '') = L6 )
THEN SET C5 = 'XXZQM11' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ12' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ13' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ14' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C5, '%') THEN SET C5 = 'XXZQMQ15' ;
END IF ; 

IF ((SELECT COUNT(*) FROM OPNV_LWORDS WHERE LWORDS LIKE C6) > 0 OR (SELECT LENGTH(REPLACE(C6, '%', '')) < 6 ) 
OR REPLACE(C6,'%', '') = L1 OR REPLACE(C6,'%', '') = L6 )
THEN SET C6 = 'XXZQM16' ; 
 ELSEIF REPLACE( C1, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ17' ;
  ELSEIF REPLACE( C2, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ18' ;
    ELSEIF REPLACE( C3, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ19' ;
        ELSEIF REPLACE( C4, '%', '')  LIKE  CONCAT('%', C6, '%') THEN SET C6 = 'XXZQMQ20' ;
END IF ; 

 SELECT C1,C2,C3,C4, C5, C6 ;  LEAVE llistproc46W ;

/* 
UPDATE OPN_KW_TAGS SET LIKE1 = C1, LIKE2 = C2, LIKE3 = C3, LIKE4 = C4, LIKE5 = C5, LIKE6 = C6, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ; 

CALL OPN_UKW_TAGGINGKW(TID, KID) ;
*/



END //
DELIMITER ;-- OPN_SCRAPE_DESIGN

 DELIMITER //
DROP PROCEDURE IF EXISTS OPN_SCRAPE_DESIGN //
CREATE PROCEDURE OPN_SCRAPE_DESIGN(stag2 varchar(65), L1 VARCHAR(60), L2 VARCHAR(60), L3 VARCHAR(60), L4 VARCHAR(60), L5 VARCHAR(60), L6 VARCHAR(60)
, NL1 VARCHAR(60), NL2 VARCHAR(60), NL3 VARCHAR(60))
BEGIN

/* OPN_SCRAPE_DESIGN

08222018 AST: To create the L and NL tags for scraping - updated into OPN_KW_TAGS table

CALL OPN_SCRAPE_DESIGN('ALPHA', '%ALPHA%', '','','','','', '%ALPHABET%', '%ALPHA%NUMER%', '') ;

*/

DECLARE SCR_DGN_DONE VARCHAR(3) ;
DECLARE KID INT;

SET SQL_SAFE_UPDATES = 0;
SET SCR_DGN_DONE = (SELECT COUNT(*) FROM OPN_KW_TAGS WHERE SCRAPE_TAG2 = stag2) ;
SET KID = (SELECT MAX(KEYID) FROM OPN_P_KW WHERE SCRAPE_TAG2 = stag2) ;

CASE WHEN SCR_DGN_DONE > 0 THEN 

UPDATE OPN_KW_TAGS SET LIKE1 = L1, LIKE2 = L2, LIKE3 = L3, LIKE4 = L4, LIKE5 = L5, LIKE6 = L6
, NOT_LIKE1 = NL1, NOT_LIKE2 = NL2, NOT_LIKE3 = NL3, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE SCRAPE_TAG2 = stag2 ;

 WHEN SCR_DGN_DONE = 0 THEN 

INSERT INTO OPN_KW_TAGS(TOPICID, KEYID, KEYWORDS, KW_TRIM, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3, SCRAPE_DESIGN_DONE, SCRAPE_DESIGN_DTM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE, KW_DTM) 
SELECT TOPICID, KEYID, KEYWORDS, KW_TRIM, SCRAPE_TAG1, SCRAPE_TAG2, '', 'N', NOW(), COUNTRY_CODE, ORIGIN_COUNTRY_CODE, CREATION_DTM
FROM OPN_P_KW K WHERE K.KEYID = KID ;

UPDATE OPN_KW_TAGS SET LIKE1 = L1, LIKE2 = L2, LIKE3 = L3, LIKE4 = L4, LIKE5 = L5, LIKE6 = L6
, NOT_LIKE1 = NL1, NOT_LIKE2 = NL2, NOT_LIKE3 = NL3, SCRAPE_DESIGN_DONE = 'Y', SCRAPE_DESIGN_DTM = NOW() WHERE KEYID = KID ;

END CASE ;
  
END //
DELIMITER ;

-- -- OPN_SCRAPE_DESIGN

 DELIMITER //
DROP PROCEDURE IF EXISTS OPN_SCRAPE_DESIGN_GEN //
-- CREATE PROCEDURE OPN_SCRAPE_DESIGN_GEN(userKW varchar(60), stag2 varchar(65), TID INT, KID INT, ccode VARCHAR(5))
CREATE PROCEDURE OPN_SCRAPE_DESIGN_GEN(TID INT, KID INT, STAG2 VARCHAR(60), userKW varchar(60))
thisproc: BEGIN

/* OPN_SCRAPE_DESIGN_GEN

05/16/2019: AST: This is the coolest proc in terms of impact !

    This proc will take a new KW created by the user and then:
        - Will determine if it is a genuine KW (by checking that num of words < 8 and number of consecutive blank spaces < 4)
        - If genuine, then it will strip out the words with length < 4 (because they seldom mean anything in terms of search)
        - It will strip out the reptetitions (like trump moron trump moron trump moron etc)
        - Then it will take the genuine words with at least 4 char and combine them to create the LIKE1 to LIKE6
        - Then it will update the OPN_KW_TAGS for that keyword
        - Then it will call the OPN_UKW_TAGGINGKW proc to complete the tagging and sweep in the scrapes from WSRU to WSR and tag them with the correct SCRAPE_TAG2
        - The OPN_UKW_TAGGINGKW will ensure that if there are any matches in the WSRU, they will be converted into posts 

Thus,
        It will make the OPINITO truly AI-capable. It will ensure that almost all genuine KWs that new users make, will immediately have 
        posts matching their newly created KWs.
        
        It will make the OPINITO system fully automated.
        
        Why the GEN in the name? It is like the General relativity - compared to special relativity :)

UPDATE OPN_KW_TAGS SET LIKE1 = L1, LIKE2 = L2, LIKE3 = L3, LIKE4 = L4, LIKE5 = L5, LIKE6 = L6
, NOT_LIKE1 = NL1, NOT_LIKE2 = NL2, NOT_LIKE3 = NL3, SCRAPE_DESIGN_DONE = 'Y' WHERE SCRAPE_TAG2 = stag2 ;

*/

DECLARE KW1, KW2, KW3, KW4, KW5 VARCHAR(60) ;
DECLARE SK1, SK2, SK3, SK4, SK5, SK6 VARCHAR(60) ;
DECLARE WCNT INT ;

/* STEP 1 - JUST TRIM THE KW */
SET KW1 = (SELECT TRIM(replaceNonAlpha(userKW))) ;

/* STEP 2 - LOOK FOR CONSECUTIVE BLANKS OF 4 OR MORE */

SET KW2 = (SELECT INSTR(KW1, '    ')) ;

 CASE WHEN KW2 > 0 THEN LEAVE thisproc ;
 
 ELSE
 
 /* STEP 3 - Replace 3 and 2 space occurrences with single space */
 
 SET KW3 = (SELECT REPLACE(REPLACE(KW1, '   ', ' '), '  ', ' ')) ;
 
 /* STEP 4 - Now do the word count */
 
 SET WCNT = (SELECT wordcount(kw3)) ;
 
 -- SELECT WCNT ;
 
 CASE WHEN WCNT > 6 THEN  LEAVE thisproc ;
 
 WHEN WCNT = 6 THEN  
 
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1) 
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)  
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  6), ' ', -1) INTO SK1, SK2, SK3, SK4, SK5, SK6 ;

CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, SK2, SK3,SK4,SK5,SK6 ) ;

/*
INSERT INTO OPN_LLIST_TEMP(TOPICID, KEYID, KEYWORD, SUBWORD, SUBLENGTH, SUBWNAME)
VALUES (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1)), 'L1')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1)), 'L2')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1)), 'L3')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)), 'L4')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1)), 'L5')
, (TID, KID, userKW, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  6), ' ', -1), LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  6), ' ', -1)), 'L6') ;

*/

 WHEN WCNT = 5 THEN  
 
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1) 
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)  
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  5), ' ', -1) INTO SK1, SK2, SK3, SK4, SK5 ;

CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, SK2, SK3,SK4,SK5,'' ) ;

  WHEN WCNT = 4 THEN  
 
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1) 
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  4), ' ', -1)  INTO SK1, SK2, SK3, SK4 ;

CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, SK2, SK3,SK4,'','' ) ;

  WHEN WCNT = 3 THEN  

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1) 
, SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  3), ' ', -1) INTO SK1, SK2, SK3 ;

CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, SK2, SK3,'','','' ) ;
 
  WHEN WCNT = 2 THEN  
 
 SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1), SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  2), ' ', -1) INTO SK1, SK2 ;
 
 CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, SK2, '','','','' ) ;
 
  WHEN WCNT = 1 THEN  
 
 SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(KW3, ' ',  1), ' ', -1) INTO SK1 ;
  
 CALL OPN_BUILD_LLIST(TID, KID, WCNT,SK1, '', '','','','' ) ;
  
  
  
END CASE ;
  END CASE ;
END //
DELIMITER ;

-- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS OPN_SUPPRESS_DUPES //
CREATE PROCEDURE OPN_SUPPRESS_DUPES(TID INT, INTVL INT, D_OR_M VARCHAR(10))
THISPROC: BEGIN

/* 

06/21/2019 AST: This proc is for deduping the posts. It should be run every day after the STP processes are over
I may include it as a standard proc at the end of every STP - or it can be included at the end of every STP run.
D_OR_M input param is for DAY OR MONTH.

10/11/2020 AST: Changing the base of the post dedupe from POST_DATETIME to POST_PROCESSED_DTM
Also using the BOT_FLAG = 'Y' so that the non-BOT posts are not deduped

*/

DROP TABLE IF EXISTS OPN_DUPE_POST_BASE ;

CASE WHEN D_OR_M = 'DAY' THEN 

CREATE TABLE OPN_DUPE_POST_BASE AS
SELECT P.POST_CONTENT, MAX(P.POST_ID) MAX_POST_ID FROM OPN_POSTS P, OPN_USERLIST U
WHERE P.POST_BY_USERID = U.USERID AND U.BOT_FLAG = 'Y'
AND P.POST_PROCESSED_DTM > NOW() - INTERVAL INTVL DAY   
GROUP BY P.POST_CONTENT HAVING COUNT(P.POST_ID) > 1;

UPDATE OPN_POSTS P, OPN_DUPE_POST_BASE D
SET P.CLEAN_POST_FLAG = 'Z' WHERE P.POST_CONTENT = D.POST_CONTENT AND P.POST_ID <> D.MAX_POST_ID
AND P.POST_PROCESSED_DTM > NOW() - INTERVAL INTVL DAY ;

WHEN D_OR_M = 'MONTH' THEN 

CREATE TABLE OPN_DUPE_POST_BASE AS
SELECT P.POST_CONTENT, MAX(P.POST_ID) MAX_POST_ID FROM OPN_POSTS P, OPN_USERLIST U
WHERE P.POST_BY_USERID = U.USERID AND U.BOT_FLAG = 'Y'
AND P.POST_PROCESSED_DTM > NOW() - INTERVAL INTVL MONTH   
GROUP BY P.POST_CONTENT HAVING COUNT(P.POST_ID) > 1;

UPDATE OPN_POSTS P, OPN_DUPE_POST_BASE D
SET P.CLEAN_POST_FLAG = 'Z' WHERE P.POST_CONTENT = D.POST_CONTENT AND P.POST_ID <> D.MAX_POST_ID
AND P.POST_PROCESSED_DTM > NOW() - INTERVAL INTVL MONTH ;

END CASE ;



  
  
  
END; //
 DELIMITER ;
 
 -- -- 
 
 
DELIMITER //
DROP PROCEDURE IF EXISTS OPN_UKW_TAGGING //
CREATE PROCEDURE OPN_UKW_TAGGING(TID INT)
BEGIN

/* 07/12/2018 AST: 

11/20/2018 AST: added AND SCRAPE_DESIGN_DONE = 'Y' to the cursor

*/

DECLARE WSRID, VA1 INT;
DECLARE NURL VARCHAR(500) ;
DECLARE L1,L2,L3,L4,L5,L6,NL1,NL2, NL3, STAG2, SCR_TOPIC VARCHAR(60) ;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT IFNULL(LIKE1, 'JQXXWZ'), IFNULL(LIKE2, 'JQXXWZ'), IFNULL(LIKE3, 'JQXXWZ')
  , IFNULL(LIKE4, 'JQXXWZ'), IFNULL(LIKE5, 'JQXXWZ'), IFNULL(LIKE6, 'JQXXWZ')
  , IFNULL(NOT_LIKE1, 'JQXXWZ'), IFNULL(NOT_LIKE2, 'JQXXWZ'), IFNULL(NOT_LIKE3, 'JQXXWZ'), SCRAPE_TAG2 FROM OPN_KW_TAGS 
  WHERE TOPICID = TID  AND SCRAPE_DESIGN_DONE = 'Y' ORDER BY KW_DTM DESC;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO L1,L2,L3,L4,L5,L6, NL1,NL2, NL3, STAG2;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
-- SET NURL = (SELECT UPPER(NEWS_URL) FROM WEB_SCRAPE_RAW WHERE ROW_ID = 687) ;
-- SET @VA1 := FLOOR(RAND()*(2-1+1))+1 ;

/* 
 03/12/2019 Adding condition for handling the SCRAPE_TOPIC. This is because some keywords get covered in news of multiple topics
 For ex. Jussie Smollett is covered in POLITICS, CELEB & ENT. The purpose of this change is to ensure that we only tag those news items that pertain to 
 the TID that is being called. Since Jussie Smollett is added as a KW in Celeb (TID=10) we should only push the CELEB news to the CELEB interest (INTEREST = TOPIC)
 
 03/14/2019 TID 9 (TRENDING) is a special case. It can have news from many diff topics - mainly POLITICS, SPORTS, CELEB, ENT, BUSINESS. 
 So we will ad a case statement to handle this.
 
 03/15/2019: Also handled CELEB and ENT (TID 5,10)
 
 04/23/2019 AST: removing the OCCODE from the entire Proc. This is because many KWs are covered in all three country codes 
 (E.g. maduro is covered extensively in USA, IND, GGG. When we impose the OCCODE on OPN_UKW_TAGGING, we miss out on the coverage
 in other countries.
 
 The STP_STAG23_MICRO proc simply goes by STAG2. Thus it doesn't care for OCCODE or CCODE anyway
 
 */
 
 CASE WHEN TID = 1 THEN SET SCR_TOPIC = 'POLITICS';
 WHEN TID = 2 THEN SET SCR_TOPIC = 'SPORTS' ;
 WHEN TID = 3 THEN SET SCR_TOPIC = 'SCIENCE' ;
 WHEN TID = 4 THEN SET SCR_TOPIC = 'BUSINESS' ;
 WHEN TID = 5 THEN SET SCR_TOPIC = 'ENT' ;
 WHEN TID = 6 THEN SET SCR_TOPIC = 'RELIGION' ;
 WHEN TID = 7 THEN SET SCR_TOPIC = 'LIFE' ;
 WHEN TID = 8 THEN SET SCR_TOPIC = 'MISC' ;
 WHEN TID = 9 THEN SET SCR_TOPIC = 'TREND' ;
 WHEN TID = 10 THEN SET SCR_TOPIC = 'CELEB' ;
 END CASE ;
 
 CASE WHEN TID = 9 THEN 
 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC IN ('POLITICS', 'SPORTS', 'CELEB', 'ENT', 'BUSINESS') AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;

WHEN TID IN (5,10) THEN

 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;

WHEN TID NOT IN (9,5,10) THEN

 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC =  SCR_TOPIC AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;


END CASE ;

CALL STP_STAG23_MICRO(STAG2, 'H') ;
CALL STP_STAG23_MICRO(STAG2, 'L') ;

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE  MOVED_TO_POST_FLAG = 'Y' ;

DELETE FROM WEB_SCRAPE_RAW WHERE  MOVED_TO_POST_FLAG = 'Y' ;

        END LOOP;
  CLOSE CURSOR_I;
END; //
 DELIMITER ;
 
 -- -- 
 
 
DELIMITER //
DROP PROCEDURE IF EXISTS OPN_UKW_TAGGINGKW //
CREATE PROCEDURE OPN_UKW_TAGGINGKW(TID INT, KID INT)
BEGIN


DECLARE WSRID, VA1 INT;
DECLARE NURL VARCHAR(500) ;
DECLARE L1,L2,L3,L4,L5,L6,NL1,NL2, NL3, STAG2, SCR_TOPIC VARCHAR(60) ;
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT IFNULL(LIKE1, 'JQXXWZ'), IFNULL(LIKE2, 'JQXXWZ'), IFNULL(LIKE3, 'JQXXWZ')
  , IFNULL(LIKE4, 'JQXXWZ'), IFNULL(LIKE5, 'JQXXWZ'), IFNULL(LIKE6, 'JQXXWZ')
  , IFNULL(NOT_LIKE1, 'JQXXWZ'), IFNULL(NOT_LIKE2, 'JQXXWZ'), IFNULL(NOT_LIKE3, 'JQXXWZ'), SCRAPE_TAG2 FROM OPN_KW_TAGS 
  WHERE KEYID = KID  AND SCRAPE_DESIGN_DONE = 'Y' ;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO L1,L2,L3,L4,L5,L6, NL1,NL2, NL3, STAG2;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

/* 

05/14/2019 AST: This proc is the KID version of the OPN_UKW_TAGGING. THis is built only to be used
with the createOPNTSearchKW2W call.

Trying to find the UNTAGGED posts and sweep them into WSR prior to Tagging and STP.

05/15/2019 AST: Adding the DELETE for scrapes that were swept from WSRU to WSR. 

07/24/2019 AST: Adding NEWS_HEADLINE and NEWS_EXCERPT  for possible matches with the new KW. Also adding post-dedupe

09/13/2019 AST: Adding 'SPORT' and 'SPORTS' to topic list in tid not in (1,5,9,10) case. this was forgotten earlier and hence the new Sports 
KWs were getting no posts created through OPN_UKW_TAGGINGKW
 
 */
 
 CASE WHEN TID = 1 THEN SET SCR_TOPIC = 'POLITICS';
 WHEN TID = 2 THEN SET SCR_TOPIC = 'SPORTS' ;
 WHEN TID = 3 THEN SET SCR_TOPIC = 'SCIENCE' ;
 WHEN TID = 4 THEN SET SCR_TOPIC = 'BUSINESS' ;
 WHEN TID = 5 THEN SET SCR_TOPIC = 'ENT' ;
 WHEN TID = 6 THEN SET SCR_TOPIC = 'RELIGION' ;
 WHEN TID = 7 THEN SET SCR_TOPIC = 'LIFE' ;
 WHEN TID = 8 THEN SET SCR_TOPIC = 'MISC' ;
 WHEN TID = 9 THEN SET SCR_TOPIC = 'TREND' ;
 WHEN TID = 10 THEN SET SCR_TOPIC = 'CELEB' ;
 END CASE ;
 
 CASE WHEN TID IN (1,9) THEN 
 
 INSERT INTO WEB_SCRAPE_RAW (SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT DISTINCT CURRENT_DATE(), SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ('POLITICS', 'SPORTS', 'CELEB', 'ENT', 'BUSINESS') 
AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );

/* 05/15/2019 AST: Adding the DELETE */

DELETE FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ('POLITICS', 'SPORTS', 'CELEB', 'ENT', 'BUSINESS') 
AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );

 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC IN ('POLITICS', 'SPORTS', 'CELEB', 'ENT', 'BUSINESS') AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
OR UPPER(NEWS_HEADLINE) LIKE L1 OR UPPER(NEWS_HEADLINE) LIKE L2 OR UPPER(NEWS_HEADLINE) LIKE L3 
OR UPPER(NEWS_HEADLINE) LIKE L4 OR UPPER(NEWS_HEADLINE) LIKE L5 OR UPPER(NEWS_HEADLINE) LIKE L6 
OR UPPER(NEWS_EXCERPT) LIKE L1 OR UPPER(NEWS_EXCERPT) LIKE L2 OR UPPER(NEWS_EXCERPT) LIKE L3 
OR UPPER(NEWS_EXCERPT) LIKE L4 OR UPPER(NEWS_EXCERPT) LIKE L5 OR UPPER(NEWS_EXCERPT) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;

WHEN TID IN (5,10) THEN

 INSERT INTO WEB_SCRAPE_RAW (SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT DISTINCT CURRENT_DATE(), SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ( 'CELEB', 'ENT') AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );

/* 05/15/2019 AST: Adding the DELETE */ 

DELETE FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ( 'CELEB', 'ENT') AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );
 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
OR UPPER(NEWS_HEADLINE) LIKE L1 OR UPPER(NEWS_HEADLINE) LIKE L2 OR UPPER(NEWS_HEADLINE) LIKE L3 
OR UPPER(NEWS_HEADLINE) LIKE L4 OR UPPER(NEWS_HEADLINE) LIKE L5 OR UPPER(NEWS_HEADLINE) LIKE L6 
OR UPPER(NEWS_EXCERPT) LIKE L1 OR UPPER(NEWS_EXCERPT) LIKE L2 OR UPPER(NEWS_EXCERPT) LIKE L3 
OR UPPER(NEWS_EXCERPT) LIKE L4 OR UPPER(NEWS_EXCERPT) LIKE L5 OR UPPER(NEWS_EXCERPT) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;

WHEN TID NOT IN (1,9,5,10) THEN

 INSERT INTO WEB_SCRAPE_RAW (SCRAPE_DATE, SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT DISTINCT CURRENT_DATE(), SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, COUNTRY_CODE, MOVED_TO_POST_FLAG, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ('SCIENCE', 'LIFE', 'MISC', 'RELIGION', 'BUSINESS', 'SPORTS', 'SPORT') 
AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );

/* 05/15/2019 AST: Adding the DELETE */ 

DELETE FROM WSR_UNTAGGED WHERE SCRAPE_TOPIC IN ('SCIENCE', 'LIFE', 'MISC', 'RELIGION', 'BUSINESS', 'SPORTS', 'SPORT') 
AND SCRAPE_DATE > NOW()- INTERVAL 1 MONTH
AND ( (NEWS_URL LIKE L1 OR NEWS_URL LIKE L2 OR NEWS_URL LIKE L3 OR NEWS_URL LIKE L4 OR NEWS_URL LIKE L5 OR NEWS_URL LIKE L6)
OR (NEWS_HEADLINE LIKE L1 OR NEWS_HEADLINE LIKE L2 OR NEWS_HEADLINE LIKE L3 OR NEWS_HEADLINE LIKE L4 OR NEWS_HEADLINE LIKE L5 OR NEWS_HEADLINE LIKE L6)
OR (NEWS_EXCERPT LIKE L1 OR NEWS_EXCERPT LIKE L2 OR NEWS_EXCERPT LIKE L3 OR NEWS_EXCERPT LIKE L4 OR NEWS_EXCERPT LIKE L5 OR NEWS_EXCERPT LIKE L6) );

 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = STAG2, SCRAPE_TAG3 = (CASE WHEN  MOD(ROW_ID, 2) = 0 THEN 'L' 
WHEN   MOD(ROW_ID, 2) = 1 THEN 'H' END ), TAG_DONE_FLAG = 'Y'
WHERE 1=1 AND TAG_DONE_FLAG = 'N'  AND  MOVED_TO_POST_FLAG = 'N'
AND SCRAPE_TOPIC =  SCR_TOPIC AND
(
UPPER(NEWS_URL) LIKE L1 OR UPPER(NEWS_URL) LIKE L2 OR UPPER(NEWS_URL) LIKE L3 
OR UPPER(NEWS_URL) LIKE L4 OR UPPER(NEWS_URL) LIKE L5 OR UPPER(NEWS_URL) LIKE L6 
OR UPPER(NEWS_HEADLINE) LIKE L1 OR UPPER(NEWS_HEADLINE) LIKE L2 OR UPPER(NEWS_HEADLINE) LIKE L3 
OR UPPER(NEWS_HEADLINE) LIKE L4 OR UPPER(NEWS_HEADLINE) LIKE L5 OR UPPER(NEWS_HEADLINE) LIKE L6 
OR UPPER(NEWS_EXCERPT) LIKE L1 OR UPPER(NEWS_EXCERPT) LIKE L2 OR UPPER(NEWS_EXCERPT) LIKE L3 
OR UPPER(NEWS_EXCERPT) LIKE L4 OR UPPER(NEWS_EXCERPT) LIKE L5 OR UPPER(NEWS_EXCERPT) LIKE L6 
)
AND 
(
UPPER(NEWS_URL) NOT LIKE NL1 AND UPPER(NEWS_URL) NOT LIKE NL2 AND UPPER(NEWS_URL) NOT LIKE NL3   
) ;


END CASE ;

CALL STP_STAG23_MICRO(STAG2, 'H') ;
CALL STP_STAG23_MICRO(STAG2, 'L') ;
CALL OPN_SUPPRESS_DUPES(1, 1 , 'DAY');

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE  MOVED_TO_POST_FLAG = 'Y' ;

DELETE FROM WEB_SCRAPE_RAW WHERE  MOVED_TO_POST_FLAG = 'Y' ;

        END LOOP;
  CLOSE CURSOR_I;
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_GGG //
CREATE PROCEDURE STP_GRAND_GGG()
THISPROC: BEGIN

/* 
	10/09/2020 AST: removed the WSR_DEDUPE because it is being done in STP_MONITOR
    also changed the DELETE to capture the true null posts
*/

SET SQL_SAFE_UPDATES = 0;

CALL STP_GRAND_T1GGG() ;
DELETE FROM OPN_POSTS WHERE TOPICID = 1 AND POSTOR_COUNTRY_CODE = 'GGG' AND LENGTH(POST_CONTENT) < 5 ;

CALL STP_GRAND_T3() ;
DELETE FROM OPN_POSTS WHERE TOPICID = 3 AND POSTOR_COUNTRY_CODE = 'GGG' AND LENGTH(POST_CONTENT) < 5 ;


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_IND //
CREATE PROCEDURE STP_GRAND_IND()
THISPROC: BEGIN

/* 
08/24/2018 AST: changed the order to do all the IND dedupes first - otherwise we were getting tons of dupes due to mismatch of the topic order

04/04/2019 AST: Added OPINDIA sources to dedupe list

12/13/2020 AST: Removed the DEDUPE calls because the STP_MONITOR calls the WSR_DEDUPE_ALL 

*/

SET SQL_SAFE_UPDATES = 0;

-- CALL WSR_DEDUPE('ET/BIZ') ;


DELETE FROM WEB_SCRAPE_RAW WHERE UPPER(NEWS_URL) LIKE '%MARKETS/STOCKS%'  AND SCRAPE_SOURCE = 'ET/BIZ';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'INDSPORTS' WHERE SCRAPE_SOURCE = 'ET/BIZ'
AND UPPER(NEWS_URL) LIKE '%NEWS/SPORTS%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'POLITICS' WHERE SCRAPE_SOURCE = 'ET/BIZ'
AND UPPER(NEWS_URL) LIKE '%NEWS/POLITICS%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'INDBIZ' , SCRAPE_TAG2 = 'INDBIZ' , SCRAPE_TAG3 = 'INDBIZ' 
WHERE SCRAPE_SOURCE = 'ET/BIZ' AND SCRAPE_TAG1 = 'BUSINESS';

/*
CALL WSR_DEDUPE('DP/POLITICS') ;
CALL WSR_DEDUPE('IE/POLITICS') ;
CALL WSR_DEDUPE('REDIFF/POL') ; 

CALL WSR_DEDUPE('OPINDIA/MEDIA') ;
CALL WSR_DEDUPE('OPINDIA/OPED') ;
CALL WSR_DEDUPE('OPINDIA/POL') ; 
*/

CALL STP_GRAND_T9IND() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T1IND() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

/*
CALL WSR_DEDUPE('IE/ENT') ;
CALL WSR_DEDUPE('REDIFF/ENT') ;
CALL WSR_DEDUPE('TOI/ENT') ;
*/

CALL STP_GRAND_T10IND() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T5IND() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

-- CALL WSR_DEDUPE('DP/BIZ') ;


CALL STP_GRAND_T4IND() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

-- CALL WSR_DEDUPE('IE/SPORTS') ;
-- CALL WSR_DEDUPE('DP/SPORT') ;

CALL STP_GRAND_T2IND() ;
DELETE FROM OPN_POSTS WHERE LENGTH(POST_CONTENT) < 4 ;


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T10IND //
CREATE PROCEDURE STP_GRAND_T10IND()
THISPROC: BEGIN

/* 

05/07/2019 AST: replaced   AND SCRAPE_TAG1 = 'BOLLYWOOD'   with  AND SCRAPE_TOPIC IN ('CELEB', 'ENT')  
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/05/2020 AST: Adding the tagging of 25 untagged scrapes to CELEB NEWS KW
10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'srk'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHAH-RUKH%'     
OR UPPER(NEWS_URL) LIKE     '%SRK%' OR UPPER(NEWS_URL) LIKE     '%SHAH%RUKH%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'srk'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHAH-RUKH%'     
OR UPPER(NEWS_URL) LIKE     '%SRK%' OR UPPER(NEWS_URL) LIKE     '%SHAH%RUKH%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kangana'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KANGANA%'     
OR UPPER(NEWS_URL) LIKE     '%RANAUT%' ) AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')        AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kangana'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KANGANA%'     
OR UPPER(NEWS_URL) LIKE     '%RANAUT%' ) AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')        AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'salman'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALMAN%'     
OR UPPER(NEWS_URL) LIKE     '%SALLU%' OR UPPER(NEWS_URL) LIKE     '%TIGER%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'salman'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALMAN%'     
OR UPPER(NEWS_URL) LIKE     '%SALLU%'  OR UPPER(NEWS_URL) LIKE     '%TIGER%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aamir'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AAMIR%'     
OR UPPER(NEWS_URL) LIKE     '%AAMIR%KHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aamir'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AAMIR%'     
OR UPPER(NEWS_URL) LIKE     '%AAMIR%KHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'akshay'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AKSHAY%'     
OR UPPER(NEWS_URL) LIKE     '%AKSHAY%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'akshay'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AKSHAY%'     
OR UPPER(NEWS_URL) LIKE     '%AKSHAY%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'deepika'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEEPIKA%'     
OR UPPER(NEWS_URL) LIKE     '%PADUKON%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'deepika'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEEPIKA%'     
OR UPPER(NEWS_URL) LIKE     '%PADUKON%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hritik'    , SCRAPE_TAG3 = 'L'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HRITHIK%'     
OR UPPER(NEWS_URL) LIKE     '%ROSHAN%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hritik'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HRITHIK%'     
OR UPPER(NEWS_URL) LIKE     '%ROSHAN%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anushka'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ANUSHKA%'     
OR UPPER(NEWS_URL) LIKE     '%USHKA%%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anushka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ANUSHKA%'     
OR UPPER(NEWS_URL) LIKE     '%USHKA%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranveer'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANVEER%'     
OR UPPER(NEWS_URL) LIKE     '%RANVEER%%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranveer'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANVEER%'     
OR UPPER(NEWS_URL) LIKE     '%RANVEER%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'priyanka'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PRIYANKA%'     
OR UPPER(NEWS_URL) LIKE     '%PC%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'priyanka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PRIYANKA%'     
OR UPPER(NEWS_URL) LIKE     '%PC%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranbeer'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANBEER%'     
OR UPPER(NEWS_URL) LIKE     '%RAN%KAPOOR%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ranbeer'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RANBEER%'     
OR UPPER(NEWS_URL) LIKE     '%RAN%KAPOOR%%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'alia'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ALIA%'     
OR UPPER(NEWS_URL) LIKE     '%BHATT%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'alia'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ALIA%'     
OR UPPER(NEWS_URL) LIKE     '%BHATT%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitabh'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMITABH%'     
OR UPPER(NEWS_URL) LIKE     '%BACHCHAN%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitabh'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMITABH%'     
OR UPPER(NEWS_URL) LIKE     '%BACHCHAN%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'madhuri'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MADHURI%'     
OR UPPER(NEWS_URL) LIKE     '%MADHURI%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'madhuri'    , SCRAPE_TAG3 = 'H'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MADHURI%'     
OR UPPER(NEWS_URL) LIKE     '%MADHURI%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dharam'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DHARMENDRA%'     
OR UPPER(NEWS_URL) LIKE     '%DEOL%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dharam'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DHARMENDRA%'     
OR UPPER(NEWS_URL) LIKE     '%DEOL%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aish'    , SCRAPE_TAG3 = 'L'    
 WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AISHWA%'     
OR UPPER(NEWS_URL) LIKE     '%ABHISHEK%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aish'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AISHWA%'     
OR UPPER(NEWS_URL) LIKE     '%ABHISHEK%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'katrina'    , SCRAPE_TAG3 = 'L'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATRINA%'     
OR UPPER(NEWS_URL) LIKE     '%KAIF%' )  AND COUNTRY_CODE = 'IND'
 AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'katrina'    , SCRAPE_TAG3 = 'H'   
  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATRINA%'     
OR UPPER(NEWS_URL) LIKE     '%KAIF%' )  AND COUNTRY_CODE = 'IND' 
AND SCRAPE_TOPIC IN ('CELEB', 'ENT')       AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */


-- CALL STP_STAG23_1KWINSERT('srk', 'H', 2) ;
CALL STP_STAG23_MICRO('srk', 'H') ;

-- CALL STP_STAG23_1KWINSERT('srk', 'L', 3) ;
CALL STP_STAG23_MICRO('srk', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kangana', 'H', 2) ;
CALL STP_STAG23_MICRO('kangana', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kangana', 'L', 1) ;
CALL STP_STAG23_MICRO('kangana', 'L') ;

-- CALL STP_STAG23_1KWINSERT('salman', 'H', 3) ;
CALL STP_STAG23_MICRO('salman', 'H') ;

-- CALL STP_STAG23_1KWINSERT('salman', 'L', 3) ;
CALL STP_STAG23_MICRO('salman', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aamir', 'H', 3) ;
CALL STP_STAG23_MICRO('aamir', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aamir', 'L', 3) ;
CALL STP_STAG23_MICRO('aamir', 'L') ;

-- CALL STP_STAG23_1KWINSERT('akshay', 'H', 3) ;
CALL STP_STAG23_MICRO('akshay', 'H') ;

-- CALL STP_STAG23_1KWINSERT('akshay', 'L', 3) ;
CALL STP_STAG23_MICRO('akshay', 'L') ;

-- CALL STP_STAG23_1KWINSERT('deepika', 'H', 3) ;
CALL STP_STAG23_MICRO('deepika', 'H') ;

-- CALL STP_STAG23_1KWINSERT('deepika', 'L', 3) ;
CALL STP_STAG23_MICRO('deepika', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hritik', 'H', 3) ;
CALL STP_STAG23_MICRO('hritik', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hritik', 'L', 3) ;
CALL STP_STAG23_MICRO('hritik', 'L') ;

-- CALL STP_STAG23_1KWINSERT('anushka', 'H', 3) ;
CALL STP_STAG23_MICRO('anushka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('anushka', 'L', 3) ;
CALL STP_STAG23_MICRO('anushka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ranveer', 'H', 1) ;
CALL STP_STAG23_MICRO('ranveer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ranveer', 'L', 1) ;
CALL STP_STAG23_MICRO('ranveer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('priyanka', 'H', 1) ;
CALL STP_STAG23_MICRO('priyanka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('priyanka', 'L', 1) ;
CALL STP_STAG23_MICRO('priyanka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ranbeer', 'H', 1) ;
CALL STP_STAG23_MICRO('ranbeer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ranbeer', 'L', 1) ;
CALL STP_STAG23_MICRO('ranbeer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('alia', 'H', 1) ;
CALL STP_STAG23_MICRO('alia', 'H') ;

-- CALL STP_STAG23_1KWINSERT('alia', 'L', 1) ;
CALL STP_STAG23_MICRO('alia', 'L') ;

-- CALL STP_STAG23_1KWINSERT('amitabh', 'H', 1) ;
CALL STP_STAG23_MICRO('amitabh', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amitabh', 'L', 1) ;
CALL STP_STAG23_MICRO('amitabh', 'L') ;

-- CALL STP_STAG23_1KWINSERT('madhuri', 'H', 1) ;
CALL STP_STAG23_MICRO('madhuri', 'H') ;

-- CALL STP_STAG23_1KWINSERT('madhuri', 'L', 1) ;
CALL STP_STAG23_MICRO('madhuri', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dharam', 'H', 1) ;
CALL STP_STAG23_MICRO('dharam', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dharam', 'L', 1) ;
CALL STP_STAG23_MICRO('dharam', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aish', 'H', 1) ;
CALL STP_STAG23_MICRO('aish', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aish', 'L', 1) ;
CALL STP_STAG23_MICRO('aish', 'L') ;

-- CALL STP_STAG23_1KWINSERT('katrina', 'H', 1) ;
CALL STP_STAG23_MICRO('katrina', 'H') ;

-- CALL STP_STAG23_1KWINSERT('katrina', 'L', 1) ;
CALL STP_STAG23_MICRO('katrina', 'L') ;

/*  Completing the POLNEWS addition with STp MICRo call  */

CALL STP_STAG23_MICRO('CELEBNEWS', 'H') ;

CALL STP_STAG23_MICRO('CELEBNEWS', 'L') ;

/*  END OF Completing the POLNEWS addition with STp MICRo call  */



  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T10USA //
CREATE PROCEDURE STP_GRAND_T10USA()
THISPROC: BEGIN

/* 

    05/01/2019 AST:   removed CALL STP_STAG1_1KW(10, 'USACELEB', 'USA')
    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
    09/19/2020 AST: Adding the tagging of 25 untagged scrapes to CELEB NEWS KW
	10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

-- PRIOR TO THIS, THE WEB_SCRAPE_RAW MUST BE DEDUPED

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;
  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USACELEB', SCRAPE_TAG2 = 'USACELEB', SCRAPE_TAG3 = 'USACELEB' WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swift'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%TAYLOR%'     
OR UPPER(NEWS_URL) LIKE     '%-SWIFT-%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'swift'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%TAYLOR%'     
OR UPPER(NEWS_URL) LIKE     '%-SWIFT-%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kimk'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%KARDASH%'     
OR UPPER(NEWS_URL) LIKE     '%-KANYE-%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'kimk'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%KARDASH%'     
OR UPPER(NEWS_URL) LIKE     '%-KANYE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'depp'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DEPP%'     
OR UPPER(NEWS_URL) LIKE     '%-PIRATE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'depp'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DEPP%'     
OR UPPER(NEWS_URL) LIKE     '%-PIRATE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angie'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%ANGIE%'     
OR UPPER(NEWS_URL) LIKE     '%JOLIE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'angie'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%ANGIE%'     
OR UPPER(NEWS_URL) LIKE     '%JOLIE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pitt'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%PITT%'     
OR UPPER(NEWS_URL) LIKE     '%BRANGE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'pitt'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%PITT%'     
OR UPPER(NEWS_URL) LIKE     '%BRANGE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'julia'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%JULIA%ROB%'     
OR UPPER(NEWS_URL) LIKE     '%JULIA%ROB%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'julia'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%JULIA%ROB%'     
OR UPPER(NEWS_URL) LIKE     '%JULIA%ROB%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cruise'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%TOM%CRUISE%'     
OR UPPER(NEWS_URL) LIKE     '%CRUISE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'cruise'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%TOM%CRUISE%'     
OR UPPER(NEWS_URL) LIKE     '%CRUISE%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jlaw'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%JEN%LAWR%'     
OR UPPER(NEWS_URL) LIKE     '%JENNI%LAWR%%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'jlaw'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%JEN%LAWR%'     
OR UPPER(NEWS_URL) LIKE     '%JENNI%LAWR%%'  )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wahl'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%WAHL%'     
OR UPPER(NEWS_URL) LIKE     '%WAHL%')     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'wahl'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%WAHL%'     
OR UPPER(NEWS_URL) LIKE     '%WAHL%'  )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sandler'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%SANDLER%'     
OR UPPER(NEWS_URL) LIKE     '%SANDLER%')     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'sandler'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%SANDLER%'     
OR UPPER(NEWS_URL) LIKE     '%SANDLER%'  )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mila'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%KUNIS%'     
OR UPPER(NEWS_URL) LIKE     '%KUNIS%')     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'mila'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%KUNIS%'     
OR UPPER(NEWS_URL) LIKE     '%KUNIS%'  )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'scarjo'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%SCARLET%'     
OR UPPER(NEWS_URL) LIKE     '%JOHANSS%')     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'scarjo'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%SCARLET%'     
OR UPPER(NEWS_URL) LIKE     '%JOHANSS%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aniston'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%ANISTON%'     
OR UPPER(NEWS_URL) LIKE     '%ANISTON%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'aniston'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%ANISTON%'     
OR UPPER(NEWS_URL) LIKE     '%ANISTON%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'emma'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%EMMA%'     
OR UPPER(NEWS_URL) LIKE     '%EMMA%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'emma'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%EMMA%'     
OR UPPER(NEWS_URL) LIKE     '%EMMA%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vin'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DIESEL%'     
OR UPPER(NEWS_URL) LIKE     '%-VIN-%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'vin'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DIESEL%'     
OR UPPER(NEWS_URL) LIKE     '%-VIN-%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rock'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%THE%ROCK%'     
OR UPPER(NEWS_URL) LIKE     '%DWAYNE%JOHN%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'rock'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%THE%ROCK%'     
OR UPPER(NEWS_URL) LIKE     '%DWAYNE%JOHN%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'theron'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%CHARLIZ%'     
OR UPPER(NEWS_URL) LIKE     '%THERON%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'theron'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%CHARLIZ%'     
OR UPPER(NEWS_URL) LIKE     '%THERON%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'downey'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DOWNEY%'     
OR UPPER(NEWS_URL) LIKE     '%DOWNEY%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB' ORDER BY RAND() LIMIT 1  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =      'downey'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG2 = 'USACELEB'  AND (UPPER(NEWS_URL) LIKE     '%DOWNEY%'     
OR UPPER(NEWS_URL) LIKE     '%DOWNEY%' )     AND UPPER(SCRAPE_TAG1) = 'USACELEB'    ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'minaj'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MINAJ%' OR UPPER(NEWS_URL) LIKE     '%MINAJ%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'minaj'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MINAJ%' OR UPPER(NEWS_URL) LIKE     '%MINAJ%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'beyonce'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BEYONCE%' OR UPPER(NEWS_URL) LIKE     '%JAY%Z%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'beyonce'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BEYONCE%' OR UPPER(NEWS_URL) LIKE     '%JAY%Z%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'oprah'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%OPRAH%' OR UPPER(NEWS_URL) LIKE     '%WINFREY%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'oprah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%OPRAH%' OR UPPER(NEWS_URL) LIKE     '%WINFREY%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cardi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CARDI%B%' OR UPPER(NEWS_URL) LIKE     '%ALMANZ%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cardi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CARDI%B%' OR UPPER(NEWS_URL) LIKE     '%ALMANZ%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rihanna'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIHANNA%' OR UPPER(NEWS_URL) LIKE     '%RIHANNA%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rihanna'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIHANNA%' OR UPPER(NEWS_URL) LIKE     '%RIHANNA%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kperry'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATY%PERRY%' OR UPPER(NEWS_URL) LIKE     '%KATY%PERRY%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kperry'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATY%PERRY%' OR UPPER(NEWS_URL) LIKE     '%KATY%PERRY%%' )     
AND UPPER(SCRAPE_TAG1) IN ('USACELEB', 'USAENT')  ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('swift', 'H', 2) ;
CALL STP_STAG23_MICRO('swift', 'H') ;

-- CALL STP_STAG23_1KWINSERT('swift', 'L', 2) ;
CALL STP_STAG23_MICRO('swift', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kimk', 'H', 2) ;
CALL STP_STAG23_MICRO('kimk', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kimk', 'L', 2) ;
CALL STP_STAG23_MICRO('kimk', 'L') ;

-- CALL STP_STAG23_1KWINSERT('depp', 'H', 2) ;
CALL STP_STAG23_MICRO('depp', 'H') ;

-- CALL STP_STAG23_1KWINSERT('depp', 'L', 2) ;
CALL STP_STAG23_MICRO('depp', 'L') ;

-- CALL STP_STAG23_1KWINSERT('angie', 'H', 2) ;
CALL STP_STAG23_MICRO('angie', 'H') ;

-- CALL STP_STAG23_1KWINSERT('angie', 'L', 2) ;
CALL STP_STAG23_MICRO('angie', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pitt', 'H', 2) ;
CALL STP_STAG23_MICRO('pitt', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pitt', 'L', 2) ;
CALL STP_STAG23_MICRO('pitt', 'L') ;

-- CALL STP_STAG23_1KWINSERT('julia', 'H', 2) ;
CALL STP_STAG23_MICRO('julia', 'H') ;

-- CALL STP_STAG23_1KWINSERT('julia', 'L', 2) ;
CALL STP_STAG23_MICRO('julia', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cruise', 'H', 2) ;
CALL STP_STAG23_MICRO('cruise', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cruise', 'L', 2) ;
CALL STP_STAG23_MICRO('cruise', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jlaw', 'H', 2) ;
CALL STP_STAG23_MICRO('jlaw', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jlaw', 'L', 2) ;
CALL STP_STAG23_MICRO('jlaw', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sandler', 'H', 2) ;
CALL STP_STAG23_MICRO('sandler', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sandler', 'L', 2) ;
CALL STP_STAG23_MICRO('sandler', 'L') ;




-- CALL STP_STAG23_1KWINSERT('mila', 'H', 2) ;
CALL STP_STAG23_MICRO('mila', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mila', 'L', 2) ;
CALL STP_STAG23_MICRO('mila', 'L') ;

-- CALL STP_STAG23_1KWINSERT('vin', 'H', 2) ;
CALL STP_STAG23_MICRO('vin', 'H') ;

-- CALL STP_STAG23_1KWINSERT('vin', 'L', 2) ;
CALL STP_STAG23_MICRO('vin', 'L') ;

-- CALL STP_STAG23_1KWINSERT('emma', 'H', 2) ;
CALL STP_STAG23_MICRO('emma', 'H') ;

-- CALL STP_STAG23_1KWINSERT('emma', 'L', 2) ;
CALL STP_STAG23_MICRO('emma', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rock', 'H', 2) ;
CALL STP_STAG23_MICRO('rock', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rock', 'L', 2) ;
CALL STP_STAG23_MICRO('rock', 'L') ;



-- CALL STP_STAG23_1KWINSERT('aniston', 'H', 2) ;
CALL STP_STAG23_MICRO('aniston', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aniston', 'L', 2) ;
CALL STP_STAG23_MICRO('aniston', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wahl', 'H', 2) ;
CALL STP_STAG23_MICRO('wahl', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wahl', 'L', 2) ;
CALL STP_STAG23_MICRO('wahl', 'L') ;

-- CALL STP_STAG23_1KWINSERT('downey', 'H', 2) ;
CALL STP_STAG23_MICRO('downey', 'H') ;

-- CALL STP_STAG23_1KWINSERT('downey', 'L', 2) ;
CALL STP_STAG23_MICRO('downey', 'L') ;

-- CALL STP_STAG23_1KWINSERT('scarjo', 'H', 2) ;
CALL STP_STAG23_MICRO('scarjo', 'H') ;

-- CALL STP_STAG23_1KWINSERT('scarjo', 'L', 2) ;
CALL STP_STAG23_MICRO('scarjo', 'L') ;

-- CALL STP_STAG23_1KWINSERT('theron', 'H', 2) ;
CALL STP_STAG23_MICRO('theron', 'H') ;

-- CALL STP_STAG23_1KWINSERT('theron', 'L', 2) ;
CALL STP_STAG23_MICRO('theron', 'L') ;

-- 

-- CALL STP_STAG23_1KWINSERT('minaj', 'H', 2) ;
CALL STP_STAG23_MICRO('minaj', 'H') ;

-- CALL STP_STAG23_1KWINSERT('minaj', 'L', 2) ;
CALL STP_STAG23_MICRO('minaj', 'L') ;

-- CALL STP_STAG23_1KWINSERT('beyonce', 'H', 2) ;
CALL STP_STAG23_MICRO('beyonce', 'H') ;

-- CALL STP_STAG23_1KWINSERT('beyonce', 'L', 5) ;
CALL STP_STAG23_MICRO('beyonce', 'L') ;

-- CALL STP_STAG23_1KWINSERT('oprah', 'H', 2) ;
CALL STP_STAG23_MICRO('oprah', 'H') ;

-- CALL STP_STAG23_1KWINSERT('oprah', 'L', 5) ;
CALL STP_STAG23_MICRO('oprah', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cardi', 'H', 2) ;
CALL STP_STAG23_MICRO('cardi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cardi', 'L', 5) ;
CALL STP_STAG23_MICRO('cardi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rihanna', 'H', 2) ;
CALL STP_STAG23_MICRO('rihanna', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rihanna', 'L', 5) ;
CALL STP_STAG23_MICRO('rihanna', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kperry', 'H', 2) ;
CALL STP_STAG23_MICRO('kperry', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kperry', 'L', 5) ;
CALL STP_STAG23_MICRO('kperry', 'L') ;

/*  Completing the CELEBNEWS addition with STp MICRo call  */

CALL STP_STAG23_MICRO('CELEBNEWS', 'H') ;

CALL STP_STAG23_MICRO('CELEBNEWS', 'L') ;

/*  END OF Completing the CELEBNEWS addition with STp MICRo call  */
  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T1GGG //
CREATE PROCEDURE STP_GRAND_T1GGG()
THISPROC: BEGIN

/* 

80007	Theresa May	tmay	H	1008004	OU1008004
80007	Theresa May	tmay	L	1008003	OU1008003
80008	Jeremy Corbyn	corbyn	H	1008006	OU1008006
80008	Jeremy Corbyn	corbyn	L	1008005	OU1008005
80009	Justin Trudeau	trudeau	H	1008008	OU1008008
80009	Justin Trudeau	trudeau	L	1008007	OU1008007
80010	Emmanuel Macron	macron	H	1008010	OU1008010
80010	Emmanuel Macron	macron	L	1008009	OU1008009
80011	Marine Le Pen	lepen	H	1008014	OU1008014
80011	Marine Le Pen	lepen	L	1008013	OU1008013
80012	Xi Jinping	xi	H	1020606	GGST1020606
80012	Xi Jinping	xi	L	1008011	OU1008011
80013	Vladimir Putin	putin	H	1008016	OU1008016
80013	Vladimir Putin	putin	L	1008015	OU1008015
80014	Benjamin Netanyahu	netanyahu	H	1008002	OU1008002
80014	Benjamin Netanyahu	netanyahu	L	1008001	OU1008001
80015	Mahmoud Abbas	abbas	H	1020609	GGST1020609
80015	Mahmoud Abbas	abbas	L	1008017	OU1008017
80016	Angela Merkel	merkel	H	1008012	OU1008012
80016	Angela Merkel	merkel	L	1020620	GGST1020620

04/25/2019 AST: Removing the CALL STP_STAG1_1KW(1, 'GPOL', 'GGG')  because it is not productive 

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'GPOL' ,SCRAPE_TAG2 = 'GPOL', SCRAPE_TAG3 = 'GPOL' 
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tmay'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THERESA%MAY%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'corbyn'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CORBYN%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tmay'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THERESA%MAY%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'corbyn'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CORBYN%' 
OR UPPER(NEWS_URL) LIKE     '%BRITAIN%%'  OR UPPER(NEWS_URL) LIKE     '-UK%'
OR UPPER(NEWS_URL) LIKE     '%BRITISH%' OR UPPER(NEWS_URL) LIKE     'UK%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'trudeau'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TRUDEAU%' 
OR UPPER(NEWS_URL) LIKE     '%CANADA%%'  OR UPPER(NEWS_URL) LIKE     'CANADI%'
OR UPPER(NEWS_URL) LIKE     '%OTTAWA%' )     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'trudeau'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TRUDEAU%' 
OR UPPER(NEWS_URL) LIKE     '%CANADA%%'  OR UPPER(NEWS_URL) LIKE     'CANADI%'
OR UPPER(NEWS_URL) LIKE     '%OTTAWA%' )     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;  

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macron'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MACRON%' 
OR UPPER(NEWS_URL) LIKE     '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lepen'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LE%PEN%' 
OR UPPER(NEWS_URL) LIKE      '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%') 
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macron'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MACRON%' 
OR UPPER(NEWS_URL) LIKE     '%FRANCE%%'  OR UPPER(NEWS_URL) LIKE     'FRENCH%')     
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lepen'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LE%PEN%' ) 
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'xi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%XI%' 
OR UPPER(NEWS_URL) LIKE     '%JINPING%%'  OR UPPER(NEWS_URL) LIKE     '%CHINA%'
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%YUAN%'  
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%RENMIN%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'xi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%XI%' 
OR UPPER(NEWS_URL) LIKE     '%JINPING%%'  OR UPPER(NEWS_URL) LIKE     '%CHINA%'
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%YUAN%'  
 OR UPPER(NEWS_URL) LIKE     '%CHINESE%'  OR UPPER(NEWS_URL) LIKE     '%RENMIN%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'putin'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PUTIN%' 
OR UPPER(NEWS_URL) LIKE     '%RUSSIA%%'  OR UPPER(NEWS_URL) LIKE     '%UKRAIN%'
 OR UPPER(NEWS_URL) LIKE     '%CRIMEA%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'putin'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PUTIN%' 
OR UPPER(NEWS_URL) LIKE     '%RUSSIA%%'  OR UPPER(NEWS_URL) LIKE     '%UKRAIN%'
 OR UPPER(NEWS_URL) LIKE     '%CRIMEA%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'netanyahu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NETANYAH%' OR UPPER(NEWS_URL) LIKE     '%ISRAEL%%'   )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'netanyahu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NETANYAH%' OR UPPER(NEWS_URL) LIKE     '%ISRAEL%%'   )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 3 ;       

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'abbas'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ABBAS%' 
OR UPPER(NEWS_URL) LIKE     '%PALESTIN%%'  OR UPPER(NEWS_URL) LIKE     '%GAZA%%' 
OR UPPER(NEWS_URL) LIKE     '%WEST%BANK%' OR UPPER(NEWS_URL) LIKE     '%-PLO-%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'abbas'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ABBAS%' 
OR UPPER(NEWS_URL) LIKE     '%PALESTIN%%'  OR UPPER(NEWS_URL) LIKE     '%GAZA%%' 
OR UPPER(NEWS_URL) LIKE     '%WEST%BANK%' OR UPPER(NEWS_URL) LIKE     '%-PLO-%' )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'merkel'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MERKEL%' 
OR UPPER(NEWS_URL) LIKE     '%GERMAN%%'  OR UPPER(NEWS_URL) LIKE     '%EURO%%'  )          
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL') ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'merkel'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MERKEL%' 
OR UPPER(NEWS_URL) LIKE     '%GERMAN%%'  OR UPPER(NEWS_URL) LIKE     '%EURO%%'  )         
AND SCRAPE_TAG2 = 'GPOL' AND UPPER(SCRAPE_TAG1) IN ('GPOL')  ;

-- 

-- CALL STP_STAG1_1KW(1, 'GPOL', 'GGG') ;

-- 

-- CALL STP_STAG23_1KWINSERT('tmay', 'H', 2) ;
CALL STP_STAG23_MICRO('tmay', 'H') ;
-- CALL STP_STAG23_1KWINSERT('tmay', 'L', 3) ;
CALL STP_STAG23_MICRO('tmay', 'L') ;

-- CALL STP_STAG23_1KWINSERT('corbyn', 'H', 2) ;
CALL STP_STAG23_MICRO('corbyn', 'H') ;
-- CALL STP_STAG23_1KWINSERT('corbyn', 'L', 3) ;
CALL STP_STAG23_MICRO('corbyn', 'L') ;

-- CALL STP_STAG23_1KWINSERT('trudeau', 'H', 2) ;
CALL STP_STAG23_MICRO('trudeau', 'H') ;
-- CALL STP_STAG23_1KWINSERT('trudeau', 'L', 3) ;
CALL STP_STAG23_MICRO('trudeau', 'L') ;

-- CALL STP_STAG23_1KWINSERT('macron', 'H', 2) ;
CALL STP_STAG23_MICRO('macron', 'H') ;
-- CALL STP_STAG23_1KWINSERT('macron', 'L', 3) ;
CALL STP_STAG23_MICRO('macron', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lepen', 'H', 2) ;
CALL STP_STAG23_MICRO('lepen', 'H') ;
-- CALL STP_STAG23_1KWINSERT('lepen', 'L', 3) ;
CALL STP_STAG23_MICRO('lepen', 'L') ;

-- CALL STP_STAG23_1KWINSERT('xi', 'H', 2) ;
CALL STP_STAG23_MICRO('xi', 'H') ;
-- CALL STP_STAG23_1KWINSERT('xi', 'L', 3) ;
CALL STP_STAG23_MICRO('xi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('putin', 'H', 2) ;
CALL STP_STAG23_MICRO('putin', 'H') ;
-- CALL STP_STAG23_1KWINSERT('putin', 'L', 3) ;
CALL STP_STAG23_MICRO('putin', 'L') ;

-- CALL STP_STAG23_1KWINSERT('netanyahu', 'H', 2) ;
CALL STP_STAG23_MICRO('netanyahu', 'H') ;
-- CALL STP_STAG23_1KWINSERT('netanyahu', 'L', 3) ;
CALL STP_STAG23_MICRO('netanyahu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('abbas', 'H', 2) ;
CALL STP_STAG23_MICRO('abbas', 'H') ;
-- CALL STP_STAG23_1KWINSERT('abbas', 'L', 3) ;
CALL STP_STAG23_MICRO('abbas', 'L') ;

-- CALL STP_STAG23_1KWINSERT('merkel', 'H', 2) ;
CALL STP_STAG23_MICRO('merkel', 'H') ;
-- CALL STP_STAG23_1KWINSERT('merkel', 'L', 3) ;
CALL STP_STAG23_MICRO('merkel', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'GGG' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T1GGG', 'POLITICS', 'GGG', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP Logging addition */

  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T1IND //
CREATE PROCEDURE STP_GRAND_T1IND()
THISPROC: BEGIN

/* 
12/13/2018 AST: Added sweep into OPN_WEB_LINKS

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND'

08/30/2019 AST: Adding back NaMo

    	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
        
        09/05/2020 AST: Adding the tagging of 25 untagged scrapes to POLITICS NEWS KW
		10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEVENDRA%NAVIS%'     
OR UPPER(NEWS_URL) LIKE     '%MAH%GOV%' OR UPPER(NEWS_URL) LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DEVENDRA%NAVIS%'     
OR UPPER(NEWS_URL) LIKE     '%MAH%GOV%' OR UPPER(NEWS_URL) LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%YOGI%'     
OR UPPER(NEWS_URL) LIKE     '%ADITYA%NATH%' )
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%YOGI%'     
OR UPPER(NEWS_URL) LIKE     '%ADITYA%NATH%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JAITLEY%'     
OR UPPER(NEWS_URL) LIKE     '%MIN%FIN%' OR UPPER(NEWS_URL) LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JAITLEY%'     
OR UPPER(NEWS_URL) LIKE     '%MIN%FIN%' OR UPPER(NEWS_URL) LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SUSHMA%'     
OR UPPER(NEWS_URL) LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SUSHMA%'     
OR UPPER(NEWS_URL) LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ARNAB%'     
OR UPPER(NEWS_URL) LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ARNAB%'     
OR UPPER(NEWS_URL) LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SMRITI%'     
OR UPPER(NEWS_URL) LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SMRITI%'     
OR UPPER(NEWS_URL) LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PARRIKAR%'     
OR UPPER(NEWS_URL) LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PARRIKAR%'     
OR UPPER(NEWS_URL) LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMIT%SHAH%'     
OR UPPER(NEWS_URL) LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AMIT%SHAH%'     
OR UPPER(NEWS_URL) LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RSS%'     
OR UPPER(NEWS_URL) LIKE     '%RASH%SANGH%' OR UPPER(NEWS_URL) LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RSS%'     
OR UPPER(NEWS_URL) LIKE     '%RASH%SANGH%' OR UPPER(NEWS_URL) LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LALU%'     
OR UPPER(NEWS_URL) LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%LALU%'     
OR UPPER(NEWS_URL) LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THAROOR%'     
OR UPPER(NEWS_URL) LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%THAROOR%'     
OR UPPER(NEWS_URL) LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHARAD%PAWAR%'     
OR UPPER(NEWS_URL) LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SHARAD%PAWAR%'     
OR UPPER(NEWS_URL) LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%-AAP-%'     
OR UPPER(NEWS_URL) LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%-AAP-%'     
OR UPPER(NEWS_URL) LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CHIDAMBARAM%'     
OR UPPER(NEWS_URL) LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CHIDAMBARAM%'     
OR UPPER(NEWS_URL) LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DIDI%'     
OR UPPER(NEWS_URL) LIKE     '%MAMATA%' OR UPPER(NEWS_URL) LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%DIDI%'     
OR UPPER(NEWS_URL) LIKE     '%MAMATA%' OR UPPER(NEWS_URL) LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%OWAISI%'     
OR UPPER(NEWS_URL) LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%OWAISI%'     
OR UPPER(NEWS_URL) LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HARDIK%'     
OR UPPER(NEWS_URL) LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HARDIK%'     
OR UPPER(NEWS_URL) LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%UDDHAV%'     
OR UPPER(NEWS_URL) LIKE     '%THAKREY%' OR UPPER(NEWS_URL) LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%UDDHAV%'     
OR UPPER(NEWS_URL) LIKE     '%THAKREY%' OR UPPER(NEWS_URL) LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%sonia%'     
OR UPPER(NEWS_URL) LIKE     '%PRIYANKA%' OR UPPER(NEWS_URL) LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%sonia%'     
OR UPPER(NEWS_URL) LIKE     '%PRIYANKA%' OR UPPER(NEWS_URL) LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KEJRI%'     
OR UPPER(NEWS_URL) LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KEJRI%'     
OR UPPER(NEWS_URL) LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RAHUL%GANDHI%'     
OR UPPER(NEWS_URL) LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RAHUL%GANDHI%'     
OR UPPER(NEWS_URL) LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CONGRESS%'     
OR UPPER(NEWS_URL) LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CONGRESS%'     
OR UPPER(NEWS_URL) LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;



UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NARENDRA%MODI%'     
OR UPPER(NEWS_URL) LIKE     '%PM%MODI%' OR UPPER(NEWS_URL) LIKE     '%NAMO%' OR UPPER(NEWS_URL) LIKE     '%MODI%GOV%'
) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%NARENDRA%MODI%'     
OR UPPER(NEWS_URL) LIKE     '%PM%MODI%' OR UPPER(NEWS_URL) LIKE     '%NAMO%' OR UPPER(NEWS_URL) LIKE     '%MODI%GOV%'
)
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;



UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BJP%'     
OR UPPER(NEWS_URL) LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BJP%'     
OR UPPER(NEWS_URL) LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

/*

09/03/2019 AST: Adding NEWS_HEADLINE LIKE

*/

--
/* 05/25/2018 AST: removing the section below - because all kinds of crap news gets posted in politics
and we don't want to spam the instream with that 

start of the removal section */

/*

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'NDA', SCRAPE_TAG2 = 'NDA', SCRAPE_TAG3 = 'NDA' 
WHERE SCRAPE_SOURCE = 'DP/POLITICS' AND MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG1 = 'POLITICS' AND SCRAPE_TAG2 = SCRAPE_TAG3 ;

--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'UPA', SCRAPE_TAG2 = 'UPA', SCRAPE_TAG3 = 'UPA' 
WHERE SCRAPE_SOURCE <> 'DP/POLITICS' AND MOVED_TO_POST_FLAG = 'N' 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS' AND SCRAPE_TAG2 = SCRAPE_TAG3 ;

--

--

CALL STP_STAG1_1KW(1, 'NDA', 'IND') ;
CALL STP_MOP_UP('NDA') ;

CALL STP_STAG1_1KW(1, 'UPA', 'IND') ;
CALL STP_MOP_UP('UPA') ;

*/

/* end of crap news removal section */

--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%DEVENDRA%NAVIS%'     
OR NEWS_HEADLINE LIKE     '%MAH%GOV%' OR NEWS_HEADLINE LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%DEVENDRA%NAVIS%'     
OR NEWS_HEADLINE LIKE     '%MAH%GOV%' OR NEWS_HEADLINE LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%YOGI%'     
OR NEWS_HEADLINE LIKE     '%ADITYA%NATH%' )
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%YOGI%'     
OR NEWS_HEADLINE LIKE     '%ADITYA%NATH%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%JAITLEY%'     
OR NEWS_HEADLINE LIKE     '%MIN%FIN%' OR NEWS_HEADLINE LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%JAITLEY%'     
OR NEWS_HEADLINE LIKE     '%MIN%FIN%' OR NEWS_HEADLINE LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SUSHMA%'     
OR NEWS_HEADLINE LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SUSHMA%'     
OR NEWS_HEADLINE LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%ARNAB%'     
OR NEWS_HEADLINE LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%ARNAB%'     
OR NEWS_HEADLINE LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SMRITI%'     
OR NEWS_HEADLINE LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SMRITI%'     
OR NEWS_HEADLINE LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%PARRIKAR%'     
OR NEWS_HEADLINE LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%PARRIKAR%'     
OR NEWS_HEADLINE LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%AMIT%SHAH%'     
OR NEWS_HEADLINE LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%AMIT%SHAH%'     
OR NEWS_HEADLINE LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%RSS%'     
OR NEWS_HEADLINE LIKE     '%RASH%SANGH%' OR NEWS_HEADLINE LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%RSS%'     
OR NEWS_HEADLINE LIKE     '%RASH%SANGH%' OR NEWS_HEADLINE LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%LALU%'     
OR NEWS_HEADLINE LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%LALU%'     
OR NEWS_HEADLINE LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%THAROOR%'     
OR NEWS_HEADLINE LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%THAROOR%'     
OR NEWS_HEADLINE LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SHARAD%PAWAR%'     
OR NEWS_HEADLINE LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%SHARAD%PAWAR%'     
OR NEWS_HEADLINE LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%-AAP-%'     
OR NEWS_HEADLINE LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%-AAP-%'     
OR NEWS_HEADLINE LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%CHIDAMBARAM%'     
OR NEWS_HEADLINE LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%CHIDAMBARAM%'     
OR NEWS_HEADLINE LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%DIDI%'     
OR NEWS_HEADLINE LIKE     '%MAMATA%' OR NEWS_HEADLINE LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%DIDI%'     
OR NEWS_HEADLINE LIKE     '%MAMATA%' OR NEWS_HEADLINE LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%OWAISI%'     
OR NEWS_HEADLINE LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%OWAISI%'     
OR NEWS_HEADLINE LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%HARDIK%'     
OR NEWS_HEADLINE LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%HARDIK%'     
OR NEWS_HEADLINE LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%UDDHAV%'     
OR NEWS_HEADLINE LIKE     '%THAKREY%' OR NEWS_HEADLINE LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%UDDHAV%'     
OR NEWS_HEADLINE LIKE     '%THAKREY%' OR NEWS_HEADLINE LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%sonia%'     
OR NEWS_HEADLINE LIKE     '%PRIYANKA%' OR NEWS_HEADLINE LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%sonia%'     
OR NEWS_HEADLINE LIKE     '%PRIYANKA%' OR NEWS_HEADLINE LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%KEJRI%'     
OR NEWS_HEADLINE LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%KEJRI%'     
OR NEWS_HEADLINE LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%RAHUL%GANDHI%'     
OR NEWS_HEADLINE LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%RAHUL%GANDHI%'     
OR NEWS_HEADLINE LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%CONGRESS%'     
OR NEWS_HEADLINE LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%CONGRESS%'     
OR NEWS_HEADLINE LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%NARENDRA%MODI%'     
OR NEWS_HEADLINE LIKE     '%PM%MODI%' OR NEWS_HEADLINE LIKE     '%NAMO%' OR NEWS_HEADLINE LIKE     '%MODI%GOV%'
) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS' AND TAG_DONE_FLAG = 'N'    AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%NARENDRA%MODI%'     
OR NEWS_HEADLINE LIKE     '%PM%MODI%' OR NEWS_HEADLINE LIKE     '%NAMO%' OR NEWS_HEADLINE LIKE     '%MODI%GOV%'
)
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'  AND TAG_DONE_FLAG = 'N'   AND MOD(ROW_ID, 2) = 0 ;



UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%BJP%'     
OR NEWS_HEADLINE LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%BJP%'     
OR NEWS_HEADLINE LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

-- END OF 'NEWS_HEADLINE LIKE' Addition

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%DEVENDRA%NAVIS%'     
OR NEWS_EXCERPT LIKE     '%MAH%GOV%' OR NEWS_EXCERPT LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fad'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%DEVENDRA%NAVIS%'     
OR NEWS_EXCERPT LIKE     '%MAH%GOV%' OR NEWS_EXCERPT LIKE     '%DNAVIS%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%YOGI%'     
OR NEWS_EXCERPT LIKE     '%ADITYA%NATH%' )
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yogi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%YOGI%'     
OR NEWS_EXCERPT LIKE     '%ADITYA%NATH%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%JAITLEY%'     
OR NEWS_EXCERPT LIKE     '%MIN%FIN%' OR NEWS_EXCERPT LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jetley'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%JAITLEY%'     
OR NEWS_EXCERPT LIKE     '%MIN%FIN%' OR NEWS_EXCERPT LIKE     '%FIN%MIN%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SUSHMA%'     
OR NEWS_EXCERPT LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'swaraj'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SUSHMA%'     
OR NEWS_EXCERPT LIKE     '%SWARAJ%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%ARNAB%'     
OR NEWS_EXCERPT LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'arnab'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%ARNAB%'     
OR NEWS_EXCERPT LIKE     '%GOSWAMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SMRITI%'     
OR NEWS_EXCERPT LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'smriti'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SMRITI%'     
OR NEWS_EXCERPT LIKE     '%IRANI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%PARRIKAR%'     
OR NEWS_EXCERPT LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'parrikar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%PARRIKAR%'     
OR NEWS_EXCERPT LIKE     '%GOA%CM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%AMIT%SHAH%'     
OR NEWS_EXCERPT LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amitshah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%AMIT%SHAH%'     
OR NEWS_EXCERPT LIKE     '%AMIT%SHAH%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%RSS%'     
OR NEWS_EXCERPT LIKE     '%RASH%SANGH%' OR NEWS_EXCERPT LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rss'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%RSS%'     
OR NEWS_EXCERPT LIKE     '%RASH%SANGH%' OR NEWS_EXCERPT LIKE     '%MOHAN%BHAG%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%LALU%'     
OR NEWS_EXCERPT LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lalu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%LALU%'     
OR NEWS_EXCERPT LIKE     '%RJD%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%THAROOR%'     
OR NEWS_EXCERPT LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tharoor'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%THAROOR%'     
OR NEWS_EXCERPT LIKE     '%THAROOR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SHARAD%PAWAR%'     
OR NEWS_EXCERPT LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawar'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%SHARAD%PAWAR%'     
OR NEWS_EXCERPT LIKE     '%PAWAR%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%-AAP-%'     
OR NEWS_EXCERPT LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aap'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%-AAP-%'     
OR NEWS_EXCERPT LIKE     '%AAM%ADMI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%CHIDAMBARAM%'     
OR NEWS_EXCERPT LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chidu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%CHIDAMBARAM%'     
OR NEWS_EXCERPT LIKE     '%CHIDAMBARAM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%DIDI%'     
OR NEWS_EXCERPT LIKE     '%MAMATA%' OR NEWS_EXCERPT LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'didi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%DIDI%'     
OR NEWS_EXCERPT LIKE     '%MAMATA%' OR NEWS_EXCERPT LIKE     '%BENGAL%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%OWAISI%'     
OR NEWS_EXCERPT LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'owaisi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%OWAISI%'     
OR NEWS_EXCERPT LIKE     '%MIM%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%HARDIK%'     
OR NEWS_EXCERPT LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dick'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%HARDIK%'     
OR NEWS_EXCERPT LIKE     '%HARDIK%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%UDDHAV%'     
OR NEWS_EXCERPT LIKE     '%THAKREY%' OR NEWS_EXCERPT LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'uddu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%UDDHAV%'     
OR NEWS_EXCERPT LIKE     '%THAKREY%' OR NEWS_EXCERPT LIKE     '%SHIV%SENA%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%sonia%'     
OR NEWS_EXCERPT LIKE     '%PRIYANKA%' OR NEWS_EXCERPT LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonia'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%sonia%'     
OR NEWS_EXCERPT LIKE     '%PRIYANKA%' OR NEWS_EXCERPT LIKE     '%GANDHI%')  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%KEJRI%'     
OR NEWS_EXCERPT LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kejri'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%KEJRI%'     
OR NEWS_EXCERPT LIKE     '%KEJRI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%RAHUL%GANDHI%'     
OR NEWS_EXCERPT LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raga'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%RAHUL%GANDHI%'     
OR NEWS_EXCERPT LIKE     '%RAHUL%GANDHI%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%CONGRESS%'     
OR NEWS_EXCERPT LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'congress'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%CONGRESS%'     
OR NEWS_EXCERPT LIKE     '%CONGRESS%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%NARENDRA%MODI%'     
OR NEWS_EXCERPT LIKE     '%PM%MODI%' OR NEWS_EXCERPT LIKE     '%NAMO%' OR NEWS_EXCERPT LIKE     '%MODI%GOV%'
) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'modi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%NARENDRA%MODI%'     
OR NEWS_EXCERPT LIKE     '%PM%MODI%' OR NEWS_EXCERPT LIKE     '%NAMO%' OR NEWS_EXCERPT LIKE     '%MODI%GOV%'
)
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;



UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%BJP%'     
OR NEWS_EXCERPT LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bjp'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_EXCERPT LIKE     '%BJP%'     
OR NEWS_EXCERPT LIKE     '%BHAR%JANAT%' )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;


-- END OF 'NEWS_EXCERPT LIKE' ADDITION

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('modi', 'H', 5) ;
 CALL STP_STAG23_MICRO('modi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('modi', 'L', 5) ;
 CALL STP_STAG23_MICRO('modi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('congress', 'H', 5) ;
CALL STP_STAG23_MICRO('congress', 'H') ;

-- CALL STP_STAG23_1KWINSERT('congress', 'L', 5) ;
CALL STP_STAG23_MICRO('congress', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raga', 'H', 5) ;
CALL STP_STAG23_MICRO('raga', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raga', 'L', 5) ;
CALL STP_STAG23_MICRO('raga', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kejri', 'H', 3) ;
CALL STP_STAG23_MICRO('kejri', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kejri', 'L', 3) ;
CALL STP_STAG23_MICRO('kejri', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sonia', 'H', 3) ;
CALL STP_STAG23_MICRO('sonia', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sonia', 'L', 3) ;
CALL STP_STAG23_MICRO('sonia', 'L') ;

-- CALL STP_STAG23_1KWINSERT('uddu', 'H', 2) ;
CALL STP_STAG23_MICRO('uddu', 'H') ;

-- CALL STP_STAG23_1KWINSERT('uddu', 'L', 3) ;
CALL STP_STAG23_MICRO('uddu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dick', 'H', 2) ;
CALL STP_STAG23_MICRO('dick', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dick', 'L', 3) ;
CALL STP_STAG23_MICRO('dick', 'L') ;

-- CALL STP_STAG23_1KWINSERT('owaisi', 'H', 2) ;
CALL STP_STAG23_MICRO('owaisi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('owaisi', 'L', 3) ;
CALL STP_STAG23_MICRO('owaisi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chidu', 'H', 2) ;
CALL STP_STAG23_MICRO('chidu', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chidu', 'L', 3) ;
CALL STP_STAG23_MICRO('chidu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('didi', 'H', 2) ;
CALL STP_STAG23_MICRO('didi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('didi', 'L', 3) ;
CALL STP_STAG23_MICRO('didi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aap', 'H', 2) ;
CALL STP_STAG23_MICRO('aap', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aap', 'L', 3) ;
CALL STP_STAG23_MICRO('aap', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pawar', 'H', 2) ;
CALL STP_STAG23_MICRO('pawar', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pawar', 'L', 3) ;
CALL STP_STAG23_MICRO('pawar', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tharoor', 'H', 2) ;
CALL STP_STAG23_MICRO('tharoor', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tharoor', 'L', 3) ;
CALL STP_STAG23_MICRO('tharoor', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lalu', 'H', 2) ;
CALL STP_STAG23_MICRO('lalu', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lalu', 'L', 3) ;
CALL STP_STAG23_MICRO('lalu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bjp', 'H', 5) ;
CALL STP_STAG23_MICRO('bjp', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bjp', 'L', 5) ;
CALL STP_STAG23_MICRO('bjp', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rss', 'H', 2) ;
CALL STP_STAG23_MICRO('rss', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rss', 'L', 3) ;
CALL STP_STAG23_MICRO('rss', 'L') ;

-- CALL STP_STAG23_1KWINSERT('amitshah', 'H', 2) ;
CALL STP_STAG23_MICRO('amitshah', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amitshah', 'L', 3) ;
CALL STP_STAG23_MICRO('amitshah', 'L') ;


-- CALL STP_STAG23_1KWINSERT('parrikar', 'H', 2) ;
CALL STP_STAG23_MICRO('parrikar', 'H') ;

-- CALL STP_STAG23_1KWINSERT('parrikar', 'L', 3) ;
CALL STP_STAG23_MICRO('parrikar', 'L') ;


-- CALL STP_STAG23_1KWINSERT('smriti', 'H', 2) ;
CALL STP_STAG23_MICRO('smriti', 'H') ;

-- CALL STP_STAG23_1KWINSERT('smriti', 'L', 3) ;
CALL STP_STAG23_MICRO('smriti', 'L') ;


-- CALL STP_STAG23_1KWINSERT('arnab', 'H', 2) ;
CALL STP_STAG23_MICRO('arnab', 'H') ;

-- CALL STP_STAG23_1KWINSERT('arnab', 'L', 3) ;
CALL STP_STAG23_MICRO('arnab', 'L') ;


-- CALL STP_STAG23_1KWINSERT('fad', 'H', 2) ;
CALL STP_STAG23_MICRO('fad', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fad', 'L', 3) ;
CALL STP_STAG23_MICRO('fad', 'L') ;

-- CALL STP_STAG23_1KWINSERT('yogi', 'H', 2) ;
CALL STP_STAG23_MICRO('yogi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('yogi', 'L', 1) ;
CALL STP_STAG23_MICRO('yogi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jetley', 'H', 3) ;
CALL STP_STAG23_MICRO('jetley', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jetley', 'L', 3) ;
CALL STP_STAG23_MICRO('jetley', 'L') ;

-- CALL STP_STAG23_1KWINSERT('swaraj', 'H', 3) ;
CALL STP_STAG23_MICRO('swaraj', 'H') ;

-- CALL STP_STAG23_1KWINSERT('swaraj', 'L', 3) ;
CALL STP_STAG23_MICRO('swaraj', 'L') ;


/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE
, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T9IND', 'TRENDING', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T1IND', 'POLITICS', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;
  
  
END

; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T1USA //
CREATE PROCEDURE STP_GRAND_T1USA()
THISPROC: BEGIN

/* 

12/13/2018 AST: Added sweep into OPN_WEB_LINKS

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA'

12/18/2018 : AST :  ADDED SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL

06/07/2019 AST: Removing the 1KW STP Procs - because now they are not needed

CALL STP_STAG1_1KW(1, 'USAPOL', 'USA') ;

-- CALL STP_STAG23_1KWINSERT('hillary', 'L', 2) ;

06/12/2019 AST: Added NR to the USAPOLRW classification
08/29/2019 AST: Trump added back
09/03/2019 AST: Added NEWS_HEADLINE LIKE 

05/07/2020 AST: REMOVED %AR%15% AND REPLACED WITH %RIFLE% FOR GUN CONTROL

	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/05/2020 AST: Adding the tagging of 25 untagged scrapes to POLITICS NEWS KW
10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.

10/07/2020 AST Added WAPO%, HILL%, BBRT% to the LW/RW classification
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

-- PRIOR TO THIS, THE WEB_SCRAPE_RAW MUST BE DEDUPED

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAPOLLW', SCRAPE_TAG2 = 'USAPOLLW', SCRAPE_TAG3 = 'USAPOLLW' 
WHERE (SCRAPE_SOURCE LIKE 'CNN%' OR SCRAPE_SOURCE LIKE 'YAHOO%' OR SCRAPE_SOURCE LIKE 'WAPO%' OR SCRAPE_SOURCE LIKE 'HILL%')
AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAPOLRW', SCRAPE_TAG2 = 'USAPOLRW', SCRAPE_TAG3 = 'USAPOLRW' 
WHERE (SCRAPE_SOURCE LIKE 'FOX%' OR SCRAPE_SOURCE LIKE 'RCP%' OR SCRAPE_SOURCE LIKE 'NR%' OR SCRAPE_SOURCE LIKE 'BBRT%') 
AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%HILLARY%' OR UPPER(NEWS_URL) LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%HILLARY%' OR UPPER(NEWS_URL) LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BERNIE%' OR UPPER(NEWS_URL) LIKE '%SANDERS%') AND UPPER(NEWS_URL) NOT LIKE '%SARA%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%BERNIE%' OR UPPER(NEWS_URL) LIKE '%SANDERS%')  AND UPPER(NEWS_URL) NOT LIKE '%SARA%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%OBAMA%' OR UPPER(NEWS_URL) LIKE '%BARACK%') AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%OBAMA%' OR UPPER(NEWS_URL) LIKE '%BARACK%')  AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PELOSI%' OR UPPER(NEWS_URL) LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PELOSI%' OR UPPER(NEWS_URL) LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SCHUMER%' OR UPPER(NEWS_URL) LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SCHUMER%' OR UPPER(NEWS_URL) LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%WARREN%' OR UPPER(NEWS_URL) LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%WARREN%' OR UPPER(NEWS_URL) LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%MUELLER%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MUELLER%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%KAMALA%' OR UPPER(NEWS_URL) LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%KAMALA%' OR UPPER(NEWS_URL) LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%FEINSTEIN%' OR UPPER(NEWS_URL) LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%FEINSTEIN%' OR UPPER(NEWS_URL) LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%DE%BLASIO%' OR UPPER(NEWS_URL) LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%DE%BLASIO%' OR UPPER(NEWS_URL) LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%COLBERT%' OR UPPER(NEWS_URL) LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%COLBERT%' OR UPPER(NEWS_URL) LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PATH%CITIZ%' OR UPPER(NEWS_URL) LIKE '%IMMI%'  
OR UPPER(NEWS_URL) LIKE '%DREAMERS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PATH%CITIZ%' OR UPPER(NEWS_URL) LIKE '%IMMI%'  
OR UPPER(NEWS_URL) LIKE '%DREAMERS%'  OR UPPER(NEWS_URL) LIKE '%ILLEG%IMMI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PLANNED%PARENT%' OR UPPER(NEWS_URL) LIKE '%ABORTION%'  
OR UPPER(NEWS_URL) LIKE '%ROE%WADE%' OR UPPER(NEWS_URL) LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PLANNED%PARENT%' OR UPPER(NEWS_URL) LIKE '%ABORTION%'  
OR UPPER(NEWS_URL) LIKE '%ROE%WADE%' OR UPPER(NEWS_URL) LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%ANTIFA%' OR UPPER(NEWS_URL) LIKE '%OCCUPY%' 
OR UPPER(NEWS_URL) LIKE '%FREE%SPEECH%' OR UPPER(NEWS_URL) LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%ANTIFA%' OR UPPER(NEWS_URL) LIKE '%OCCUPY%'  
OR UPPER(NEWS_URL) LIKE '%FREE%SPEECH%' OR UPPER(NEWS_URL) LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%LGBT%' OR UPPER(NEWS_URL) LIKE '%GAY%'  OR UPPER(NEWS_URL) LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%LGBT%' OR UPPER(NEWS_URL) LIKE '%GAY%'  OR UPPER(NEWS_URL) LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%CLIMATE%' OR UPPER(NEWS_URL) LIKE '%GLOBAL%WARM%'  OR UPPER(NEWS_URL) LIKE '%RENEWAB%'  
OR UPPER(NEWS_URL) LIKE '%FOSSIL%FUEL%'  OR UPPER(NEWS_URL) LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%CLIMATE%' OR UPPER(NEWS_URL) LIKE '%GLOBAL%WARM%'  OR UPPER(NEWS_URL) LIKE '%RENEWAB%'  
OR UPPER(NEWS_URL) LIKE '%FOSSIL%FUEL%'  OR UPPER(NEWS_URL) LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--


--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pence', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PENCE%' OR UPPER(NEWS_URL) LIKE '%VICE%PRESI%' OR UPPER(NEWS_URL) LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PENCE%' OR UPPER(NEWS_URL) LIKE '%VICE%PRESI%' OR UPPER(NEWS_URL) LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PAUL%RYAN%' OR UPPER(NEWS_URL) LIKE '%HOUSE%SPEAKER%' OR UPPER(NEWS_URL) LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%PAUL%RYAN%' OR UPPER(NEWS_URL) LIKE '%HOUSE%SPEAKER%' OR UPPER(NEWS_URL) LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MITCH%MCCON%' OR UPPER(NEWS_URL) LIKE '%SENATE%LEADER%' OR UPPER(NEWS_URL) LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MITCH%MCCON%' OR UPPER(NEWS_URL) LIKE '%SENATE%LEADER%' OR UPPER(NEWS_URL) LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%IVANKA%' OR UPPER(NEWS_URL) LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%IVANKA%' OR UPPER(NEWS_URL) LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SARA%SANDER%' OR UPPER(NEWS_URL) LIKE '%SARA%HUCKAB%' OR UPPER(NEWS_URL) LIKE '%HUCKAB%SANDER%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SARA%SANDER%' OR UPPER(NEWS_URL) LIKE '%SARA%HUCKAB%' OR UPPER(NEWS_URL) LIKE '%HUCKAB%SANDER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%JEFF%SESSION%' OR UPPER(NEWS_URL) LIKE '%SESSIONS%' OR UPPER(NEWS_URL) LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%JEFF%SESSION%' OR UPPER(NEWS_URL) LIKE '%SESSIONS%' OR UPPER(NEWS_URL) LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BETSY%DEVOS%' OR UPPER(NEWS_URL) LIKE '%DEVOS%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BETSY%DEVOS%' OR UPPER(NEWS_URL) LIKE '%DEVOS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SCOTT%PRUITT%' OR UPPER(NEWS_URL) LIKE '%PRUITT%'  OR UPPER(NEWS_URL) LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SCOTT%PRUITT%' OR UPPER(NEWS_URL) LIKE '%PRUITT%'  OR UPPER(NEWS_URL) LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%STEVE%MNUCHIN%' OR UPPER(NEWS_URL) LIKE '%MNUCHIN%'  OR UPPER(NEWS_URL) LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%STEVE%MNUCHIN%' OR UPPER(NEWS_URL) LIKE '%MNUCHIN%'  OR UPPER(NEWS_URL) LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%NIKKI%HALEY%' OR UPPER(NEWS_URL) LIKE '%AMBA%%HALEY%'  OR UPPER(NEWS_URL) LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%NIKKI%HALEY%' OR UPPER(NEWS_URL) LIKE '%AMBA%%HALEY%'  OR UPPER(NEWS_URL) LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%REX%TILLER%' OR UPPER(NEWS_URL) LIKE '%TILLERSO%'  OR UPPER(NEWS_URL) LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%REX%TILLER%' OR UPPER(NEWS_URL) LIKE '%TILLERSO%'  OR UPPER(NEWS_URL) LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%RUSH%LIMB%' OR UPPER(NEWS_URL) LIKE '%LIMBAU%'  OR UPPER(NEWS_URL) LIKE '%BLOWHARD%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%RUSH%LIMB%' OR UPPER(NEWS_URL) LIKE '%LIMBAU%'  OR UPPER(NEWS_URL) LIKE '%BLOWHARD%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%FOX%NEWS%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%FOX%NEWS%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%FOXNEWS%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BREIT%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%BREIT%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%BREIT%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%IMMIGR%' OR UPPER(NEWS_URL) LIKE '%-VISA-%'  OR UPPER(NEWS_URL) LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%IMMIGR%' OR UPPER(NEWS_URL) LIKE '%-VISA-%'  OR UPPER(NEWS_URL) LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%-NRA-%' OR UPPER(NEWS_URL) LIKE '%RIFLE%'  OR UPPER(NEWS_URL) LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%-NRA-%' OR UPPER(NEWS_URL) LIKE '%RIFLE%'  OR UPPER(NEWS_URL) LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%ABORTION%' OR UPPER(NEWS_URL) LIKE '%PLANNED%PARENT%'  OR UPPER(NEWS_URL) LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%ABORTION%' OR UPPER(NEWS_URL) LIKE '%PLANNED%PARENT%'  OR UPPER(NEWS_URL) LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%ALT%RIGHT%' OR UPPER(NEWS_URL) LIKE '%WHITE%SUPREM%%'  OR UPPER(NEWS_URL) LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%altright%' '%ALT%RIGHT%' OR UPPER(NEWS_URL) LIKE '%WHITE%SUPREM%%'  OR UPPER(NEWS_URL) LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%GLOBAL%WARM%' OR UPPER(NEWS_URL) LIKE '%CLIMATE%SCI%%'  OR UPPER(NEWS_URL) LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%GLOBAL%WARM%' OR UPPER(NEWS_URL) LIKE '%CLIMATE%SCI%%'  OR UPPER(NEWS_URL) LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE '%GUN%' OR UPPER(NEWS_URL) LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%GUN%' OR UPPER(NEWS_URL) LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--

/* 06/12/2019 - commenting out the trump part - just to research what drops out and can be captures by scrape_design_gen 
08/30/2019 AST: Adding back in */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%' ) ;
 
--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%HILLARY%' OR NEWS_HEADLINE LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%HILLARY%' OR NEWS_HEADLINE LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BERNIE%' OR NEWS_HEADLINE LIKE '%SANDERS%') AND UPPER(NEWS_URL) NOT LIKE '%SARA%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%BERNIE%' OR NEWS_HEADLINE LIKE '%SANDERS%')  AND UPPER(NEWS_URL) NOT LIKE '%SARA%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%OBAMA%' OR NEWS_HEADLINE LIKE '%BARACK%') AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%OBAMA%' OR NEWS_HEADLINE LIKE '%BARACK%')  AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PELOSI%' OR NEWS_HEADLINE LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PELOSI%' OR NEWS_HEADLINE LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SCHUMER%' OR NEWS_HEADLINE LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SCHUMER%' OR NEWS_HEADLINE LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%WARREN%' OR NEWS_HEADLINE LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%WARREN%' OR NEWS_HEADLINE LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%MUELLER%' OR NEWS_HEADLINE LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%MUELLER%' OR NEWS_HEADLINE LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%KAMALA%' OR NEWS_HEADLINE LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%KAMALA%' OR NEWS_HEADLINE LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%FEINSTEIN%' OR NEWS_HEADLINE LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%FEINSTEIN%' OR NEWS_HEADLINE LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%DE%BLASIO%' OR NEWS_HEADLINE LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%DE%BLASIO%' OR NEWS_HEADLINE LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%COLBERT%' OR NEWS_HEADLINE LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%COLBERT%' OR NEWS_HEADLINE LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PATH%CITIZ%' OR NEWS_HEADLINE LIKE '%IMMI%'  
OR NEWS_HEADLINE LIKE '%DREAMERS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PATH%CITIZ%' OR NEWS_HEADLINE LIKE '%IMMI%'  
OR NEWS_HEADLINE LIKE '%DREAMERS%'  OR NEWS_HEADLINE LIKE '%ILLEG%IMMI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PLANNED%PARENT%' OR NEWS_HEADLINE LIKE '%ABORTION%'  
OR NEWS_HEADLINE LIKE '%ROE%WADE%' OR NEWS_HEADLINE LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PLANNED%PARENT%' OR NEWS_HEADLINE LIKE '%ABORTION%'  
OR NEWS_HEADLINE LIKE '%ROE%WADE%' OR NEWS_HEADLINE LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%ANTIFA%' OR NEWS_HEADLINE LIKE '%OCCUPY%' 
OR NEWS_HEADLINE LIKE '%FREE%SPEECH%' OR NEWS_HEADLINE LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%ANTIFA%' OR NEWS_HEADLINE LIKE '%OCCUPY%'  
OR NEWS_HEADLINE LIKE '%FREE%SPEECH%' OR NEWS_HEADLINE LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%LGBT%' OR NEWS_HEADLINE LIKE '%GAY%'  OR NEWS_HEADLINE LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%LGBT%' OR NEWS_HEADLINE LIKE '%GAY%'  OR NEWS_HEADLINE LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%CLIMATE%' OR NEWS_HEADLINE LIKE '%GLOBAL%WARM%'  OR NEWS_HEADLINE LIKE '%RENEWAB%'  
OR NEWS_HEADLINE LIKE '%FOSSIL%FUEL%'  OR NEWS_HEADLINE LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%CLIMATE%' OR NEWS_HEADLINE LIKE '%GLOBAL%WARM%'  OR NEWS_HEADLINE LIKE '%RENEWAB%'  
OR NEWS_HEADLINE LIKE '%FOSSIL%FUEL%'  OR NEWS_HEADLINE LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--


--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pence', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PENCE%' OR NEWS_HEADLINE LIKE '%VICE%PRESI%' OR NEWS_HEADLINE LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PENCE%' OR NEWS_HEADLINE LIKE '%VICE%PRESI%' OR NEWS_HEADLINE LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PAUL%RYAN%' OR NEWS_HEADLINE LIKE '%HOUSE%SPEAKER%' OR NEWS_HEADLINE LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%PAUL%RYAN%' OR NEWS_HEADLINE LIKE '%HOUSE%SPEAKER%' OR NEWS_HEADLINE LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%MITCH%MCCON%' OR NEWS_HEADLINE LIKE '%SENATE%LEADER%' OR NEWS_HEADLINE LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%MITCH%MCCON%' OR NEWS_HEADLINE LIKE '%SENATE%LEADER%' OR NEWS_HEADLINE LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%IVANKA%' OR NEWS_HEADLINE LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%IVANKA%' OR NEWS_HEADLINE LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SARA%SANDER%' OR NEWS_HEADLINE LIKE '%SARA%HUCKAB%' OR NEWS_HEADLINE LIKE '%HUCKAB%SANDER%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SARA%SANDER%' OR NEWS_HEADLINE LIKE '%SARA%HUCKAB%' OR NEWS_HEADLINE LIKE '%HUCKAB%SANDER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%JEFF%SESSION%' OR NEWS_HEADLINE LIKE '%SESSIONS%' OR NEWS_HEADLINE LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%JEFF%SESSION%' OR NEWS_HEADLINE LIKE '%SESSIONS%' OR NEWS_HEADLINE LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BETSY%DEVOS%' OR NEWS_HEADLINE LIKE '%DEVOS%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BETSY%DEVOS%' OR NEWS_HEADLINE LIKE '%DEVOS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SCOTT%PRUITT%' OR NEWS_HEADLINE LIKE '%PRUITT%'  OR NEWS_HEADLINE LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%SCOTT%PRUITT%' OR NEWS_HEADLINE LIKE '%PRUITT%'  OR NEWS_HEADLINE LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%STEVE%MNUCHIN%' OR NEWS_HEADLINE LIKE '%MNUCHIN%'  OR NEWS_HEADLINE LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%STEVE%MNUCHIN%' OR NEWS_HEADLINE LIKE '%MNUCHIN%'  OR NEWS_HEADLINE LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%NIKKI%HALEY%' OR NEWS_HEADLINE LIKE '%AMBA%%HALEY%'  OR NEWS_HEADLINE LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%NIKKI%HALEY%' OR NEWS_HEADLINE LIKE '%AMBA%%HALEY%'  OR NEWS_HEADLINE LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%REX%TILLER%' OR NEWS_HEADLINE LIKE '%TILLERSO%'  OR NEWS_HEADLINE LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%REX%TILLER%' OR NEWS_HEADLINE LIKE '%TILLERSO%'  OR NEWS_HEADLINE LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%RUSH%LIMB%' OR NEWS_HEADLINE LIKE '%LIMBAU%'  OR NEWS_HEADLINE LIKE '%BLOWHARD%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%RUSH%LIMB%' OR NEWS_HEADLINE LIKE '%LIMBAU%'  OR NEWS_HEADLINE LIKE '%BLOWHARD%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%FOX%NEWS%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%FOX%NEWS%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%FOXNEWS%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%BREIT%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%BREIT%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%BREIT%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%IMMIGR%' OR NEWS_HEADLINE LIKE '%-VISA-%'  OR NEWS_HEADLINE LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%IMMIGR%' OR NEWS_HEADLINE LIKE '%-VISA-%'  OR NEWS_HEADLINE LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%-NRA-%' OR NEWS_HEADLINE LIKE '%RIFLE%'  OR NEWS_HEADLINE LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%-NRA-%' OR NEWS_HEADLINE LIKE '%RIFLE%'  OR NEWS_HEADLINE LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%ABORTION%' OR NEWS_HEADLINE LIKE '%PLANNED%PARENT%'  OR NEWS_HEADLINE LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%ABORTION%' OR NEWS_HEADLINE LIKE '%PLANNED%PARENT%'  OR NEWS_HEADLINE LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%ALT%RIGHT%' OR NEWS_HEADLINE LIKE '%WHITE%SUPREM%%'  OR NEWS_HEADLINE LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%altright%' '%ALT%RIGHT%' OR NEWS_HEADLINE LIKE '%WHITE%SUPREM%%'  OR NEWS_HEADLINE LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%GLOBAL%WARM%' OR NEWS_HEADLINE LIKE '%CLIMATE%SCI%%'  OR NEWS_HEADLINE LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%GLOBAL%WARM%' OR NEWS_HEADLINE LIKE '%CLIMATE%SCI%%'  OR NEWS_HEADLINE LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE '%GUN%' OR NEWS_HEADLINE LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%GUN%' OR NEWS_HEADLINE LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--

/* 06/12/2019 - commenting out the trump part - just to research what drops out and can be captures by scrape_design_gen 
08/30/2019 AST: Adding back in */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%TRUMP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_HEADLINE LIKE '%TRUMP%' ) ;

--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%HILLARY%' OR NEWS_EXCERPT LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hillary', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%HILLARY%' OR NEWS_EXCERPT LIKE '%CLINTON%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BERNIE%' OR NEWS_EXCERPT LIKE '%SANDERS%') AND UPPER(NEWS_URL) NOT LIKE '%SARA%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bernie', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%BERNIE%' OR NEWS_EXCERPT LIKE '%SANDERS%')  AND UPPER(NEWS_URL) NOT LIKE '%SARA%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%OBAMA%' OR NEWS_EXCERPT LIKE '%BARACK%') AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'obama', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%OBAMA%' OR NEWS_EXCERPT LIKE '%BARACK%')  AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%';

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PELOSI%' OR NEWS_EXCERPT LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pelosi', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PELOSI%' OR NEWS_EXCERPT LIKE '%HOUSE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SCHUMER%' OR NEWS_EXCERPT LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'schumer', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SCHUMER%' OR NEWS_EXCERPT LIKE '%SENATE%MINORITY%') -- AND UPPER(NEWS_URL) NOT LIKE '%OBAMACARE%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%WARREN%' OR NEWS_EXCERPT LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'warren', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%WARREN%' OR NEWS_EXCERPT LIKE '%LIZ%WARREN%')  AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%MUELLER%' OR NEWS_EXCERPT LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mueller', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%MUELLER%' OR NEWS_EXCERPT LIKE '%SPECIAL%COUNSEL%') AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%KAMALA%' OR NEWS_EXCERPT LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'kamala', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%KAMALA%' OR NEWS_EXCERPT LIKE '%SENATOR%HARRIS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%FEINSTEIN%' OR NEWS_EXCERPT LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fein', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%FEINSTEIN%' OR NEWS_EXCERPT LIKE '%SENATOR%DIANNE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%DE%BLASIO%' OR NEWS_EXCERPT LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deblasio', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%DE%BLASIO%' OR NEWS_EXCERPT LIKE '%N%Y%%MAYOR%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%COLBERT%' OR NEWS_EXCERPT LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'colbert', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%COLBERT%' OR NEWS_EXCERPT LIKE '%LATE%%SHOW%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PATH%CITIZ%' OR NEWS_EXCERPT LIKE '%IMMI%'  
OR NEWS_EXCERPT LIKE '%DREAMERS%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'path', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PATH%CITIZ%' OR NEWS_EXCERPT LIKE '%IMMI%'  
OR NEWS_EXCERPT LIKE '%DREAMERS%'  OR NEWS_EXCERPT LIKE '%ILLEG%IMMI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PLANNED%PARENT%' OR NEWS_EXCERPT LIKE '%ABORTION%'  
OR NEWS_EXCERPT LIKE '%ROE%WADE%' OR NEWS_EXCERPT LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pp', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PLANNED%PARENT%' OR NEWS_EXCERPT LIKE '%ABORTION%'  
OR NEWS_EXCERPT LIKE '%ROE%WADE%' OR NEWS_EXCERPT LIKE '%WOM%RIGHT%CHOOSE%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%ANTIFA%' OR NEWS_EXCERPT LIKE '%OCCUPY%' 
OR NEWS_EXCERPT LIKE '%FREE%SPEECH%' OR NEWS_EXCERPT LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'antifa', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%ANTIFA%' OR NEWS_EXCERPT LIKE '%OCCUPY%'  
OR NEWS_EXCERPT LIKE '%FREE%SPEECH%' OR NEWS_EXCERPT LIKE '%BLM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%LGBT%' OR NEWS_EXCERPT LIKE '%GAY%'  OR NEWS_EXCERPT LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'lgbt', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%LGBT%' OR NEWS_EXCERPT LIKE '%GAY%'  OR NEWS_EXCERPT LIKE '%TRANSG%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%CLIMATE%' OR NEWS_EXCERPT LIKE '%GLOBAL%WARM%'  OR NEWS_EXCERPT LIKE '%RENEWAB%'  
OR NEWS_EXCERPT LIKE '%FOSSIL%FUEL%'  OR NEWS_EXCERPT LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'clime', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%CLIMATE%' OR NEWS_EXCERPT LIKE '%GLOBAL%WARM%'  OR NEWS_EXCERPT LIKE '%RENEWAB%'  
OR NEWS_EXCERPT LIKE '%FOSSIL%FUEL%'  OR NEWS_EXCERPT LIKE '%KYOTO%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--


--

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pence', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PENCE%' OR NEWS_EXCERPT LIKE '%VICE%PRESI%' OR NEWS_EXCERPT LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PENCE%' OR NEWS_EXCERPT LIKE '%VICE%PRESI%' OR NEWS_EXCERPT LIKE '%VEEP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bannon', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BANNON%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PAUL%RYAN%' OR NEWS_EXCERPT LIKE '%HOUSE%SPEAKER%' OR NEWS_EXCERPT LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ryan', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%PAUL%RYAN%' OR NEWS_EXCERPT LIKE '%HOUSE%SPEAKER%' OR NEWS_EXCERPT LIKE '%SPEAKER%HOUSE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%MITCH%MCCON%' OR NEWS_EXCERPT LIKE '%SENATE%LEADER%' OR NEWS_EXCERPT LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mconel', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%MITCH%MCCON%' OR NEWS_EXCERPT LIKE '%SENATE%LEADER%' OR NEWS_EXCERPT LIKE '%MCCONNE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%IVANKA%' OR NEWS_EXCERPT LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ivanka', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%IVANKA%' OR NEWS_EXCERPT LIKE '%KUSHNER%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SARA%SANDER%' OR NEWS_EXCERPT LIKE '%SARA%HUCKAB%' OR NEWS_EXCERPT LIKE '%HUCKAB%SANDER%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'ssand', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SARA%SANDER%' OR NEWS_EXCERPT LIKE '%SARA%HUCKAB%' OR NEWS_EXCERPT LIKE '%HUCKAB%SANDER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%JEFF%SESSION%' OR NEWS_EXCERPT LIKE '%SESSIONS%' OR NEWS_EXCERPT LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'sessions', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%JEFF%SESSION%' OR NEWS_EXCERPT LIKE '%SESSIONS%' OR NEWS_EXCERPT LIKE '%ATTORN%GENERAL%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BETSY%DEVOS%' OR NEWS_EXCERPT LIKE '%DEVOS%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'devos', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BETSY%DEVOS%' OR NEWS_EXCERPT LIKE '%DEVOS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SCOTT%PRUITT%' OR NEWS_EXCERPT LIKE '%PRUITT%'  OR NEWS_EXCERPT LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'pruitt', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%SCOTT%PRUITT%' OR NEWS_EXCERPT LIKE '%PRUITT%'  OR NEWS_EXCERPT LIKE '%-EPA-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%STEVE%MNUCHIN%' OR NEWS_EXCERPT LIKE '%MNUCHIN%'  OR NEWS_EXCERPT LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'mnuchin', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%STEVE%MNUCHIN%' OR NEWS_EXCERPT LIKE '%MNUCHIN%'  OR NEWS_EXCERPT LIKE '%-TREASURY-%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%NIKKI%HALEY%' OR NEWS_EXCERPT LIKE '%AMBA%%HALEY%'  OR NEWS_EXCERPT LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'haley', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%NIKKI%HALEY%' OR NEWS_EXCERPT LIKE '%AMBA%%HALEY%'  OR NEWS_EXCERPT LIKE '%UNITED%NATIONS%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%REX%TILLER%' OR NEWS_EXCERPT LIKE '%TILLERSO%'  OR NEWS_EXCERPT LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tiller', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%REX%TILLER%' OR NEWS_EXCERPT LIKE '%TILLERSO%'  OR NEWS_EXCERPT LIKE '%SEC%STATE%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%RUSH%LIMB%' OR NEWS_EXCERPT LIKE '%LIMBAU%'  OR NEWS_EXCERPT LIKE '%BLOWHARD%') 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'rush', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%RUSH%LIMB%' OR NEWS_EXCERPT LIKE '%LIMBAU%'  OR NEWS_EXCERPT LIKE '%BLOWHARD%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'hannity', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%HANNITY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'coulter', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%COULTER%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%FOX%NEWS%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'fox', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%FOX%NEWS%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%FOXNEWS%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%BREIT%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'breit', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL)  LIKE '%BREIT%' ) AND UPPER(NEWS_URL) NOT LIKE '%HTTP%BREIT%'
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%IMMIGR%' OR NEWS_EXCERPT LIKE '%-VISA-%'  OR NEWS_EXCERPT LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'immi', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%IMMIGR%' OR NEWS_EXCERPT LIKE '%-VISA-%'  OR NEWS_EXCERPT LIKE '%AMNESTY%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%-NRA-%' OR NEWS_EXCERPT LIKE '%RIFLE%'  OR NEWS_EXCERPT LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'nra', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%-NRA-%' OR NEWS_EXCERPT LIKE '%RIFLE%'  OR NEWS_EXCERPT LIKE '%SHOOTING%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%ABORTION%' OR NEWS_EXCERPT LIKE '%PLANNED%PARENT%'  OR NEWS_EXCERPT LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'abortion', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%ABORTION%' OR NEWS_EXCERPT LIKE '%PLANNED%PARENT%'  OR NEWS_EXCERPT LIKE '%CONTRACEPT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%ALT%RIGHT%' OR NEWS_EXCERPT LIKE '%WHITE%SUPREM%%'  OR NEWS_EXCERPT LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altright', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%altright%' '%ALT%RIGHT%' OR NEWS_EXCERPT LIKE '%WHITE%SUPREM%%'  OR NEWS_EXCERPT LIKE '%STORMFRONT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%GLOBAL%WARM%' OR NEWS_EXCERPT LIKE '%CLIMATE%SCI%%'  OR NEWS_EXCERPT LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gwarm', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%GLOBAL%WARM%' OR NEWS_EXCERPT LIKE '%CLIMATE%SCI%%'  OR NEWS_EXCERPT LIKE '%POLLUTION%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE '%GUN%' OR NEWS_EXCERPT LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gun', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%GUN%' OR NEWS_EXCERPT LIKE '%MASS%SHOOTI%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;

--

/* 06/12/2019 - commenting out the trump part - just to research what drops out and can be captures by scrape_design_gen 
08/30/2019 AST: Adding back in */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TAG1 = 'USAPOLLW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%TRUMP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trump', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TAG1 = 'USAPOLRW' AND MOVED_TO_POST_FLAG = 'N'
AND (NEWS_EXCERPT LIKE '%TRUMP%' ) ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAPOL' WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' 
AND SCRAPE_TAG2 = SCRAPE_TAG3 AND MOVED_TO_POST_FLAG = 'N' ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG1_1KW(1, 'USAPOL', 'USA') ;
-- CALL STP_MOP_UP('USAPOL') ;

--

-- CALL STP_STAG23_1KWINSERT('hillary', 'L', 2) ;
CALL STP_STAG23_MICRO('hillary', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hillary', 'H', 5) ;
CALL STP_STAG23_MICRO('hillary', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bernie', 'L', 2) ;
CALL STP_STAG23_MICRO('bernie', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bernie', 'H', 5) ;
CALL STP_STAG23_MICRO('bernie', 'H') ;

-- CALL STP_STAG23_1KWINSERT('obama', 'L', 2) ;
CALL STP_STAG23_MICRO('obama', 'L') ;

-- CALL STP_STAG23_1KWINSERT('obama', 'H', 5) ;
CALL STP_STAG23_MICRO('obama', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pelosi', 'L', 2) ;
CALL STP_STAG23_MICRO('pelosi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pelosi', 'H', 5) ;
CALL STP_STAG23_MICRO('pelosi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('schumer', 'L', 2) ;
CALL STP_STAG23_MICRO('schumer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('schumer', 'H', 2) ;
CALL STP_STAG23_MICRO('schumer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('warren', 'L', 2) ;
CALL STP_STAG23_MICRO('warren', 'L') ;

-- CALL STP_STAG23_1KWINSERT('warren', 'H', 2) ;
CALL STP_STAG23_MICRO('warren', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mueller', 'L', 3) ;
CALL STP_STAG23_MICRO('mueller', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mueller', 'H', 5) ;
CALL STP_STAG23_MICRO('mueller', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kamala', 'L', 3) ;
CALL STP_STAG23_MICRO('kamala', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kamala', 'H', 5) ;
CALL STP_STAG23_MICRO('kamala', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fein', 'L', 3) ;
CALL STP_STAG23_MICRO('fein', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fein', 'H', 5) ;
CALL STP_STAG23_MICRO('fein', 'H') ;

-- CALL STP_STAG23_1KWINSERT('deblasio', 'L', 3) ;
CALL STP_STAG23_MICRO('deblasio', 'L') ;

-- CALL STP_STAG23_1KWINSERT('deblasio', 'H', 5) ;
CALL STP_STAG23_MICRO('deblasio', 'H') ;

-- CALL STP_STAG23_1KWINSERT('colbert', 'L', 3) ;
CALL STP_STAG23_MICRO('colbert', 'L') ;

-- CALL STP_STAG23_1KWINSERT('colbert', 'H', 5) ;
CALL STP_STAG23_MICRO('colbert', 'H') ;

-- CALL STP_STAG23_1KWINSERT('path', 'L', 3) ;
CALL STP_STAG23_MICRO('path', 'L') ;

-- CALL STP_STAG23_1KWINSERT('path', 'H', 5) ;
CALL STP_STAG23_MICRO('path', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pp', 'L', 3) ;
CALL STP_STAG23_MICRO('pp', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pp', 'H', 5) ;
CALL STP_STAG23_MICRO('pp', 'H') ;

-- CALL STP_STAG23_1KWINSERT('antifa', 'L', 3) ;
CALL STP_STAG23_MICRO('antifa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('antifa', 'H', 5) ;
CALL STP_STAG23_MICRO('antifa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lgbt', 'L', 3) ;
CALL STP_STAG23_MICRO('lgbt', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lgbt', 'H', 5) ;
CALL STP_STAG23_MICRO('lgbt', 'H') ;

-- CALL STP_STAG23_1KWINSERT('clime', 'L', 3) ;
CALL STP_STAG23_MICRO('clime', 'L') ;

-- CALL STP_STAG23_1KWINSERT('clime', 'H', 5) ;
CALL STP_STAG23_MICRO('clime', 'H') ;

--


--

-- CALL STP_STAG23_1KWINSERT('pence', 'H', 2) ;
CALL STP_STAG23_MICRO('pence', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pence', 'L', 2) ;
CALL STP_STAG23_MICRO('pence', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bannon', 'H', 2) ;
CALL STP_STAG23_MICRO('bannon', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bannon', 'L', 2) ;
CALL STP_STAG23_MICRO('bannon', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ryan', 'H', 2) ;
CALL STP_STAG23_MICRO('ryan', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ryan', 'L', 2) ;
CALL STP_STAG23_MICRO('ryan', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mconel', 'H', 2) ;
CALL STP_STAG23_MICRO('mconel', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mconel', 'L', 2) ;
CALL STP_STAG23_MICRO('mconel', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ivanka', 'H', 2) ;
CALL STP_STAG23_MICRO('ivanka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ivanka', 'L', 2) ;
CALL STP_STAG23_MICRO('ivanka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ssand', 'H', 2) ;
CALL STP_STAG23_MICRO('ssand', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ssand', 'L', 2) ;
CALL STP_STAG23_MICRO('ssand', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sessions', 'H', 2) ;
CALL STP_STAG23_MICRO('sessions', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sessions', 'L', 2) ;
CALL STP_STAG23_MICRO('sessions', 'L') ;

-- CALL STP_STAG23_1KWINSERT('devos', 'H', 2) ;
CALL STP_STAG23_MICRO('devos', 'H') ;

-- CALL STP_STAG23_1KWINSERT('devos', 'L', 2) ;
CALL STP_STAG23_MICRO('devos', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pruitt', 'H', 2) ;
CALL STP_STAG23_MICRO('pruitt', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pruitt', 'L', 2) ;
CALL STP_STAG23_MICRO('pruitt', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mnuchin', 'H', 2) ;
CALL STP_STAG23_MICRO('mnuchin', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mnuchin', 'L', 2) ;
CALL STP_STAG23_MICRO('mnuchin', 'L') ;

-- CALL STP_STAG23_1KWINSERT('haley', 'H', 2) ;
CALL STP_STAG23_MICRO('haley', 'H') ;

-- CALL STP_STAG23_1KWINSERT('haley', 'L', 2) ;
CALL STP_STAG23_MICRO('haley', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tiller', 'H', 2) ;
CALL STP_STAG23_MICRO('tiller', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tiller', 'L', 2) ;
CALL STP_STAG23_MICRO('tiller', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rush', 'H', 2) ;
CALL STP_STAG23_MICRO('rush', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rush', 'L', 2) ;
CALL STP_STAG23_MICRO('rush', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hannity', 'H', 2) ;
CALL STP_STAG23_MICRO('hannity', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hannity', 'L', 2) ;
CALL STP_STAG23_MICRO('hannity', 'L') ;

-- CALL STP_STAG23_1KWINSERT('coulter', 'H', 2) ;
CALL STP_STAG23_MICRO('coulter', 'H') ;

-- CALL STP_STAG23_1KWINSERT('coulter', 'L', 2) ;
CALL STP_STAG23_MICRO('coulter', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fox', 'H', 2) ;
CALL STP_STAG23_MICRO('fox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fox', 'L', 2) ;
CALL STP_STAG23_MICRO('fox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('breit', 'H', 2) ;
CALL STP_STAG23_MICRO('breit', 'H') ;

-- CALL STP_STAG23_1KWINSERT('breit', 'L', 2) ;
CALL STP_STAG23_MICRO('breit', 'L') ;

-- CALL STP_STAG23_1KWINSERT('immi', 'H', 2) ;
CALL STP_STAG23_MICRO('immi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('immi', 'L', 2) ;
CALL STP_STAG23_MICRO('immi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('abortion', 'H', 2) ;
CALL STP_STAG23_MICRO('abortion', 'H') ;

-- CALL STP_STAG23_1KWINSERT('abortion', 'L', 2) ;
CALL STP_STAG23_MICRO('abortion', 'L') ;

-- CALL STP_STAG23_1KWINSERT('altright', 'H', 2) ;
CALL STP_STAG23_MICRO('altright', 'H') ;

-- CALL STP_STAG23_1KWINSERT('altright', 'L', 2) ;
CALL STP_STAG23_MICRO('altright', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nra', 'H', 2) ;
CALL STP_STAG23_MICRO('nra', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nra', 'L', 2) ;
CALL STP_STAG23_MICRO('nra', 'L') ;

-- CALL STP_STAG23_1KWINSERT('gwarm', 'H', 2) ;
CALL STP_STAG23_MICRO('gwarm', 'H') ;

-- CALL STP_STAG23_1KWINSERT('gwarm', 'L', 2) ;
CALL STP_STAG23_MICRO('gwarm', 'L') ;


-- CALL STP_STAG23_1KWINSERT('gun', 'L', 2) ;
CALL STP_STAG23_MICRO('gun', 'L') ;

-- CALL STP_STAG23_1KWINSERT('gun', 'H', 2) ;
CALL STP_STAG23_MICRO('gun', 'H') ;

--


-- CALL STP_STAG23_1KWINSERT('trump', 'H', 2) ;
CALL STP_STAG23_MICRO('trump', 'H') ;

-- CALL STP_STAG23_1KWINSERT('trump', 'L', 2) ;
CALL STP_STAG23_MICRO('trump', 'L') ;


--

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T1USA', 'POLITICS', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2IND //
CREATE PROCEDURE STP_GRAND_T2IND()
THISPROC: BEGIN

/* 
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
            09/19/2020 AST: Adding the tagging of 25 untagged scrapes to sportsnews2 KW
10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/
DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl'  , SCRAPE_TAG2 =     'iplmumbai'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%MUMB%IND%'  OR UPPER(NEWS_URL) LIKE '%INDIANS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'     
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl'  , SCRAPE_TAG2 =     'iplmumbai'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%MUMB%IND%'  OR UPPER(NEWS_URL) LIKE '%INDIANS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'ipldelhi'      WHERE  (UPPER(NEWS_URL) LIKE '%DELH%DARE%'  OR UPPER(NEWS_URL) LIKE '%DAREDE%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'ipldelhi'      WHERE  (UPPER(NEWS_URL) LIKE '%DELH%DARE%'  OR UPPER(NEWS_URL) LIKE '%DAREDE%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplkings'      WHERE  (UPPER(NEWS_URL) LIKE '%PUNJ%KING%'  OR UPPER(NEWS_URL) LIKE '%KING%XI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplkings'      WHERE  (UPPER(NEWS_URL) LIKE '%PUNJ%KING%'  OR UPPER(NEWS_URL) LIKE '%KING%XI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplkings'      WHERE  (UPPER(NEWS_URL) LIKE '%PUNJ%KING%'  OR UPPER(NEWS_URL) LIKE '%KING%XI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplkings'      WHERE  (UPPER(NEWS_URL) LIKE '%PUNJ%KING%'  OR UPPER(NEWS_URL) LIKE '%KING%%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplchen'      WHERE  (UPPER(NEWS_URL) LIKE '%CHEN%SUPER%'  OR UPPER(NEWS_URL) LIKE '%SUPER%KING%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplchen'      WHERE  (UPPER(NEWS_URL) LIKE '%CHEN%SUPER%'  OR UPPER(NEWS_URL) LIKE '%SUPER%KING%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplkolk'      WHERE  (UPPER(NEWS_URL) LIKE '%KOLK%RIDER%'  OR UPPER(NEWS_URL) LIKE '%KNIGHT%RIDE%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplkolk'      WHERE  (UPPER(NEWS_URL) LIKE '%KOLK%RIDER%'  OR UPPER(NEWS_URL) LIKE '%KNIGHT%RIDE%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplbang'      WHERE  (UPPER(NEWS_URL) LIKE '%ROY%CHALL%'  OR UPPER(NEWS_URL) LIKE '%ROYAL%CHALL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplbang'      WHERE  (UPPER(NEWS_URL) LIKE '%ROY%CHALL%'  OR UPPER(NEWS_URL) LIKE '%ROYAL%CHALL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplhyd'      WHERE  (UPPER(NEWS_URL) LIKE '%HYD%SUN%'  OR UPPER(NEWS_URL) LIKE '%SUNRISER%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplhyd'      WHERE  (UPPER(NEWS_URL) LIKE '%HYD%SUN%'  OR UPPER(NEWS_URL) LIKE '%SUNRISER%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'iplroyals'      WHERE  (UPPER(NEWS_URL) LIKE '%RAJ%ROYALS%'  OR UPPER(NEWS_URL) LIKE '%ROYALS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 2 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'iplroyals'      WHERE  (UPPER(NEWS_URL) LIKE '%RAJ%ROYALS%'  OR UPPER(NEWS_URL) LIKE '%ROYALS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'sachin'      WHERE  (UPPER(NEWS_URL) LIKE '%SACHIN%TENDU%'  OR UPPER(NEWS_URL) LIKE '%TENDULKAR%'  OR UPPER(NEWS_URL) LIKE '%SRT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'sachin'      WHERE  (UPPER(NEWS_URL) LIKE '%SACHIN%TENDU%'  OR UPPER(NEWS_URL) LIKE '%TENDULKAR%'  OR UPPER(NEWS_URL) LIKE '%SRT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'kohli'      WHERE  (UPPER(NEWS_URL) LIKE '%VIRA%KOHLI%'  OR UPPER(NEWS_URL) LIKE '%KOHLI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'kohli'      WHERE  (UPPER(NEWS_URL) LIKE '%VIRA%KOHLI%'  OR UPPER(NEWS_URL) LIKE '%KOHLI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'dhoni'      WHERE  (UPPER(NEWS_URL) LIKE '%MAH%DHONI%'  OR UPPER(NEWS_URL) LIKE '%DHONI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'dhoni'      WHERE  (UPPER(NEWS_URL) LIKE '%MAH%DHONI%'  OR UPPER(NEWS_URL) LIKE '%DHONI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'shami'      WHERE  (UPPER(NEWS_URL) LIKE '%SHAMI%'  OR UPPER(NEWS_URL) LIKE '%SHAMI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'shami'      WHERE  (UPPER(NEWS_URL) LIKE '%SHAMI%'  OR UPPER(NEWS_URL) LIKE '%SHAMI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'jadeja'      WHERE  (UPPER(NEWS_URL) LIKE '%JADEJA%'  OR UPPER(NEWS_URL) LIKE '%JADEJA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'jadeja'      WHERE  (UPPER(NEWS_URL) LIKE '%JADEJA%'  OR UPPER(NEWS_URL) LIKE '%JADEJA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'rahane'      WHERE  (UPPER(NEWS_URL) LIKE '%RAHANE%'  OR UPPER(NEWS_URL) LIKE '%AJINKYA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'rahane'      WHERE  (UPPER(NEWS_URL) LIKE '%RAHANE%'  OR UPPER(NEWS_URL) LIKE '%AJINKYA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'dhawan'      WHERE  (UPPER(NEWS_URL) LIKE '%DHAWAN%'  OR UPPER(NEWS_URL) LIKE '%SHIKHAR%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'dhawan'      WHERE  (UPPER(NEWS_URL) LIKE '%DHAWAN%'  OR UPPER(NEWS_URL) LIKE '%SHIKHAR%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'ishant'      WHERE  (UPPER(NEWS_URL) LIKE '%ISHANT%'  OR UPPER(NEWS_URL) LIKE '%ISHANT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'ishant'      WHERE  (UPPER(NEWS_URL) LIKE '%ISHANT%'  OR UPPER(NEWS_URL) LIKE '%ISHANT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'rohit'      WHERE  (UPPER(NEWS_URL) LIKE '%ROHIT%'  OR UPPER(NEWS_URL) LIKE '%ROHIT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'rohit'      WHERE  (UPPER(NEWS_URL) LIKE '%ROHIT%'  OR UPPER(NEWS_URL) LIKE '%ROHIT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'hardik'      WHERE  (UPPER(NEWS_URL) LIKE '%HARDIK%'  OR UPPER(NEWS_URL) LIKE '%PANDYA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'hardik'      WHERE  (UPPER(NEWS_URL) LIKE '%HARDIK%'  OR UPPER(NEWS_URL) LIKE '%PANDYA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'bumrah'      WHERE  (UPPER(NEWS_URL) LIKE '%BUMRAH%'  OR UPPER(NEWS_URL) LIKE '%BUMRAH%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'bumrah'      WHERE  (UPPER(NEWS_URL) LIKE '%BUMRAH%'  OR UPPER(NEWS_URL) LIKE '%BUMRAH%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'ashwin'      WHERE  (UPPER(NEWS_URL) LIKE '%ASHWIN%'  OR UPPER(NEWS_URL) LIKE '%ASHWIN%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'ashwin'      WHERE  (UPPER(NEWS_URL) LIKE '%ASHWIN%'  OR UPPER(NEWS_URL) LIKE '%ASHWIN%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'yuvraj'      WHERE  (UPPER(NEWS_URL) LIKE '%YUVRAJ%'  OR UPPER(NEWS_URL) LIKE '%YUVI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'yuvraj'      WHERE  (UPPER(NEWS_URL) LIKE '%YUVRAJ%'  OR UPPER(NEWS_URL) LIKE '%YUVI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'bhuv'      WHERE  (UPPER(NEWS_URL) LIKE '%BHUVNESH%'  OR UPPER(NEWS_URL) LIKE '%BHUVI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'bhuv'      WHERE  (UPPER(NEWS_URL) LIKE '%BHUVNESH%'  OR UPPER(NEWS_URL) LIKE '%BHUVI%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'chahal'      WHERE  (UPPER(NEWS_URL) LIKE '%CHAHAL%'  OR UPPER(NEWS_URL) LIKE '%YUZ%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'chahal'      WHERE  (UPPER(NEWS_URL) LIKE '%CHAHAL%'  OR UPPER(NEWS_URL) LIKE '%YUZ%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'gavaskar'      WHERE  (UPPER(NEWS_URL) LIKE '%GAVASK%'  OR UPPER(NEWS_URL) LIKE '%GAVASK%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'gavaskar'      WHERE  (UPPER(NEWS_URL) LIKE '%GAVASK%'  OR UPPER(NEWS_URL) LIKE '%GAVASK%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'saurav'      WHERE  (UPPER(NEWS_URL) LIKE '%SAURAV%'  OR UPPER(NEWS_URL) LIKE '%GANGUL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'saurav'      WHERE  (UPPER(NEWS_URL) LIKE '%SAURAV%'  OR UPPER(NEWS_URL) LIKE '%GANGUL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'laxman'      WHERE  (UPPER(NEWS_URL) LIKE '%LAXMAN%'  OR UPPER(NEWS_URL) LIKE '%VVS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'laxman'      WHERE  (UPPER(NEWS_URL) LIKE '%LAXMAN%'  OR UPPER(NEWS_URL) LIKE '%VVS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'dravid'      WHERE  (UPPER(NEWS_URL) LIKE '%DRAVID%'  OR UPPER(NEWS_URL) LIKE '%DRAVID%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'dravid'      WHERE  (UPPER(NEWS_URL) LIKE '%DRAVID%'  OR UPPER(NEWS_URL) LIKE '%DRAVID%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'kapil'      WHERE  (UPPER(NEWS_URL) LIKE '%KAPIL%'  OR UPPER(NEWS_URL) LIKE '%KAPIL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'kapil'      WHERE  (UPPER(NEWS_URL) LIKE '%KAPIL%'  OR UPPER(NEWS_URL) LIKE '%KAPIL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'cricket'      WHERE  (UPPER(NEWS_URL) LIKE '%CRICKET%'  OR UPPER(NEWS_URL) LIKE '%BATTING%' OR UPPER(NEWS_URL) LIKE '%BOWL%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'cricket'      WHERE  (UPPER(NEWS_URL) LIKE '%CRICKET%'  OR UPPER(NEWS_URL) LIKE '%BATTING%' OR UPPER(NEWS_URL) LIKE '%BOWL%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'ipl'      WHERE  (UPPER(NEWS_URL) LIKE '%IPL%'  ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 5 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'ipl', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'ipl'      WHERE  (UPPER(NEWS_URL) LIKE '%IPL%'  ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'sindhu'      WHERE  (UPPER(NEWS_URL) LIKE '%SINDHU%'  ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'sindhu'      WHERE  (UPPER(NEWS_URL) LIKE '%SINDHU%'  )  
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'saina'      WHERE  (UPPER(NEWS_URL) LIKE '%SAINA%' OR UPPER(NEWS_URL) LIKE '%NEHWAL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'saina'      WHERE  (UPPER(NEWS_URL) LIKE '%SAINA%' OR UPPER(NEWS_URL) LIKE '%NEHWAL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'badminton'      WHERE  (UPPER(NEWS_URL) LIKE '%BADMONTON%' OR UPPER(NEWS_URL) LIKE '%SHUTTL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'badminton', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'badminton'      WHERE  (UPPER(NEWS_URL) LIKE '%BADMONTON%' OR UPPER(NEWS_URL) LIKE '%SHUTTL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'kabaddi', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'kabaddi'      WHERE  (UPPER(NEWS_URL) LIKE '%KABADDI%'  ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'kabaddi', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'kabaddi'      WHERE  (UPPER(NEWS_URL) LIKE '%KABADDI%'  ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'indianteam'      WHERE  (UPPER(NEWS_URL) LIKE '%CRICKET%INDIA%' OR UPPER(NEWS_URL) LIKE '%INDIA%CRICKET%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'cricket', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'indianteam'      WHERE  (UPPER(NEWS_URL) LIKE '%CRICKET%INDIA%' OR UPPER(NEWS_URL) LIKE '%INDIA%CRICKET%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'      
;



UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'hockey', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'hockey'      WHERE  (UPPER(NEWS_URL) LIKE '%HOCKEY%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'hockey', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'hockey'      WHERE  (UPPER(NEWS_URL) LIKE '%HOCKEY%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'athletics', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'athletics'      WHERE  (UPPER(NEWS_URL) LIKE '%ATHLET%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'athletics', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'athletics'      WHERE  (UPPER(NEWS_URL) LIKE '%ATHLET%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'tennis', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'tennis'      WHERE  (UPPER(NEWS_URL) LIKE '%TENNIS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'tennis', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'tennis'      WHERE  (UPPER(NEWS_URL) LIKE '%TENNIS%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'soccer', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'soccer'      WHERE  (UPPER(NEWS_URL) LIKE '%FOOTBALL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'soccer', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'soccer'      WHERE  (UPPER(NEWS_URL) LIKE '%FOOTBALL%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'golf', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'golf'      WHERE  (UPPER(NEWS_URL) LIKE '%GOLF%' OR UPPER(NEWS_URL) LIKE '%PGA%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'golf', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'golf'      WHERE  (UPPER(NEWS_URL) LIKE '%GOLF%' OR UPPER(NEWS_URL) LIKE '%PGA%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'motor-sport', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'motor-sport'      WHERE  (UPPER(NEWS_URL) LIKE '%MOTOR%' OR UPPER(NEWS_URL) LIKE '%PRIX%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'motor-sport', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'motor-sport'      WHERE  (UPPER(NEWS_URL) LIKE '%MOTOR%' OR UPPER(NEWS_URL) LIKE '%PRIX%') 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'    
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'GSPORT', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'federer'      WHERE  (UPPER(NEWS_URL) LIKE '%FEDERER%' ) 
AND COUNTRY_CODE IN ('IND', 'GGG') AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'GSPORT', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'federer'      WHERE  (UPPER(NEWS_URL) LIKE '%FEDERER%' ) 
AND COUNTRY_CODE IN ('IND', 'GGG') AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'  
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'GSPORT', SCRAPE_TAG3 = 'H'   
, SCRAPE_TAG2 =     'nadal'      WHERE  (UPPER(NEWS_URL) LIKE '%NADAL%' ) 
AND COUNTRY_CODE IN ('IND', 'GGG') AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N' 
ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 =     'GSPORT', SCRAPE_TAG3 = 'L'   
, SCRAPE_TAG2 =     'nadal'      WHERE  (UPPER(NEWS_URL) LIKE '%NADAL%' ) 
AND COUNTRY_CODE IN ('IND', 'GGG') AND SCRAPE_TAG1 = 'INDSPORTS'  AND   MOVED_TO_POST_FLAG = 'N'  
;

-- 
/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */


-- CALL STP_STAG23_1KWINSERT('cricket','L',1) ;
CALL STP_STAG23_MICRO('cricket','L') ;
-- CALL STP_STAG23_1KWINSERT('cricket','H',1) ;
CALL STP_STAG23_MICRO('cricket','H') ;
-- CALL STP_STAG23_1KWINSERT('ipl','L',1) ;
CALL STP_STAG23_MICRO('ipl','L') ;
-- CALL STP_STAG23_1KWINSERT('ipl','H',1) ;
CALL STP_STAG23_MICRO('ipl','H') ;
-- CALL STP_STAG23_1KWINSERT('iplmumbai','L',1) ;
CALL STP_STAG23_MICRO('iplmumbai','L') ;
-- CALL STP_STAG23_1KWINSERT('iplmumbai','H',1) ;
CALL STP_STAG23_MICRO('iplmumbai','H') ;
-- CALL STP_STAG23_1KWINSERT('ipldelhi','L',1) ;
CALL STP_STAG23_MICRO('ipldelhi','L') ;
-- CALL STP_STAG23_1KWINSERT('ipldelhi','H',1) ;
CALL STP_STAG23_MICRO('ipldelhi','H') ;
-- CALL STP_STAG23_1KWINSERT('iplchen','L',1) ;
CALL STP_STAG23_MICRO('iplchen','L') ;
-- CALL STP_STAG23_1KWINSERT('iplchen','H',1) ;
CALL STP_STAG23_MICRO('iplchen','H') ;
-- CALL STP_STAG23_1KWINSERT('iplkings','L',1) ;
CALL STP_STAG23_MICRO('iplkings','L') ;
-- CALL STP_STAG23_1KWINSERT('iplkings','H',1) ;
CALL STP_STAG23_MICRO('iplkings','H') ;
-- CALL STP_STAG23_1KWINSERT('iplkolk','L',1) ;
CALL STP_STAG23_MICRO('iplkolk','L') ;
-- CALL STP_STAG23_1KWINSERT('iplkolk','H',1) ;
CALL STP_STAG23_MICRO('iplkolk','H') ;
-- CALL STP_STAG23_1KWINSERT('iplroyals','L',1) ;
CALL STP_STAG23_MICRO('iplroyals','L') ;
-- CALL STP_STAG23_1KWINSERT('iplroyals','H',1) ;
CALL STP_STAG23_MICRO('iplroyals','H') ;
-- CALL STP_STAG23_1KWINSERT('iplbang','L',1) ;
CALL STP_STAG23_MICRO('iplbang','L') ;
-- CALL STP_STAG23_1KWINSERT('iplbang','H',1) ;
CALL STP_STAG23_MICRO('iplbang','H') ;
-- CALL STP_STAG23_1KWINSERT('iplhyd','L',1) ;
CALL STP_STAG23_MICRO('iplhyd','L') ;
-- CALL STP_STAG23_1KWINSERT('iplhyd','H',1) ;
CALL STP_STAG23_MICRO('iplhyd','H') ;
-- CALL STP_STAG23_1KWINSERT('sachin','L',1) ;
CALL STP_STAG23_MICRO('sachin','L') ;
-- CALL STP_STAG23_1KWINSERT('sachin','H',1) ;
CALL STP_STAG23_MICRO('sachin','H') ;
-- CALL STP_STAG23_1KWINSERT('kohli','L',1) ;
CALL STP_STAG23_MICRO('kohli','L') ;
-- CALL STP_STAG23_1KWINSERT('kohli','H',1) ;
CALL STP_STAG23_MICRO('kohli','H') ;
-- CALL STP_STAG23_1KWINSERT('gavaskar','L',1) ;
CALL STP_STAG23_MICRO('gavaskar','L') ;
-- CALL STP_STAG23_1KWINSERT('gavaskar','H',1) ;
CALL STP_STAG23_MICRO('gavaskar','H') ;
-- CALL STP_STAG23_1KWINSERT('dhoni','L',1) ;
CALL STP_STAG23_MICRO('dhoni','L') ;
-- CALL STP_STAG23_1KWINSERT('dhoni','H',1) ;
CALL STP_STAG23_MICRO('dhoni','H') ;
-- CALL STP_STAG23_1KWINSERT('saurav','L',1) ;
CALL STP_STAG23_MICRO('saurav','L') ;
-- CALL STP_STAG23_1KWINSERT('saurav','H',1) ;
CALL STP_STAG23_MICRO('saurav','H') ;
-- CALL STP_STAG23_1KWINSERT('laxman','L',1) ;
CALL STP_STAG23_MICRO('laxman','L') ;
-- CALL STP_STAG23_1KWINSERT('laxman','H',1) ;
CALL STP_STAG23_MICRO('laxman','H') ;
-- CALL STP_STAG23_1KWINSERT('dravid','L',1) ;
CALL STP_STAG23_MICRO('dravid','L') ;
-- CALL STP_STAG23_1KWINSERT('dravid','H',1) ;
CALL STP_STAG23_MICRO('dravid','H') ;
-- CALL STP_STAG23_1KWINSERT('kapil','L',1) ;
CALL STP_STAG23_MICRO('kapil','L') ;
-- CALL STP_STAG23_1KWINSERT('kapil','H',1) ;
CALL STP_STAG23_MICRO('kapil','H') ;
-- CALL STP_STAG23_1KWINSERT('shami','L',1) ;
CALL STP_STAG23_MICRO('shami','L') ;
-- CALL STP_STAG23_1KWINSERT('shami','H',1) ;
CALL STP_STAG23_MICRO('shami','H') ;
-- CALL STP_STAG23_1KWINSERT('jadeja','L',1) ;
CALL STP_STAG23_MICRO('jadeja','L') ;
-- CALL STP_STAG23_1KWINSERT('jadeja','H',1) ;
CALL STP_STAG23_MICRO('jadeja','H') ;
-- CALL STP_STAG23_1KWINSERT('rahane','L',1) ;
CALL STP_STAG23_MICRO('rahane','L') ;
-- CALL STP_STAG23_1KWINSERT('rahane','H',1) ;
CALL STP_STAG23_MICRO('rahane','H') ;
-- CALL STP_STAG23_1KWINSERT('dhawan','L',1) ;
CALL STP_STAG23_MICRO('dhawan','L') ;
-- CALL STP_STAG23_1KWINSERT('dhawan','H',1) ;
CALL STP_STAG23_MICRO('dhawan','H') ;
-- CALL STP_STAG23_1KWINSERT('badminton','L',1) ;
CALL STP_STAG23_MICRO('badminton','L') ;
-- CALL STP_STAG23_1KWINSERT('badminton','H',1) ;
CALL STP_STAG23_MICRO('badminton','H') ;
-- CALL STP_STAG23_1KWINSERT('sindhu','L',1) ;
CALL STP_STAG23_MICRO('sindhu','L') ;
-- CALL STP_STAG23_1KWINSERT('sindhu','H',1) ;
CALL STP_STAG23_MICRO('sindhu','H') ;
-- CALL STP_STAG23_1KWINSERT('saina','L',1) ;
CALL STP_STAG23_MICRO('saina','L') ;
-- CALL STP_STAG23_1KWINSERT('saina','H',1) ;
CALL STP_STAG23_MICRO('saina','H') ;


-- CALL STP_STAG23_1KWINSERT('indianteam','L',1) ;
CALL STP_STAG23_MICRO('indianteam','L') ;
-- CALL STP_STAG23_1KWINSERT('indianteam','H',1) ;
CALL STP_STAG23_MICRO('indianteam','H') ;
-- CALL STP_STAG23_1KWINSERT('kabaddi','L',1) ;
CALL STP_STAG23_MICRO('kabaddi','L') ;
-- CALL STP_STAG23_1KWINSERT('kabaddi','H',1) ;
CALL STP_STAG23_MICRO('kabaddi','H') ;
-- CALL STP_STAG23_1KWINSERT('ishant','L',1) ;
CALL STP_STAG23_MICRO('ishant','L') ;
-- CALL STP_STAG23_1KWINSERT('ishant','H',1) ;
CALL STP_STAG23_MICRO('ishant','H') ;
-- CALL STP_STAG23_1KWINSERT('rohit','L',1) ;
CALL STP_STAG23_MICRO('rohit','L') ;
-- CALL STP_STAG23_1KWINSERT('rohit','H',1) ;
CALL STP_STAG23_MICRO('rohit','H') ;
-- CALL STP_STAG23_1KWINSERT('hardik','L',1) ;
CALL STP_STAG23_MICRO('hardik','L') ;
-- CALL STP_STAG23_1KWINSERT('hardik','H',1) ;
CALL STP_STAG23_MICRO('hardik','H') ;
-- CALL STP_STAG23_1KWINSERT('bumrah','L',1) ;
CALL STP_STAG23_MICRO('bumrah','L') ;
-- CALL STP_STAG23_1KWINSERT('bumrah','H',1) ;
CALL STP_STAG23_MICRO('bumrah','H') ;
-- CALL STP_STAG23_1KWINSERT('ashwin','L',1) ;
CALL STP_STAG23_MICRO('ashwin','L') ;
-- CALL STP_STAG23_1KWINSERT('ashwin','H',1) ;
CALL STP_STAG23_MICRO('ashwin','H') ;
-- CALL STP_STAG23_1KWINSERT('yuvraj','L',1) ;
CALL STP_STAG23_MICRO('yuvraj','L') ;
-- CALL STP_STAG23_1KWINSERT('yuvraj','H',1) ;
CALL STP_STAG23_MICRO('yuvraj','H') ;
-- CALL STP_STAG23_1KWINSERT('bhuv','L',1) ;
CALL STP_STAG23_MICRO('bhuv','L') ;
-- CALL STP_STAG23_1KWINSERT('bhuv','H',1) ;
CALL STP_STAG23_MICRO('bhuv','H') ;
-- CALL STP_STAG23_1KWINSERT('chahal','L',1) ;
CALL STP_STAG23_MICRO('chahal','L') ;
-- CALL STP_STAG23_1KWINSERT('chahal','H',1) ;
CALL STP_STAG23_MICRO('chahal','H') ;  

-- CALL STP_STAG23_1KWINSERT('hockey','L',1) ;
CALL STP_STAG23_MICRO('hockey','L') ;
-- CALL STP_STAG23_1KWINSERT('hockey','H',1) ;
CALL STP_STAG23_MICRO('hockey','H') ;
-- CALL STP_STAG23_1KWINSERT('athletics','L',1) ;
CALL STP_STAG23_MICRO('athletics','L') ;
-- CALL STP_STAG23_1KWINSERT('athletics','H',1) ;
CALL STP_STAG23_MICRO('athletics','H') ;
-- CALL STP_STAG23_1KWINSERT('tennis','L',1) ;
CALL STP_STAG23_MICRO('tennis','L') ;
-- CALL STP_STAG23_1KWINSERT('tennis','H',1) ;
CALL STP_STAG23_MICRO('tennis','H') ;
-- CALL STP_STAG23_1KWINSERT('soccer','L',1) ;
CALL STP_STAG23_MICRO('soccer','L') ;
-- CALL STP_STAG23_1KWINSERT('soccer','H',1) ;
CALL STP_STAG23_MICRO('soccer','H') ;
-- CALL STP_STAG23_1KWINSERT('golf','L',1) ;
CALL STP_STAG23_MICRO('golf','L') ;
-- CALL STP_STAG23_1KWINSERT('golf','H',1) ;
CALL STP_STAG23_MICRO('golf','H') ;
-- CALL STP_STAG23_1KWINSERT('motor-sport','L',1) ;
CALL STP_STAG23_MICRO('motor-sport','L') ;
-- CALL STP_STAG23_1KWINSERT('motor-sport','H',1) ;
CALL STP_STAG23_MICRO('motor-sport','H') ;
  
-- CALL STP_STAG23_1KWINSERT('federer','L',1) ;
CALL STP_STAG23_MICRO('federer','L') ;
-- CALL STP_STAG23_1KWINSERT('federer','H',1) ;
CALL STP_STAG23_MICRO('federer','H') ;
-- CALL STP_STAG23_1KWINSERT('nadal','L',1) ;
CALL STP_STAG23_MICRO('nadal','L') ;
-- CALL STP_STAG23_1KWINSERT('nadal','H',1) ;
CALL STP_STAG23_MICRO('nadal','H') ;  


/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2IND', 'SPORT', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2MLBUSA //
CREATE PROCEDURE STP_GRAND_T2MLBUSA()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%orioles-%' OR NEWS_URL LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%orioles-%' OR NEWS_URL LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%red-sox-%' OR NEWS_URL LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%red-sox-%' OR NEWS_URL LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%yankees-%' OR NEWS_URL LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%yankees-%' OR NEWS_URL LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rays-%' OR NEWS_URL LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rays-%' OR NEWS_URL LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jays-%' OR NEWS_URL LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jays-%' OR NEWS_URL LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%white-sox-%' OR NEWS_URL LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%white-sox-%' OR NEWS_URL LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%indians-%' OR NEWS_URL LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%indians-%' OR NEWS_URL LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%tigers-%' OR NEWS_URL LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%tigers-%' OR NEWS_URL LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%royals-%' OR NEWS_URL LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%royals-%' OR NEWS_URL LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%twins-%' OR NEWS_URL LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%twins-%' OR NEWS_URL LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%astros-%' OR NEWS_URL LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%astros-%' OR NEWS_URL LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%angels-%' OR NEWS_URL LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%angels-%' OR NEWS_URL LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%athletics-%' OR NEWS_URL LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%athletics-%' OR NEWS_URL LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mariners-%' OR NEWS_URL LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mariners-%' OR NEWS_URL LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rangers-%' OR NEWS_URL LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rangers-%' OR NEWS_URL LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%braves-%' OR NEWS_URL LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%braves-%' OR NEWS_URL LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%marlins-%' OR NEWS_URL LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%marlins-%' OR NEWS_URL LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mets-%' OR NEWS_URL LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mets-%' OR NEWS_URL LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%phillies-%' OR NEWS_URL LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%phillies-%' OR NEWS_URL LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nationals-%' OR NEWS_URL LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nationals-%' OR NEWS_URL LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cubs-%' OR NEWS_URL LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cubs-%' OR NEWS_URL LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%reds-%' OR NEWS_URL LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%reds-%' OR NEWS_URL LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%brewers-%' OR NEWS_URL LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%brewers-%' OR NEWS_URL LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pirates-%' OR NEWS_URL LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pirates-%' OR NEWS_URL LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cardinals-%' OR NEWS_URL LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cardinals-%' OR NEWS_URL LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%diamondbacks-%' OR NEWS_URL LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%diamondbacks-%' OR NEWS_URL LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockies-%' OR NEWS_URL LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockies-%' OR NEWS_URL LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%dodgers-%' OR NEWS_URL LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%dodgers-%' OR NEWS_URL LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%padres-%' OR NEWS_URL LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%padres-%' OR NEWS_URL LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%sfgiants-%' OR NEWS_URL LIKE  '-sfgiants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%sfgiants-%' OR NEWS_URL LIKE  '-sfgiants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%MLB-%' OR NEWS_URL LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%MLB-%' OR NEWS_URL LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'L') ;


-- CALL STP_STAG23_1KWINSERT('MLB', 'H', 5) ;
CALL STP_STAG23_MICRO('MLB', 'H') ;

-- CALL STP_STAG23_1KWINSERT('MLB', 'L', 5) ;
CALL STP_STAG23_MICRO('MLB', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'H', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'L', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'H', 3) ;
CALL STP_STAG23_MICRO('orioles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'L', 3) ;
CALL STP_STAG23_MICRO('orioles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'H', 3) ;
CALL STP_STAG23_MICRO('jays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'L', 3) ;
CALL STP_STAG23_MICRO('jays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'H', 3) ;
CALL STP_STAG23_MICRO('braves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'L', 3) ;
CALL STP_STAG23_MICRO('braves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'H', 3) ;
CALL STP_STAG23_MICRO('pirates', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'L', 3) ;
CALL STP_STAG23_MICRO('pirates', 'L') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'H', 3) ;
CALL STP_STAG23_MICRO('yankees', 'H') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'L', 3) ;
CALL STP_STAG23_MICRO('yankees', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'H', 3) ;
CALL STP_STAG23_MICRO('rangers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'L', 3) ;
CALL STP_STAG23_MICRO('rangers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'H', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'L', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockies', 'H', 3) ;
CALL STP_STAG23_MICRO('rockies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockies', 'L', 3) ;
CALL STP_STAG23_MICRO('rockies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'H', 3) ;
CALL STP_STAG23_MICRO('royals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'L', 3) ;
CALL STP_STAG23_MICRO('royals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'H', 3) ;
CALL STP_STAG23_MICRO('nationals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'L', 3) ;
CALL STP_STAG23_MICRO('nationals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'H', 3) ;
CALL STP_STAG23_MICRO('marlins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'L', 3) ;
CALL STP_STAG23_MICRO('marlins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'H', 3) ;
CALL STP_STAG23_MICRO('reds', 'H') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'L', 3) ;
CALL STP_STAG23_MICRO('reds', 'L') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'H', 3) ;
CALL STP_STAG23_MICRO('angels', 'H') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'L', 3) ;
CALL STP_STAG23_MICRO('angels', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'H', 3) ;
CALL STP_STAG23_MICRO('cubs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'L', 3) ;
CALL STP_STAG23_MICRO('cubs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'H', 3) ;
CALL STP_STAG23_MICRO('twins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'L', 3) ;
CALL STP_STAG23_MICRO('twins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'H', 3) ;
CALL STP_STAG23_MICRO('phillies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'L', 3) ;
CALL STP_STAG23_MICRO('phillies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'H', 3) ;
CALL STP_STAG23_MICRO('indians', 'H') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'L', 3) ;
CALL STP_STAG23_MICRO('indians', 'L') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'H', 3) ;
CALL STP_STAG23_MICRO('athletics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'L', 3) ;
CALL STP_STAG23_MICRO('athletics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'H', 3) ;
CALL STP_STAG23_MICRO('mets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'L', 3) ;
CALL STP_STAG23_MICRO('mets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'H', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'L', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'H', 3) ;
CALL STP_STAG23_MICRO('padres', 'H') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'L', 3) ;
CALL STP_STAG23_MICRO('padres', 'L') ;


-- CALL STP_STAG23_1KWINSERT('brewers', 'H', 3) ;
CALL STP_STAG23_MICRO('brewers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('brewers', 'L', 3) ;
CALL STP_STAG23_MICRO('brewers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'H', 3) ;
CALL STP_STAG23_MICRO('mariners', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'L', 3) ;
CALL STP_STAG23_MICRO('mariners', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rays', 'H', 3) ;
CALL STP_STAG23_MICRO('rays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rays', 'L', 3) ;
CALL STP_STAG23_MICRO('rays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'H', 3) ;
CALL STP_STAG23_MICRO('tigers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'L', 3) ;
CALL STP_STAG23_MICRO('tigers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'H', 3) ;
CALL STP_STAG23_MICRO('astros', 'H') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'L', 3) ;
CALL STP_STAG23_MICRO('astros', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2MLBUSA', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2MLBUSA_EX //
CREATE PROCEDURE STP_GRAND_T2MLBUSA_EX()
THISPROC: BEGIN

/*
    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%orioles%' OR NEWS_EXCERPT LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%orioles%' OR NEWS_EXCERPT LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%red sox%' OR NEWS_EXCERPT LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%red sox%' OR NEWS_EXCERPT LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%yankees%' OR NEWS_EXCERPT LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%yankees%' OR NEWS_EXCERPT LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rays%' OR NEWS_EXCERPT LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rays%' OR NEWS_EXCERPT LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jays%' OR NEWS_EXCERPT LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jays%' OR NEWS_EXCERPT LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%white sox%' OR NEWS_EXCERPT LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%white sox%' OR NEWS_EXCERPT LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%indians%' OR NEWS_EXCERPT LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%indians%' OR NEWS_EXCERPT LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%tigers%' OR NEWS_EXCERPT LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%tigers%' OR NEWS_EXCERPT LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%royals%' OR NEWS_EXCERPT LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%royals%' OR NEWS_EXCERPT LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%twins%' OR NEWS_EXCERPT LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%twins%' OR NEWS_EXCERPT LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%astros%' OR NEWS_EXCERPT LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%astros%' OR NEWS_EXCERPT LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%angels%' OR NEWS_EXCERPT LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%angels%' OR NEWS_EXCERPT LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%athletics%' OR NEWS_EXCERPT LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%athletics%' OR NEWS_EXCERPT LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mariners%' OR NEWS_EXCERPT LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mariners%' OR NEWS_EXCERPT LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rangers%' OR NEWS_EXCERPT LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rangers%' OR NEWS_EXCERPT LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%braves%' OR NEWS_EXCERPT LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%braves%' OR NEWS_EXCERPT LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%marlins%' OR NEWS_EXCERPT LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%marlins%' OR NEWS_EXCERPT LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mets%' OR NEWS_EXCERPT LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mets%' OR NEWS_EXCERPT LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%phillies%' OR NEWS_EXCERPT LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%phillies%' OR NEWS_EXCERPT LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nationals%' OR NEWS_EXCERPT LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nationals%' OR NEWS_EXCERPT LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     
AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cubs%' OR NEWS_EXCERPT LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cubs%' OR NEWS_EXCERPT LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'    
 AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%reds%' OR NEWS_EXCERPT LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%reds%' OR NEWS_EXCERPT LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%brewers%' OR NEWS_EXCERPT LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%brewers%' OR NEWS_EXCERPT LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pirates%' OR NEWS_EXCERPT LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pirates%' OR NEWS_EXCERPT LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cardinals%' OR NEWS_EXCERPT LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cardinals%' OR NEWS_EXCERPT LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%diamondbacks%' OR NEWS_EXCERPT LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%diamondbacks%' OR NEWS_EXCERPT LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rockies%' OR NEWS_EXCERPT LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rockies%' OR NEWS_EXCERPT LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%dodgers%' OR NEWS_EXCERPT LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%dodgers%' OR NEWS_EXCERPT LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%padres%' OR NEWS_EXCERPT LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%padres%' OR NEWS_EXCERPT LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%sfgiants%' OR NEWS_EXCERPT LIKE  '-sfgiants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%sfgiants%' OR NEWS_EXCERPT LIKE  '-sfgiants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%MLB%' OR NEWS_EXCERPT LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%MLB%' OR NEWS_EXCERPT LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'L') ;


-- CALL STP_STAG23_1KWINSERT('MLB', 'H', 5) ;
CALL STP_STAG23_MICRO('MLB', 'H') ;

-- CALL STP_STAG23_1KWINSERT('MLB', 'L', 5) ;
CALL STP_STAG23_MICRO('MLB', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'H', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'L', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'H', 3) ;
CALL STP_STAG23_MICRO('orioles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'L', 3) ;
CALL STP_STAG23_MICRO('orioles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'H', 3) ;
CALL STP_STAG23_MICRO('jays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'L', 3) ;
CALL STP_STAG23_MICRO('jays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'H', 3) ;
CALL STP_STAG23_MICRO('braves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'L', 3) ;
CALL STP_STAG23_MICRO('braves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'H', 3) ;
CALL STP_STAG23_MICRO('pirates', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'L', 3) ;
CALL STP_STAG23_MICRO('pirates', 'L') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'H', 3) ;
CALL STP_STAG23_MICRO('yankees', 'H') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'L', 3) ;
CALL STP_STAG23_MICRO('yankees', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'H', 3) ;
CALL STP_STAG23_MICRO('rangers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'L', 3) ;
CALL STP_STAG23_MICRO('rangers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'H', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'L', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockies', 'H', 3) ;
CALL STP_STAG23_MICRO('rockies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockies', 'L', 3) ;
CALL STP_STAG23_MICRO('rockies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'H', 3) ;
CALL STP_STAG23_MICRO('royals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'L', 3) ;
CALL STP_STAG23_MICRO('royals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'H', 3) ;
CALL STP_STAG23_MICRO('nationals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'L', 3) ;
CALL STP_STAG23_MICRO('nationals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'H', 3) ;
CALL STP_STAG23_MICRO('marlins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'L', 3) ;
CALL STP_STAG23_MICRO('marlins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'H', 3) ;
CALL STP_STAG23_MICRO('reds', 'H') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'L', 3) ;
CALL STP_STAG23_MICRO('reds', 'L') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'H', 3) ;
CALL STP_STAG23_MICRO('angels', 'H') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'L', 3) ;
CALL STP_STAG23_MICRO('angels', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'H', 3) ;
CALL STP_STAG23_MICRO('cubs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'L', 3) ;
CALL STP_STAG23_MICRO('cubs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'H', 3) ;
CALL STP_STAG23_MICRO('twins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'L', 3) ;
CALL STP_STAG23_MICRO('twins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'H', 3) ;
CALL STP_STAG23_MICRO('phillies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'L', 3) ;
CALL STP_STAG23_MICRO('phillies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'H', 3) ;
CALL STP_STAG23_MICRO('indians', 'H') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'L', 3) ;
CALL STP_STAG23_MICRO('indians', 'L') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'H', 3) ;
CALL STP_STAG23_MICRO('athletics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'L', 3) ;
CALL STP_STAG23_MICRO('athletics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'H', 3) ;
CALL STP_STAG23_MICRO('mets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'L', 3) ;
CALL STP_STAG23_MICRO('mets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'H', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'L', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'H', 3) ;
CALL STP_STAG23_MICRO('padres', 'H') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'L', 3) ;
CALL STP_STAG23_MICRO('padres', 'L') ;


-- CALL STP_STAG23_1KWINSERT('brewers', 'H', 3) ;
CALL STP_STAG23_MICRO('brewers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('brewers', 'L', 3) ;
CALL STP_STAG23_MICRO('brewers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'H', 3) ;
CALL STP_STAG23_MICRO('mariners', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'L', 3) ;
CALL STP_STAG23_MICRO('mariners', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rays', 'H', 3) ;
CALL STP_STAG23_MICRO('rays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rays', 'L', 3) ;
CALL STP_STAG23_MICRO('rays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'H', 3) ;
CALL STP_STAG23_MICRO('tigers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'L', 3) ;
CALL STP_STAG23_MICRO('tigers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'H', 3) ;
CALL STP_STAG23_MICRO('astros', 'H') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'L', 3) ;
CALL STP_STAG23_MICRO('astros', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2MLBUSA_EX', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2MLBUSA_HL //
CREATE PROCEDURE STP_GRAND_T2MLBUSA_HL()
THISPROC: BEGIN

/*

    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%orioles%' OR NEWS_HEADLINE LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orioles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%orioles%' OR NEWS_HEADLINE LIKE  '-orioles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%red%sox%' OR NEWS_HEADLINE LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'red-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%red%sox%' OR NEWS_HEADLINE LIKE  '-red-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%yankees%' OR NEWS_HEADLINE LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yankees'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%yankees%' OR NEWS_HEADLINE LIKE  '-yankees%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rays%' OR NEWS_HEADLINE LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rays%' OR NEWS_HEADLINE LIKE  '-rays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jays%' OR NEWS_HEADLINE LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jays'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jays%' OR NEWS_HEADLINE LIKE  '-jays%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%white%sox%' OR NEWS_HEADLINE LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'white-sox'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%white%sox%' OR NEWS_HEADLINE LIKE  '-white-sox%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%indians%' OR NEWS_HEADLINE LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indians'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%indians%' OR NEWS_HEADLINE LIKE  '-indians%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%tigers%' OR NEWS_HEADLINE LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tigers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%tigers%' OR NEWS_HEADLINE LIKE  '-tigers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%royals%' OR NEWS_HEADLINE LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'royals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%royals%' OR NEWS_HEADLINE LIKE  '-royals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%twins%' OR NEWS_HEADLINE LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%twins%' OR NEWS_HEADLINE LIKE  '-twins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%astros%' OR NEWS_HEADLINE LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'astros'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%astros%' OR NEWS_HEADLINE LIKE  '-astros%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%angels%' OR NEWS_HEADLINE LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'angels'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%angels%' OR NEWS_HEADLINE LIKE  '-angels%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%athletics%' OR NEWS_HEADLINE LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'athletics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%athletics%' OR NEWS_HEADLINE LIKE  '-athletics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mariners%' OR NEWS_HEADLINE LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mariners'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mariners%' OR NEWS_HEADLINE LIKE  '-mariners%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rangers%' OR NEWS_HEADLINE LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rangers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rangers%' OR NEWS_HEADLINE LIKE  '-rangers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%braves%' OR NEWS_HEADLINE LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'braves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%braves%' OR NEWS_HEADLINE LIKE  '-braves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%marlins%' OR NEWS_HEADLINE LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'marlins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%marlins%' OR NEWS_HEADLINE LIKE  '-marlins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mets%' OR NEWS_HEADLINE LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mets%' OR NEWS_HEADLINE LIKE  '-mets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%phillies%' OR NEWS_HEADLINE LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'phillies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%phillies%' OR NEWS_HEADLINE LIKE  '-phillies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nationals%' OR NEWS_HEADLINE LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nationals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nationals%' OR NEWS_HEADLINE LIKE  '-nationals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cubs%' OR NEWS_HEADLINE LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cubs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cubs%' OR NEWS_HEADLINE LIKE  '-cubs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%reds%' OR NEWS_HEADLINE LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'reds'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%reds%' OR NEWS_HEADLINE LIKE  '-reds%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%brewers%' OR NEWS_HEADLINE LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'brewers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%brewers%' OR NEWS_HEADLINE LIKE  '-brewers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pirates%' OR NEWS_HEADLINE LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pirates'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pirates%' OR NEWS_HEADLINE LIKE  '-pirates%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mlbcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%diamondbacks%' OR NEWS_HEADLINE LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'diamondbacks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%diamondbacks%' OR NEWS_HEADLINE LIKE  '-diamondbacks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rockies%' OR NEWS_HEADLINE LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rockies%' OR NEWS_HEADLINE LIKE  '-rockies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dodgers%' OR NEWS_HEADLINE LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dodgers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dodgers%' OR NEWS_HEADLINE LIKE  '-dodgers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%padres%' OR NEWS_HEADLINE LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padres'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%padres%' OR NEWS_HEADLINE LIKE  '-padres%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' ) AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfgiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' ) AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasymlb'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%MLB%' OR NEWS_HEADLINE LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'MLB'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%MLB%' OR NEWS_HEADLINE LIKE  '-MLB%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB'     AND MOD(ROW_ID, 2) = 0 ;

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 sportsnews2 SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('SPORTS') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND DATE(NEWS_DTM_RAW) >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 50   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('SPORTS') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND DATE(NEWS_DTM_RAW) >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

/*  END OF adding 15 sportsnews2 SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasymlb', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasymlb', 'L') ;


-- CALL STP_STAG23_1KWINSERT('MLB', 'H', 5) ;
CALL STP_STAG23_MICRO('MLB', 'H') ;

-- CALL STP_STAG23_1KWINSERT('MLB', 'L', 5) ;
CALL STP_STAG23_MICRO('MLB', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'H', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sfgiants', 'L', 3) ;
CALL STP_STAG23_MICRO('sfgiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'H', 3) ;
CALL STP_STAG23_MICRO('orioles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('orioles', 'L', 3) ;
CALL STP_STAG23_MICRO('orioles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'H', 3) ;
CALL STP_STAG23_MICRO('jays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jays', 'L', 3) ;
CALL STP_STAG23_MICRO('jays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('red-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('red-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'H', 3) ;
CALL STP_STAG23_MICRO('braves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('braves', 'L', 3) ;
CALL STP_STAG23_MICRO('braves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'H', 3) ;
CALL STP_STAG23_MICRO('pirates', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pirates', 'L', 3) ;
CALL STP_STAG23_MICRO('pirates', 'L') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'H', 3) ;
CALL STP_STAG23_MICRO('yankees', 'H') ;

-- CALL STP_STAG23_1KWINSERT('yankees', 'L', 3) ;
CALL STP_STAG23_MICRO('yankees', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'H', 3) ;
CALL STP_STAG23_MICRO('rangers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rangers', 'L', 3) ;
CALL STP_STAG23_MICRO('rangers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'H', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dodgers', 'L', 3) ;
CALL STP_STAG23_MICRO('dodgers', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockies', 'H', 3) ;
CALL STP_STAG23_MICRO('rockies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockies', 'L', 3) ;
CALL STP_STAG23_MICRO('rockies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mlbcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('mlbcardinals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'H', 3) ;
CALL STP_STAG23_MICRO('royals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('royals', 'L', 3) ;
CALL STP_STAG23_MICRO('royals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'H', 3) ;
CALL STP_STAG23_MICRO('nationals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nationals', 'L', 3) ;
CALL STP_STAG23_MICRO('nationals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'H', 3) ;
CALL STP_STAG23_MICRO('marlins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('marlins', 'L', 3) ;
CALL STP_STAG23_MICRO('marlins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'H', 3) ;
CALL STP_STAG23_MICRO('reds', 'H') ;

-- CALL STP_STAG23_1KWINSERT('reds', 'L', 3) ;
CALL STP_STAG23_MICRO('reds', 'L') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'H', 3) ;
CALL STP_STAG23_MICRO('angels', 'H') ;

-- CALL STP_STAG23_1KWINSERT('angels', 'L', 3) ;
CALL STP_STAG23_MICRO('angels', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'H', 3) ;
CALL STP_STAG23_MICRO('cubs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cubs', 'L', 3) ;
CALL STP_STAG23_MICRO('cubs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'H', 3) ;
CALL STP_STAG23_MICRO('twins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('twins', 'L', 3) ;
CALL STP_STAG23_MICRO('twins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'H', 3) ;
CALL STP_STAG23_MICRO('phillies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('phillies', 'L', 3) ;
CALL STP_STAG23_MICRO('phillies', 'L') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'H', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'H') ;

-- CALL STP_STAG23_1KWINSERT('white-sox', 'L', 3) ;
CALL STP_STAG23_MICRO('white-sox', 'L') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'H', 3) ;
CALL STP_STAG23_MICRO('indians', 'H') ;

-- CALL STP_STAG23_1KWINSERT('indians', 'L', 3) ;
CALL STP_STAG23_MICRO('indians', 'L') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'H', 3) ;
CALL STP_STAG23_MICRO('athletics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('athletics', 'L', 3) ;
CALL STP_STAG23_MICRO('athletics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'H', 3) ;
CALL STP_STAG23_MICRO('mets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mets', 'L', 3) ;
CALL STP_STAG23_MICRO('mets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'H', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('diamondbacks', 'L', 3) ;
CALL STP_STAG23_MICRO('diamondbacks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'H', 3) ;
CALL STP_STAG23_MICRO('padres', 'H') ;

-- CALL STP_STAG23_1KWINSERT('padres', 'L', 3) ;
CALL STP_STAG23_MICRO('padres', 'L') ;


-- CALL STP_STAG23_1KWINSERT('brewers', 'H', 3) ;
CALL STP_STAG23_MICRO('brewers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('brewers', 'L', 3) ;
CALL STP_STAG23_MICRO('brewers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'H', 3) ;
CALL STP_STAG23_MICRO('mariners', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mariners', 'L', 3) ;
CALL STP_STAG23_MICRO('mariners', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rays', 'H', 3) ;
CALL STP_STAG23_MICRO('rays', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rays', 'L', 3) ;
CALL STP_STAG23_MICRO('rays', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'H', 3) ;
CALL STP_STAG23_MICRO('tigers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tigers', 'L', 3) ;
CALL STP_STAG23_MICRO('tigers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'H', 3) ;
CALL STP_STAG23_MICRO('astros', 'H') ;

-- CALL STP_STAG23_1KWINSERT('astros', 'L', 3) ;
CALL STP_STAG23_MICRO('astros', 'L') ;

/*  Completing the sportsnews2 addition with STp MICRo call  */

CALL STP_STAG23_MICRO('sportsnews2', 'H') ;

CALL STP_STAG23_MICRO('sportsnews2', 'L') ;

/*  END OF Completing the sportsnews2 addition with STp MICRo call  */

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'MLB' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2MLBUSA_HL', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NBAUSA //
CREATE PROCEDURE STP_GRAND_T2NBAUSA()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%celtics-%' OR NEWS_URL LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%celtics-%' OR NEWS_URL LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nets-%' OR NEWS_URL LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nets-%' OR NEWS_URL LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%knicks-%' OR NEWS_URL LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%knicks-%' OR NEWS_URL LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%76ers-%' OR NEWS_URL LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%76ers-%' OR NEWS_URL LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raptors-%' OR NEWS_URL LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raptors-%' OR NEWS_URL LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bulls-%' OR NEWS_URL LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bulls-%' OR NEWS_URL LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cavaliers-%' OR NEWS_URL LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cavaliers-%' OR NEWS_URL LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pistons-%' OR NEWS_URL LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pistons-%' OR NEWS_URL LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pacers-%' OR NEWS_URL LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pacers-%' OR NEWS_URL LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bucks-%' OR NEWS_URL LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bucks-%' OR NEWS_URL LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hawks-%' OR NEWS_URL LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hawks-%' OR NEWS_URL LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hornets-%' OR NEWS_URL LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%hornets-%' OR NEWS_URL LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%heat-%' OR NEWS_URL LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%heat-%' OR NEWS_URL LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%magic-%' OR NEWS_URL LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%magic-%' OR NEWS_URL LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%wizards-%' OR NEWS_URL LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%wizards-%' OR NEWS_URL LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nuggets-%' OR NEWS_URL LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%nuggets-%' OR NEWS_URL LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%timberwolves-%' OR NEWS_URL LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%timberwolves-%' OR NEWS_URL LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%thunder-%' OR NEWS_URL LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%thunder-%' OR NEWS_URL LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%blazers-%' OR NEWS_URL LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%blazers-%' OR NEWS_URL LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jazz-%' OR NEWS_URL LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jazz-%' OR NEWS_URL LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%clippers-%' OR NEWS_URL LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%clippers-%' OR NEWS_URL LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lakers-%' OR NEWS_URL LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lakers-%' OR NEWS_URL LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%suns-%' OR NEWS_URL LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%suns-%' OR NEWS_URL LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%kings-%' OR NEWS_URL LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%kings-%' OR NEWS_URL LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mavericks-%' OR NEWS_URL LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%mavericks-%' OR NEWS_URL LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockets-%' OR NEWS_URL LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rockets-%' OR NEWS_URL LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%grizzlies-%' OR NEWS_URL LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%grizzlies-%' OR NEWS_URL LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pelicans-%' OR NEWS_URL LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%pelicans-%' OR NEWS_URL LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%NBA-%' OR NEWS_URL LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%NBA-%' OR NEWS_URL LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'L') ;


-- CALL STP_STAG23_1KWINSERT('NBA', 'H', 5) ;
CALL STP_STAG23_MICRO('NBA', 'H') ;

-- CALL STP_STAG23_1KWINSERT('NBA', 'L', 5) ;
CALL STP_STAG23_MICRO('NBA', 'L') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'H', 3) ;
CALL STP_STAG23_MICRO('celtics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'L', 3) ;
CALL STP_STAG23_MICRO('celtics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'H', 3) ;
CALL STP_STAG23_MICRO('raptors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'L', 3) ;
CALL STP_STAG23_MICRO('raptors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'H', 3) ;
CALL STP_STAG23_MICRO('nets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'L', 3) ;
CALL STP_STAG23_MICRO('nets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'H', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'L', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'H', 3) ;
CALL STP_STAG23_MICRO('suns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'L', 3) ;
CALL STP_STAG23_MICRO('suns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'H', 3) ;
CALL STP_STAG23_MICRO('knicks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'L', 3) ;
CALL STP_STAG23_MICRO('knicks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'H', 3) ;
CALL STP_STAG23_MICRO('wizards', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'L', 3) ;
CALL STP_STAG23_MICRO('wizards', 'L') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'H', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'L', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockets', 'H', 3) ;
CALL STP_STAG23_MICRO('rockets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockets', 'L', 3) ;
CALL STP_STAG23_MICRO('rockets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'H', 3) ;
CALL STP_STAG23_MICRO('kings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'L', 3) ;
CALL STP_STAG23_MICRO('kings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'H', 3) ;
CALL STP_STAG23_MICRO('pacers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'L', 3) ;
CALL STP_STAG23_MICRO('pacers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'H', 3) ;
CALL STP_STAG23_MICRO('jazz', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'L', 3) ;
CALL STP_STAG23_MICRO('jazz', 'L') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'H', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'L', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'H', 3) ;
CALL STP_STAG23_MICRO('clippers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'L', 3) ;
CALL STP_STAG23_MICRO('clippers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'H', 3) ;
CALL STP_STAG23_MICRO('hornets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'L', 3) ;
CALL STP_STAG23_MICRO('hornets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'H', 3) ;
CALL STP_STAG23_MICRO('warriors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'L', 3) ;
CALL STP_STAG23_MICRO('warriors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'H', 3) ;
CALL STP_STAG23_MICRO('bucks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'L', 3) ;
CALL STP_STAG23_MICRO('bucks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'H', 3) ;
CALL STP_STAG23_MICRO('blazers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'L', 3) ;
CALL STP_STAG23_MICRO('blazers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'H', 3) ;
CALL STP_STAG23_MICRO('bulls', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'L', 3) ;
CALL STP_STAG23_MICRO('bulls', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'H', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'L', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'H', 3) ;
CALL STP_STAG23_MICRO('heat', 'H') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'L', 3) ;
CALL STP_STAG23_MICRO('heat', 'L') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'H', 3) ;
CALL STP_STAG23_MICRO('thunder', 'H') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'L', 3) ;
CALL STP_STAG23_MICRO('thunder', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'H', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'L', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'H', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'L', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('lakers', 'H', 3) ;
CALL STP_STAG23_MICRO('lakers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lakers', 'L', 3) ;
CALL STP_STAG23_MICRO('lakers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'H', 3) ;
CALL STP_STAG23_MICRO('magic', 'H') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'L', 3) ;
CALL STP_STAG23_MICRO('magic', 'L') ;


-- CALL STP_STAG23_1KWINSERT('76ers', 'H', 3) ;
CALL STP_STAG23_MICRO('76ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('76ers', 'L', 3) ;
CALL STP_STAG23_MICRO('76ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'H', 3) ;
CALL STP_STAG23_MICRO('pistons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'L', 3) ;
CALL STP_STAG23_MICRO('pistons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'H', 3) ;
CALL STP_STAG23_MICRO('hawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'L', 3) ;
CALL STP_STAG23_MICRO('hawks', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NBAUSA', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NBAUSA_EX //
CREATE PROCEDURE STP_GRAND_T2NBAUSA_EX()
THISPROC: BEGIN

/*
    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%celtics%' OR NEWS_EXCERPT LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%celtics%' OR NEWS_EXCERPT LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nets%' OR NEWS_EXCERPT LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nets%' OR NEWS_EXCERPT LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%knicks%' OR NEWS_EXCERPT LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%knicks%' OR NEWS_EXCERPT LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%76ers%' OR NEWS_EXCERPT LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%76ers%' OR NEWS_EXCERPT LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%raptors%' OR NEWS_EXCERPT LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%raptors%' OR NEWS_EXCERPT LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bulls%' OR NEWS_EXCERPT LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bulls%' OR NEWS_EXCERPT LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cavaliers%' OR NEWS_EXCERPT LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cavaliers%' OR NEWS_EXCERPT LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pistons%' OR NEWS_EXCERPT LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pistons%' OR NEWS_EXCERPT LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pacers%' OR NEWS_EXCERPT LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pacers%' OR NEWS_EXCERPT LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bucks%' OR NEWS_EXCERPT LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bucks%' OR NEWS_EXCERPT LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%hawks%' OR NEWS_EXCERPT LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%hawks%' OR NEWS_EXCERPT LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%hornets%' OR NEWS_EXCERPT LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%hornets%' OR NEWS_EXCERPT LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%heat%' OR NEWS_EXCERPT LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%heat%' OR NEWS_EXCERPT LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%magic%' OR NEWS_EXCERPT LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%magic%' OR NEWS_EXCERPT LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%wizards%' OR NEWS_EXCERPT LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%wizards%' OR NEWS_EXCERPT LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nuggets%' OR NEWS_EXCERPT LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%nuggets%' OR NEWS_EXCERPT LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%timberwolves%' OR NEWS_EXCERPT LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%timberwolves%' OR NEWS_EXCERPT LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%thunder%' OR NEWS_EXCERPT LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%thunder%' OR NEWS_EXCERPT LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%blazers%' OR NEWS_EXCERPT LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%blazers%' OR NEWS_EXCERPT LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jazz%' OR NEWS_EXCERPT LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jazz%' OR NEWS_EXCERPT LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%giants%' OR NEWS_EXCERPT LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%giants%' OR NEWS_EXCERPT LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%clippers%' OR NEWS_EXCERPT LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%clippers%' OR NEWS_EXCERPT LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%lakers%' OR NEWS_EXCERPT LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%lakers%' OR NEWS_EXCERPT LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%suns%' OR NEWS_EXCERPT LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%suns%' OR NEWS_EXCERPT LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%kings%' OR NEWS_EXCERPT LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%kings%' OR NEWS_EXCERPT LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mavericks%' OR NEWS_EXCERPT LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%mavericks%' OR NEWS_EXCERPT LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rockets%' OR NEWS_EXCERPT LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rockets%' OR NEWS_EXCERPT LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%grizzlies%' OR NEWS_EXCERPT LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%grizzlies%' OR NEWS_EXCERPT LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pelicans%' OR NEWS_EXCERPT LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%pelicans%' OR NEWS_EXCERPT LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%NBA%' OR NEWS_EXCERPT LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%NBA%' OR NEWS_EXCERPT LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */


-- CALL STP_STAG23_1KWINSERT('fantasynba', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'L') ;


-- CALL STP_STAG23_1KWINSERT('NBA', 'H', 5) ;
CALL STP_STAG23_MICRO('NBA', 'H') ;

-- CALL STP_STAG23_1KWINSERT('NBA', 'L', 5) ;
CALL STP_STAG23_MICRO('NBA', 'L') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'H', 3) ;
CALL STP_STAG23_MICRO('celtics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'L', 3) ;
CALL STP_STAG23_MICRO('celtics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'H', 3) ;
CALL STP_STAG23_MICRO('raptors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'L', 3) ;
CALL STP_STAG23_MICRO('raptors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'H', 3) ;
CALL STP_STAG23_MICRO('nets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'L', 3) ;
CALL STP_STAG23_MICRO('nets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'H', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'L', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'H', 3) ;
CALL STP_STAG23_MICRO('suns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'L', 3) ;
CALL STP_STAG23_MICRO('suns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'H', 3) ;
CALL STP_STAG23_MICRO('knicks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'L', 3) ;
CALL STP_STAG23_MICRO('knicks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'H', 3) ;
CALL STP_STAG23_MICRO('wizards', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'L', 3) ;
CALL STP_STAG23_MICRO('wizards', 'L') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'H', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'L', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockets', 'H', 3) ;
CALL STP_STAG23_MICRO('rockets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockets', 'L', 3) ;
CALL STP_STAG23_MICRO('rockets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'H', 3) ;
CALL STP_STAG23_MICRO('kings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'L', 3) ;
CALL STP_STAG23_MICRO('kings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'H', 3) ;
CALL STP_STAG23_MICRO('pacers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'L', 3) ;
CALL STP_STAG23_MICRO('pacers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'H', 3) ;
CALL STP_STAG23_MICRO('jazz', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'L', 3) ;
CALL STP_STAG23_MICRO('jazz', 'L') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'H', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'L', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'H', 3) ;
CALL STP_STAG23_MICRO('clippers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'L', 3) ;
CALL STP_STAG23_MICRO('clippers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'H', 3) ;
CALL STP_STAG23_MICRO('hornets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'L', 3) ;
CALL STP_STAG23_MICRO('hornets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'H', 3) ;
CALL STP_STAG23_MICRO('warriors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'L', 3) ;
CALL STP_STAG23_MICRO('warriors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'H', 3) ;
CALL STP_STAG23_MICRO('bucks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'L', 3) ;
CALL STP_STAG23_MICRO('bucks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'H', 3) ;
CALL STP_STAG23_MICRO('blazers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'L', 3) ;
CALL STP_STAG23_MICRO('blazers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'H', 3) ;
CALL STP_STAG23_MICRO('bulls', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'L', 3) ;
CALL STP_STAG23_MICRO('bulls', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'H', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'L', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'H', 3) ;
CALL STP_STAG23_MICRO('heat', 'H') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'L', 3) ;
CALL STP_STAG23_MICRO('heat', 'L') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'H', 3) ;
CALL STP_STAG23_MICRO('thunder', 'H') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'L', 3) ;
CALL STP_STAG23_MICRO('thunder', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'H', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'L', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'H', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'L', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('lakers', 'H', 3) ;
CALL STP_STAG23_MICRO('lakers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lakers', 'L', 3) ;
CALL STP_STAG23_MICRO('lakers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'H', 3) ;
CALL STP_STAG23_MICRO('magic', 'H') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'L', 3) ;
CALL STP_STAG23_MICRO('magic', 'L') ;


-- CALL STP_STAG23_1KWINSERT('76ers', 'H', 3) ;
CALL STP_STAG23_MICRO('76ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('76ers', 'L', 3) ;
CALL STP_STAG23_MICRO('76ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'H', 3) ;
CALL STP_STAG23_MICRO('pistons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'L', 3) ;
CALL STP_STAG23_MICRO('pistons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'H', 3) ;
CALL STP_STAG23_MICRO('hawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'L', 3) ;
CALL STP_STAG23_MICRO('hawks', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NBAUSA_EX', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NBAUSA_HL //
CREATE PROCEDURE STP_GRAND_T2NBAUSA_HL()
THISPROC: BEGIN

/*

    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
            10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%celtics%' OR NEWS_HEADLINE LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'celtics'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%celtics%' OR NEWS_HEADLINE LIKE  '-celtics%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nets%' OR NEWS_HEADLINE LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nets%' OR NEWS_HEADLINE LIKE  '-nets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%knicks%' OR NEWS_HEADLINE LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'knicks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%knicks%' OR NEWS_HEADLINE LIKE  '-knicks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%76ers%' OR NEWS_HEADLINE LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '76ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%76ers%' OR NEWS_HEADLINE LIKE  '-76ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raptors%' OR NEWS_HEADLINE LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raptors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raptors%' OR NEWS_HEADLINE LIKE  '-raptors%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bulls%' OR NEWS_HEADLINE LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bulls'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bulls%' OR NEWS_HEADLINE LIKE  '-bulls%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cavaliers%' OR NEWS_HEADLINE LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cavaliers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cavaliers%' OR NEWS_HEADLINE LIKE  '-cavaliers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pistons%' OR NEWS_HEADLINE LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pistons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pistons%' OR NEWS_HEADLINE LIKE  '-pistons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pacers%' OR NEWS_HEADLINE LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pacers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pacers%' OR NEWS_HEADLINE LIKE  '-pacers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bucks%' OR NEWS_HEADLINE LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bucks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bucks%' OR NEWS_HEADLINE LIKE  '-bucks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%hawks%' OR NEWS_HEADLINE LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%hawks%' OR NEWS_HEADLINE LIKE  '-hawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%hornets%' OR NEWS_HEADLINE LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hornets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%hornets%' OR NEWS_HEADLINE LIKE  '-hornets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%heat%' OR NEWS_HEADLINE LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'heat'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%heat%' OR NEWS_HEADLINE LIKE  '-heat%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%magic%' OR NEWS_HEADLINE LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'magic'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%magic%' OR NEWS_HEADLINE LIKE  '-magic%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%wizards%' OR NEWS_HEADLINE LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wizards'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%wizards%' OR NEWS_HEADLINE LIKE  '-wizards%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nuggets%' OR NEWS_HEADLINE LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nuggets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%nuggets%' OR NEWS_HEADLINE LIKE  '-nuggets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%timberwolves%' OR NEWS_HEADLINE LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'timberwolves'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%timberwolves%' OR NEWS_HEADLINE LIKE  '-timberwolves%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%thunder%' OR NEWS_HEADLINE LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'thunder'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%thunder%' OR NEWS_HEADLINE LIKE  '-thunder%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%blazers%' OR NEWS_HEADLINE LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'blazers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%blazers%' OR NEWS_HEADLINE LIKE  '-blazers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jazz%' OR NEWS_HEADLINE LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jazz'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jazz%' OR NEWS_HEADLINE LIKE  '-jazz%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'warriors'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%clippers%' OR NEWS_HEADLINE LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'clippers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%clippers%' OR NEWS_HEADLINE LIKE  '-clippers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lakers%' OR NEWS_HEADLINE LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lakers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lakers%' OR NEWS_HEADLINE LIKE  '-lakers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%suns%' OR NEWS_HEADLINE LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'suns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%suns%' OR NEWS_HEADLINE LIKE  '-suns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%kings%' OR NEWS_HEADLINE LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%kings%' OR NEWS_HEADLINE LIKE  '-kings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mavericks%' OR NEWS_HEADLINE LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mavericks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%mavericks%' OR NEWS_HEADLINE LIKE  '-mavericks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rockets%' OR NEWS_HEADLINE LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rockets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rockets%' OR NEWS_HEADLINE LIKE  '-rockets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%grizzlies%' OR NEWS_HEADLINE LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'grizzlies'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%grizzlies%' OR NEWS_HEADLINE LIKE  '-grizzlies%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pelicans%' OR NEWS_HEADLINE LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pelicans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%pelicans%' OR NEWS_HEADLINE LIKE  '-pelicans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%NBA%' OR NEWS_HEADLINE LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'NBA'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%NBA%' OR NEWS_HEADLINE LIKE  '-NBA%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasynba'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'H', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasynba', 'L', 5) ;
CALL STP_STAG23_MICRO('fantasynba', 'L') ;


-- CALL STP_STAG23_1KWINSERT('NBA', 'H', 5) ;
CALL STP_STAG23_MICRO('NBA', 'H') ;

-- CALL STP_STAG23_1KWINSERT('NBA', 'L', 5) ;
CALL STP_STAG23_MICRO('NBA', 'L') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'H', 3) ;
CALL STP_STAG23_MICRO('celtics', 'H') ;

-- CALL STP_STAG23_1KWINSERT('celtics', 'L', 3) ;
CALL STP_STAG23_MICRO('celtics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'H', 3) ;
CALL STP_STAG23_MICRO('raptors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raptors', 'L', 3) ;
CALL STP_STAG23_MICRO('raptors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'H', 3) ;
CALL STP_STAG23_MICRO('nets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nets', 'L', 3) ;
CALL STP_STAG23_MICRO('nets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'H', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nuggets', 'L', 3) ;
CALL STP_STAG23_MICRO('nuggets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'H', 3) ;
CALL STP_STAG23_MICRO('suns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('suns', 'L', 3) ;
CALL STP_STAG23_MICRO('suns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'H', 3) ;
CALL STP_STAG23_MICRO('knicks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('knicks', 'L', 3) ;
CALL STP_STAG23_MICRO('knicks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'H', 3) ;
CALL STP_STAG23_MICRO('wizards', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wizards', 'L', 3) ;
CALL STP_STAG23_MICRO('wizards', 'L') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'H', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'H') ;

-- CALL STP_STAG23_1KWINSERT('grizzlies', 'L', 3) ;
CALL STP_STAG23_MICRO('grizzlies', 'L') ;


-- CALL STP_STAG23_1KWINSERT('rockets', 'H', 3) ;
CALL STP_STAG23_MICRO('rockets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rockets', 'L', 3) ;
CALL STP_STAG23_MICRO('rockets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'H', 3) ;
CALL STP_STAG23_MICRO('kings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kings', 'L', 3) ;
CALL STP_STAG23_MICRO('kings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'H', 3) ;
CALL STP_STAG23_MICRO('pacers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pacers', 'L', 3) ;
CALL STP_STAG23_MICRO('pacers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'H', 3) ;
CALL STP_STAG23_MICRO('jazz', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jazz', 'L', 3) ;
CALL STP_STAG23_MICRO('jazz', 'L') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'H', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'H') ;

-- CALL STP_STAG23_1KWINSERT('timberwolves', 'L', 3) ;
CALL STP_STAG23_MICRO('timberwolves', 'L') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'H', 3) ;
CALL STP_STAG23_MICRO('clippers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('clippers', 'L', 3) ;
CALL STP_STAG23_MICRO('clippers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'H', 3) ;
CALL STP_STAG23_MICRO('hornets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hornets', 'L', 3) ;
CALL STP_STAG23_MICRO('hornets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'H', 3) ;
CALL STP_STAG23_MICRO('warriors', 'H') ;

-- CALL STP_STAG23_1KWINSERT('warriors', 'L', 3) ;
CALL STP_STAG23_MICRO('warriors', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'H', 3) ;
CALL STP_STAG23_MICRO('bucks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bucks', 'L', 3) ;
CALL STP_STAG23_MICRO('bucks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'H', 3) ;
CALL STP_STAG23_MICRO('blazers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('blazers', 'L', 3) ;
CALL STP_STAG23_MICRO('blazers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'H', 3) ;
CALL STP_STAG23_MICRO('bulls', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bulls', 'L', 3) ;
CALL STP_STAG23_MICRO('bulls', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'H', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cavaliers', 'L', 3) ;
CALL STP_STAG23_MICRO('cavaliers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'H', 3) ;
CALL STP_STAG23_MICRO('heat', 'H') ;

-- CALL STP_STAG23_1KWINSERT('heat', 'L', 3) ;
CALL STP_STAG23_MICRO('heat', 'L') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'H', 3) ;
CALL STP_STAG23_MICRO('thunder', 'H') ;

-- CALL STP_STAG23_1KWINSERT('thunder', 'L', 3) ;
CALL STP_STAG23_MICRO('thunder', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'H', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mavericks', 'L', 3) ;
CALL STP_STAG23_MICRO('mavericks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'H', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pelicans', 'L', 3) ;
CALL STP_STAG23_MICRO('pelicans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('lakers', 'H', 3) ;
CALL STP_STAG23_MICRO('lakers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lakers', 'L', 3) ;
CALL STP_STAG23_MICRO('lakers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'H', 3) ;
CALL STP_STAG23_MICRO('magic', 'H') ;

-- CALL STP_STAG23_1KWINSERT('magic', 'L', 3) ;
CALL STP_STAG23_MICRO('magic', 'L') ;


-- CALL STP_STAG23_1KWINSERT('76ers', 'H', 3) ;
CALL STP_STAG23_MICRO('76ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('76ers', 'L', 3) ;
CALL STP_STAG23_MICRO('76ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'H', 3) ;
CALL STP_STAG23_MICRO('pistons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pistons', 'L', 3) ;
CALL STP_STAG23_MICRO('pistons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'H', 3) ;
CALL STP_STAG23_MICRO('hawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hawks', 'L', 3) ;
CALL STP_STAG23_MICRO('hawks', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NBA' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NBAUSA_HL', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NFLUSA //
CREATE PROCEDURE STP_GRAND_T2NFLUSA()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
    */

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%ravens-%' OR NEWS_URL LIKE  '-ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%ravens-%' OR NEWS_URL LIKE  '-ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bengals-%' OR NEWS_URL LIKE  '-bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bengals-%' OR NEWS_URL LIKE  '-bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%browns-%' OR NEWS_URL LIKE  '-browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%browns-%' OR NEWS_URL LIKE  '-browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%steelers-%' OR NEWS_URL LIKE  '-steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%steelers-%' OR NEWS_URL LIKE  '-steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bears-%' OR NEWS_URL LIKE  '-bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bears-%' OR NEWS_URL LIKE  '-bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lions-%' OR NEWS_URL LIKE  '-lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%lions-%' OR NEWS_URL LIKE  '-lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%packers-%' OR NEWS_URL LIKE  '-packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%packers-%' OR NEWS_URL LIKE  '-packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%texans-%' OR NEWS_URL LIKE  '-texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%texans-%' OR NEWS_URL LIKE  '-texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%colts-%' OR NEWS_URL LIKE  '-colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%colts-%' OR NEWS_URL LIKE  '-colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jaguars-%' OR NEWS_URL LIKE  '-jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jaguars-%' OR NEWS_URL LIKE  '-jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%titans-%' OR NEWS_URL LIKE  '-titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%titans-%' OR NEWS_URL LIKE  '-titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%falcons-%' OR NEWS_URL LIKE  '-falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%falcons-%' OR NEWS_URL LIKE  '-falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%panthers-%' OR NEWS_URL LIKE  '-panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%panthers-%' OR NEWS_URL LIKE  '-panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%saints-%' OR NEWS_URL LIKE  '-saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%saints-%' OR NEWS_URL LIKE  '-saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%buccaneers-%' OR NEWS_URL LIKE  '-buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%buccaneers-%' OR NEWS_URL LIKE  '-buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bills-%' OR NEWS_URL LIKE  '-bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%bills-%' OR NEWS_URL LIKE  '-bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%dolphins-%' OR NEWS_URL LIKE  '-dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%dolphins-%' OR NEWS_URL LIKE  '-dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%patriots-%' OR NEWS_URL LIKE  '-patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%patriots-%' OR NEWS_URL LIKE  '-patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jets-%' OR NEWS_URL LIKE  '-jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%jets-%' OR NEWS_URL LIKE  '-jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cowboys-%' OR NEWS_URL LIKE  '-cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cowboys-%' OR NEWS_URL LIKE  '-cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%giants-%' OR NEWS_URL LIKE  '-giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%eagles-%' OR NEWS_URL LIKE  '-eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%eagles-%' OR NEWS_URL LIKE  '-eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%redskins-%' OR NEWS_URL LIKE  '-redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%redskins-%' OR NEWS_URL LIKE  '-redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%broncos-%' OR NEWS_URL LIKE  '-broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%broncos-%' OR NEWS_URL LIKE  '-broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%chiefs-%' OR NEWS_URL LIKE  '-chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%chiefs-%' OR NEWS_URL LIKE  '-chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raiders-%' OR NEWS_URL LIKE  '-raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%raiders-%' OR NEWS_URL LIKE  '-raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%chargers-%' OR NEWS_URL LIKE  '-chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%chargers-%' OR NEWS_URL LIKE  '-chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cardinals-%' OR NEWS_URL LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%cardinals-%' OR NEWS_URL LIKE  '-cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rams-%' OR NEWS_URL LIKE  '-rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%rams-%' OR NEWS_URL LIKE  '-rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%49ers-%' OR NEWS_URL LIKE  '-49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%49ers-%' OR NEWS_URL LIKE  '-49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%seahawks-%' OR NEWS_URL LIKE  '-seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%seahawks-%' OR NEWS_URL LIKE  '-seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%vikings-%' OR NEWS_URL LIKE  '-vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%vikings-%' OR NEWS_URL LIKE  '-vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_URL LIKE  '%fantasy-%' OR NEWS_URL LIKE  '-fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('ravens', 'H', 3) ;
CALL STP_STAG23_MICRO('ravens', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ravens', 'L', 3) ;
CALL STP_STAG23_MICRO('ravens', 'L') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'H', 3) ;
CALL STP_STAG23_MICRO('49ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'L', 3) ;
CALL STP_STAG23_MICRO('49ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'H', 3) ;
CALL STP_STAG23_MICRO('bears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'L', 3) ;
CALL STP_STAG23_MICRO('bears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'H', 3) ;
CALL STP_STAG23_MICRO('bengals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'L', 3) ;
CALL STP_STAG23_MICRO('bengals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'H', 3) ;
CALL STP_STAG23_MICRO('bills', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'L', 3) ;
CALL STP_STAG23_MICRO('bills', 'L') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'H', 3) ;
CALL STP_STAG23_MICRO('broncos', 'H') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'L', 3) ;
CALL STP_STAG23_MICRO('broncos', 'L') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'H', 3) ;
CALL STP_STAG23_MICRO('browns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'L', 3) ;
CALL STP_STAG23_MICRO('browns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'H', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'L', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'L') ;


-- CALL STP_STAG23_1KWINSERT('chargers', 'H', 3) ;
CALL STP_STAG23_MICRO('chargers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chargers', 'L', 3) ;
CALL STP_STAG23_MICRO('chargers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'H', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'L', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'H', 3) ;
CALL STP_STAG23_MICRO('colts', 'H') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'L', 3) ;
CALL STP_STAG23_MICRO('colts', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'H', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'L', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'H', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'L', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'H', 3) ;
CALL STP_STAG23_MICRO('eagles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'L', 3) ;
CALL STP_STAG23_MICRO('eagles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'H', 3) ;
CALL STP_STAG23_MICRO('falcons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'L', 3) ;
CALL STP_STAG23_MICRO('falcons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'H', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'L', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'H', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'L', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'H', 3) ;
CALL STP_STAG23_MICRO('jets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'L', 3) ;
CALL STP_STAG23_MICRO('jets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'H', 3) ;
CALL STP_STAG23_MICRO('lions', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'L', 3) ;
CALL STP_STAG23_MICRO('lions', 'L') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'H', 3) ;
CALL STP_STAG23_MICRO('packers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'L', 3) ;
CALL STP_STAG23_MICRO('packers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'H', 3) ;
CALL STP_STAG23_MICRO('panthers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'L', 3) ;
CALL STP_STAG23_MICRO('panthers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'H', 3) ;
CALL STP_STAG23_MICRO('patriots', 'H') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'L', 3) ;
CALL STP_STAG23_MICRO('patriots', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'H', 3) ;
CALL STP_STAG23_MICRO('raiders', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'L', 3) ;
CALL STP_STAG23_MICRO('raiders', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'H', 3) ;
CALL STP_STAG23_MICRO('rams', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'L', 3) ;
CALL STP_STAG23_MICRO('rams', 'L') ;


-- CALL STP_STAG23_1KWINSERT('redskins', 'H', 3) ;
CALL STP_STAG23_MICRO('redskins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('redskins', 'L', 3) ;
CALL STP_STAG23_MICRO('redskins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'H', 3) ;
CALL STP_STAG23_MICRO('saints', 'H') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'L', 3) ;
CALL STP_STAG23_MICRO('saints', 'L') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'H', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'L', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'H', 3) ;
CALL STP_STAG23_MICRO('steelers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'L', 3) ;
CALL STP_STAG23_MICRO('steelers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'H', 3) ;
CALL STP_STAG23_MICRO('texans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'L', 3) ;
CALL STP_STAG23_MICRO('texans', 'L') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'H', 3) ;
CALL STP_STAG23_MICRO('titans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'L', 3) ;
CALL STP_STAG23_MICRO('titans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('vikings', 'H', 3) ;
CALL STP_STAG23_MICRO('vikings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('vikings', 'L', 3) ;
CALL STP_STAG23_MICRO('vikings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'H', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'L', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NFLUSA', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NFLUSA_EX //
CREATE PROCEDURE STP_GRAND_T2NFLUSA_EX()
THISPROC: BEGIN

/*
    07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%ravens%' OR NEWS_EXCERPT LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%ravens%' OR NEWS_EXCERPT LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bengals%' OR NEWS_EXCERPT LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bengals%' OR NEWS_EXCERPT LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%browns%' OR NEWS_EXCERPT LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%browns%' OR NEWS_EXCERPT LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%steelers%' OR NEWS_EXCERPT LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%steelers%' OR NEWS_EXCERPT LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bears%' OR NEWS_EXCERPT LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bears%' OR NEWS_EXCERPT LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%lions%' OR NEWS_EXCERPT LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%lions%' OR NEWS_EXCERPT LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%packers%' OR NEWS_EXCERPT LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%packers%' OR NEWS_EXCERPT LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%texans%' OR NEWS_EXCERPT LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%texans%' OR NEWS_EXCERPT LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%colts%' OR NEWS_EXCERPT LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%colts%' OR NEWS_EXCERPT LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jaguars%' OR NEWS_EXCERPT LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jaguars%' OR NEWS_EXCERPT LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%titans%' OR NEWS_EXCERPT LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%titans%' OR NEWS_EXCERPT LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%falcons%' OR NEWS_EXCERPT LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%falcons%' OR NEWS_EXCERPT LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%panthers%' OR NEWS_EXCERPT LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%panthers%' OR NEWS_EXCERPT LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%saints%' OR NEWS_EXCERPT LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%saints%' OR NEWS_EXCERPT LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%buccaneers%' OR NEWS_EXCERPT LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%buccaneers%' OR NEWS_EXCERPT LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bills%' OR NEWS_EXCERPT LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%bills%' OR NEWS_EXCERPT LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%dolphins%' OR NEWS_EXCERPT LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%dolphins%' OR NEWS_EXCERPT LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%patriots%' OR NEWS_EXCERPT LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%patriots%' OR NEWS_EXCERPT LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jets%' OR NEWS_EXCERPT LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%jets%' OR NEWS_EXCERPT LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cowboys%' OR NEWS_EXCERPT LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cowboys%' OR NEWS_EXCERPT LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%giants%' OR NEWS_EXCERPT LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%giants%' OR NEWS_EXCERPT LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%eagles%' OR NEWS_EXCERPT LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%eagles%' OR NEWS_EXCERPT LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%redskins%' OR NEWS_EXCERPT LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%redskins%' OR NEWS_EXCERPT LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%broncos%' OR NEWS_EXCERPT LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%broncos%' OR NEWS_EXCERPT LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%chiefs%' OR NEWS_EXCERPT LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%chiefs%' OR NEWS_EXCERPT LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%raiders%' OR NEWS_EXCERPT LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%raiders%' OR NEWS_EXCERPT LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%chargers%' OR NEWS_EXCERPT LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%chargers%' OR NEWS_EXCERPT LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cardinals%' OR NEWS_EXCERPT LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%cardinals%' OR NEWS_EXCERPT LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rams%' OR NEWS_EXCERPT LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%rams%' OR NEWS_EXCERPT LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%49ers%' OR NEWS_EXCERPT LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%49ers%' OR NEWS_EXCERPT LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%seahawks%' OR NEWS_EXCERPT LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%seahawks%' OR NEWS_EXCERPT LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%vikings%' OR NEWS_EXCERPT LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%vikings%' OR NEWS_EXCERPT LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_EXCERPT LIKE  '%fantasy%' OR NEWS_EXCERPT LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('ravens', 'H', 3) ;
CALL STP_STAG23_MICRO('ravens', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ravens', 'L', 3) ;
CALL STP_STAG23_MICRO('ravens', 'L') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'H', 3) ;
CALL STP_STAG23_MICRO('49ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'L', 3) ;
CALL STP_STAG23_MICRO('49ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'H', 3) ;
CALL STP_STAG23_MICRO('bears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'L', 3) ;
CALL STP_STAG23_MICRO('bears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'H', 3) ;
CALL STP_STAG23_MICRO('bengals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'L', 3) ;
CALL STP_STAG23_MICRO('bengals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'H', 3) ;
CALL STP_STAG23_MICRO('bills', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'L', 3) ;
CALL STP_STAG23_MICRO('bills', 'L') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'H', 3) ;
CALL STP_STAG23_MICRO('broncos', 'H') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'L', 3) ;
CALL STP_STAG23_MICRO('broncos', 'L') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'H', 3) ;
CALL STP_STAG23_MICRO('browns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'L', 3) ;
CALL STP_STAG23_MICRO('browns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'H', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'L', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'L') ;


-- CALL STP_STAG23_1KWINSERT('chargers', 'H', 3) ;
CALL STP_STAG23_MICRO('chargers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chargers', 'L', 3) ;
CALL STP_STAG23_MICRO('chargers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'H', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'L', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'H', 3) ;
CALL STP_STAG23_MICRO('colts', 'H') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'L', 3) ;
CALL STP_STAG23_MICRO('colts', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'H', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'L', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'H', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'L', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'H', 3) ;
CALL STP_STAG23_MICRO('eagles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'L', 3) ;
CALL STP_STAG23_MICRO('eagles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'H', 3) ;
CALL STP_STAG23_MICRO('falcons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'L', 3) ;
CALL STP_STAG23_MICRO('falcons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'H', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'L', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'H', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'L', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'H', 3) ;
CALL STP_STAG23_MICRO('jets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'L', 3) ;
CALL STP_STAG23_MICRO('jets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'H', 3) ;
CALL STP_STAG23_MICRO('lions', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'L', 3) ;
CALL STP_STAG23_MICRO('lions', 'L') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'H', 3) ;
CALL STP_STAG23_MICRO('packers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'L', 3) ;
CALL STP_STAG23_MICRO('packers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'H', 3) ;
CALL STP_STAG23_MICRO('panthers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'L', 3) ;
CALL STP_STAG23_MICRO('panthers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'H', 3) ;
CALL STP_STAG23_MICRO('patriots', 'H') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'L', 3) ;
CALL STP_STAG23_MICRO('patriots', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'H', 3) ;
CALL STP_STAG23_MICRO('raiders', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'L', 3) ;
CALL STP_STAG23_MICRO('raiders', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'H', 3) ;
CALL STP_STAG23_MICRO('rams', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'L', 3) ;
CALL STP_STAG23_MICRO('rams', 'L') ;


-- CALL STP_STAG23_1KWINSERT('redskins', 'H', 3) ;
CALL STP_STAG23_MICRO('redskins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('redskins', 'L', 3) ;
CALL STP_STAG23_MICRO('redskins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'H', 3) ;
CALL STP_STAG23_MICRO('saints', 'H') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'L', 3) ;
CALL STP_STAG23_MICRO('saints', 'L') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'H', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'L', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'H', 3) ;
CALL STP_STAG23_MICRO('steelers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'L', 3) ;
CALL STP_STAG23_MICRO('steelers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'H', 3) ;
CALL STP_STAG23_MICRO('texans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'L', 3) ;
CALL STP_STAG23_MICRO('texans', 'L') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'H', 3) ;
CALL STP_STAG23_MICRO('titans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'L', 3) ;
CALL STP_STAG23_MICRO('titans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('vikings', 'H', 3) ;
CALL STP_STAG23_MICRO('vikings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('vikings', 'L', 3) ;
CALL STP_STAG23_MICRO('vikings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'H', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'L', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'L') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NFLUSA_EX', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T2NFLUSA_HL //
CREATE PROCEDURE STP_GRAND_T2NFLUSA_HL()
THISPROC: BEGIN

/*
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
        09/19/2020 AST: Adding the tagging of 25 untagged scrapes to sportsnews2 KW
        10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
            10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%ravens%' OR NEWS_HEADLINE LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ravens'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%ravens%' OR NEWS_HEADLINE LIKE  'ravens%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bengals%' OR NEWS_HEADLINE LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bengals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bengals%' OR NEWS_HEADLINE LIKE  'bengals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%browns%' OR NEWS_HEADLINE LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'browns'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%browns%' OR NEWS_HEADLINE LIKE  'browns%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%steelers%' OR NEWS_HEADLINE LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'steelers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%steelers%' OR NEWS_HEADLINE LIKE  'steelers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bears%' OR NEWS_HEADLINE LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bears%' OR NEWS_HEADLINE LIKE  'bears%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lions%' OR NEWS_HEADLINE LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'lions'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%lions%' OR NEWS_HEADLINE LIKE  'lions%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%packers%' OR NEWS_HEADLINE LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'packers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%packers%' OR NEWS_HEADLINE LIKE  'packers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%texans%' OR NEWS_HEADLINE LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'texans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%texans%' OR NEWS_HEADLINE LIKE  'texans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%colts%' OR NEWS_HEADLINE LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'colts'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%colts%' OR NEWS_HEADLINE LIKE  'colts%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jaguars%' OR NEWS_HEADLINE LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jaguars'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jaguars%' OR NEWS_HEADLINE LIKE  'jaguars%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%titans%' OR NEWS_HEADLINE LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'titans'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%titans%' OR NEWS_HEADLINE LIKE  'titans%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%falcons%' OR NEWS_HEADLINE LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'falcons'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%falcons%' OR NEWS_HEADLINE LIKE  'falcons%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%panthers%' OR NEWS_HEADLINE LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'panthers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%panthers%' OR NEWS_HEADLINE LIKE  'panthers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%saints%' OR NEWS_HEADLINE LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'saints'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%saints%' OR NEWS_HEADLINE LIKE  'saints%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%buccaneers%' OR NEWS_HEADLINE LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'buccaneers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%buccaneers%' OR NEWS_HEADLINE LIKE  'buccaneers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bills%' OR NEWS_HEADLINE LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bills'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%bills%' OR NEWS_HEADLINE LIKE  'bills%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dolphins%' OR NEWS_HEADLINE LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dolphins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%dolphins%' OR NEWS_HEADLINE LIKE  'dolphins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%patriots%' OR NEWS_HEADLINE LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'patriots'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%patriots%' OR NEWS_HEADLINE LIKE  'patriots%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jets%' OR NEWS_HEADLINE LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'jets'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%jets%' OR NEWS_HEADLINE LIKE  'jets%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cowboys%' OR NEWS_HEADLINE LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cowboys'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cowboys%' OR NEWS_HEADLINE LIKE  'cowboys%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nygiants'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%giants%' OR NEWS_HEADLINE LIKE  'giants%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%eagles%' OR NEWS_HEADLINE LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'eagles'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%eagles%' OR NEWS_HEADLINE LIKE  'eagles%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%redskins%' OR NEWS_HEADLINE LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'redskins'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%redskins%' OR NEWS_HEADLINE LIKE  'redskins%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%broncos%' OR NEWS_HEADLINE LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'broncos'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%broncos%' OR NEWS_HEADLINE LIKE  'broncos%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chiefs%' OR NEWS_HEADLINE LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chiefs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chiefs%' OR NEWS_HEADLINE LIKE  'chiefs%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raiders%' OR NEWS_HEADLINE LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raiders'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%raiders%' OR NEWS_HEADLINE LIKE  'raiders%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chargers%' OR NEWS_HEADLINE LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chargers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%chargers%' OR NEWS_HEADLINE LIKE  'chargers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nflcardinals'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%cardinals%' OR NEWS_HEADLINE LIKE  'cardinals%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rams%' OR NEWS_HEADLINE LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rams'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%rams%' OR NEWS_HEADLINE LIKE  'rams%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%49ers%' OR NEWS_HEADLINE LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '49ers'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%49ers%' OR NEWS_HEADLINE LIKE  '49ers%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%seahawks%' OR NEWS_HEADLINE LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'seahawks'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%seahawks%' OR NEWS_HEADLINE LIKE  'seahawks%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%vikings%' OR NEWS_HEADLINE LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'vikings'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%vikings%' OR NEWS_HEADLINE LIKE  'vikings%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fantasy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (NEWS_HEADLINE LIKE  '%fantasy%' OR NEWS_HEADLINE LIKE  'fantasy%') AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL'     AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('ravens', 'H', 3) ;
CALL STP_STAG23_MICRO('ravens', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ravens', 'L', 3) ;
CALL STP_STAG23_MICRO('ravens', 'L') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'H', 3) ;
CALL STP_STAG23_MICRO('49ers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('49ers', 'L', 3) ;
CALL STP_STAG23_MICRO('49ers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'H', 3) ;
CALL STP_STAG23_MICRO('bears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bears', 'L', 3) ;
CALL STP_STAG23_MICRO('bears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'H', 3) ;
CALL STP_STAG23_MICRO('bengals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bengals', 'L', 3) ;
CALL STP_STAG23_MICRO('bengals', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'H', 3) ;
CALL STP_STAG23_MICRO('bills', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bills', 'L', 3) ;
CALL STP_STAG23_MICRO('bills', 'L') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'H', 3) ;
CALL STP_STAG23_MICRO('broncos', 'H') ;

-- CALL STP_STAG23_1KWINSERT('broncos', 'L', 3) ;
CALL STP_STAG23_MICRO('broncos', 'L') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'H', 3) ;
CALL STP_STAG23_MICRO('browns', 'H') ;

-- CALL STP_STAG23_1KWINSERT('browns', 'L', 3) ;
CALL STP_STAG23_MICRO('browns', 'L') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'H', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('buccaneers', 'L', 3) ;
CALL STP_STAG23_MICRO('buccaneers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'H', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nflcardinals', 'L', 3) ;
CALL STP_STAG23_MICRO('nflcardinals', 'L') ;


-- CALL STP_STAG23_1KWINSERT('chargers', 'H', 3) ;
CALL STP_STAG23_MICRO('chargers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chargers', 'L', 3) ;
CALL STP_STAG23_MICRO('chargers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'H', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chiefs', 'L', 3) ;
CALL STP_STAG23_MICRO('chiefs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'H', 3) ;
CALL STP_STAG23_MICRO('colts', 'H') ;

-- CALL STP_STAG23_1KWINSERT('colts', 'L', 3) ;
CALL STP_STAG23_MICRO('colts', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'H', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cowboys', 'L', 3) ;
CALL STP_STAG23_MICRO('cowboys', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'H', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dolphins', 'L', 3) ;
CALL STP_STAG23_MICRO('dolphins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'H', 3) ;
CALL STP_STAG23_MICRO('eagles', 'H') ;

-- CALL STP_STAG23_1KWINSERT('eagles', 'L', 3) ;
CALL STP_STAG23_MICRO('eagles', 'L') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'H', 3) ;
CALL STP_STAG23_MICRO('falcons', 'H') ;

-- CALL STP_STAG23_1KWINSERT('falcons', 'L', 3) ;
CALL STP_STAG23_MICRO('falcons', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'H', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nygiants', 'L', 3) ;
CALL STP_STAG23_MICRO('nygiants', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'H', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jaguars', 'L', 3) ;
CALL STP_STAG23_MICRO('jaguars', 'L') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'H', 3) ;
CALL STP_STAG23_MICRO('jets', 'H') ;

-- CALL STP_STAG23_1KWINSERT('jets', 'L', 3) ;
CALL STP_STAG23_MICRO('jets', 'L') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'H', 3) ;
CALL STP_STAG23_MICRO('lions', 'H') ;

-- CALL STP_STAG23_1KWINSERT('lions', 'L', 3) ;
CALL STP_STAG23_MICRO('lions', 'L') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'H', 3) ;
CALL STP_STAG23_MICRO('packers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('packers', 'L', 3) ;
CALL STP_STAG23_MICRO('packers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'H', 3) ;
CALL STP_STAG23_MICRO('panthers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('panthers', 'L', 3) ;
CALL STP_STAG23_MICRO('panthers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'H', 3) ;
CALL STP_STAG23_MICRO('patriots', 'H') ;

-- CALL STP_STAG23_1KWINSERT('patriots', 'L', 3) ;
CALL STP_STAG23_MICRO('patriots', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'H', 3) ;
CALL STP_STAG23_MICRO('raiders', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raiders', 'L', 3) ;
CALL STP_STAG23_MICRO('raiders', 'L') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'H', 3) ;
CALL STP_STAG23_MICRO('rams', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rams', 'L', 3) ;
CALL STP_STAG23_MICRO('rams', 'L') ;


-- CALL STP_STAG23_1KWINSERT('redskins', 'H', 3) ;
CALL STP_STAG23_MICRO('redskins', 'H') ;

-- CALL STP_STAG23_1KWINSERT('redskins', 'L', 3) ;
CALL STP_STAG23_MICRO('redskins', 'L') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'H', 3) ;
CALL STP_STAG23_MICRO('saints', 'H') ;

-- CALL STP_STAG23_1KWINSERT('saints', 'L', 3) ;
CALL STP_STAG23_MICRO('saints', 'L') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'H', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'H') ;

-- CALL STP_STAG23_1KWINSERT('seahawks', 'L', 3) ;
CALL STP_STAG23_MICRO('seahawks', 'L') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'H', 3) ;
CALL STP_STAG23_MICRO('steelers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('steelers', 'L', 3) ;
CALL STP_STAG23_MICRO('steelers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'H', 3) ;
CALL STP_STAG23_MICRO('texans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('texans', 'L', 3) ;
CALL STP_STAG23_MICRO('texans', 'L') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'H', 3) ;
CALL STP_STAG23_MICRO('titans', 'H') ;

-- CALL STP_STAG23_1KWINSERT('titans', 'L', 3) ;
CALL STP_STAG23_MICRO('titans', 'L') ;


-- CALL STP_STAG23_1KWINSERT('vikings', 'H', 3) ;
CALL STP_STAG23_MICRO('vikings', 'H') ;

-- CALL STP_STAG23_1KWINSERT('vikings', 'L', 3) ;
CALL STP_STAG23_MICRO('vikings', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'H', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fantasy', 'L', 3) ;
CALL STP_STAG23_MICRO('fantasy', 'L') ;


/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA'  AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC LIKE 'SPORT%' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'NFL' AND MOVED_TO_POST_FLAG = 'N' ;   

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T2NFLUSA_HL', 'SPORT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T3 //
CREATE PROCEDURE STP_GRAND_T3()
THISPROC: BEGIN

/*

03/21/2019 ADDED THE SWEEP TO WSR_UNTAGGED AND WSR_CONVERTED

04/17/2019 AST: Added handling of SCIAM/CHEMISTRY source

04/19/2019 AST: Replaced AND UPPER(SCRAPE_TAG1) = UPPER('SCIENCE') AND UPPER(SCRAPE_TAG2) = UPPER('SCIENCE') 
with
 AND SCRAPE_TOPIC = 'SCIENCE'
 Also, Replaced COUNTRY_CODE = 'GGG' 
 WITH 1=1 (THIS IS because now any user with any country_code can create KWs. This interferes with STP.
 
 For ex. Black Hole Photographed KW is created by IND user. the STP was always looking for GGG and hence it did not tag 
 the relevant scrapes.
 
 04/24/2019 AST:  Added OR UPPER(NEWS_URL) LIKE  UPPER('%CRISPR%') to genetics
                  Added  OR UPPER(NEWS_URL) LIKE  UPPER('%neander%'), OR UPPER(NEWS_URL) LIKE  UPPER('%archeo%') to evolution
                  Added OR  UPPER(NEWS_URL) LIKE  UPPER('%conservation%') environment
                  
                  Added SET TAG_DONE_FLAG = 'Y', to UPDATE statement. This is done so that the untagged news items can be 
                  swept into tags for 'Science News', 'Technology News' etc.
                  
 04/27/2019 AST : Added UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sciencenews3'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
                        TAG_DONE_FLAG = 'N' AND SCRAPE_SOURCE = 'Arstechnica/SCIENCE' AND NEWS_URL LIKE '%/SCIENCE/%' ;
                        
                    Added CALL STP_STAG23_MICRO('sciencenews3', 'L') ;
                    (these latest additions make it possible to distribute the science news to those that subscribe to the specific KW (Science News)
                    instead of randomly distributing it to all
                    
                    Same logic will be used for adding 'Technology News'
                    
07/11/2019 AST: Added handling of SCIAM/BIO source

09/19/2020 AST: Several Changes:
		1. Adding the NEWS_HEADLINE and NEWS_EXCERPT in the UPDATE
        2. Adding SCIENCENEWS3 for XYZNEWS handling
        
        09/20/2020 AST: Adding SCIENCENEWS3 for country_code IND and USA - ELSE IT WOULD NOT STP
        TO THE MAIN USERS

10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'physics'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%physics%%') OR UPPER(NEWS_URL) 
LIKE  UPPER('%PARTICLE%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%QUANTUM%%')
 OR UPPER(NEWS_URL) LIKE  UPPER('%PHYSICIS%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%GRAVITY%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%NEUTRIN%%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%ACCELERA%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%HADRON%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%CERN%%'))
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'physics'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%physics%%') OR UPPER(NEWS_URL) 
LIKE  UPPER('%PARTICLE%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%QUANTUM%%')
 OR UPPER(NEWS_URL) LIKE  UPPER('%PHYSICIS%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%GRAVITY%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%NEUTRIN%%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%ACCELERA%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%HADRON%%')  OR UPPER(NEWS_URL) LIKE  UPPER('%CERN%%'))
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%chem%%') OR UPPER(NEWS_URL) LIKE  UPPER('%MATERIAL%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%chem%%') OR UPPER(NEWS_URL) LIKE  UPPER('%MATERIAL%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('CHEMISTRY') AND UPPER(SCRAPE_TAG2) = UPPER('CHEMISTRY');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'math'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%math%%') OR UPPER(NEWS_URL) LIKE  UPPER('%algo%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'math'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%math%%') OR UPPER(NEWS_URL) LIKE  UPPER('%algo%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'bio'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%bio%chem%') OR UPPER(NEWS_URL) LIKE  UPPER('%biology%') OR  UPPER(NEWS_URL) LIKE  UPPER('%bio%chem%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%biology%') OR  UPPER(NEWS_URL) LIKE  UPPER('%insect%') OR  UPPER(NEWS_URL) LIKE  UPPER('%animal%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%fish%') OR  UPPER(NEWS_URL) LIKE  UPPER('%life%') OR  UPPER(NEWS_URL) LIKE  UPPER('%plant%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%tree%') OR  UPPER(NEWS_URL) LIKE  UPPER('%chimpa%') OR  UPPER(NEWS_URL) LIKE  UPPER('%monkey%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'bio'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%bio%chem%') OR UPPER(NEWS_URL) LIKE  UPPER('%biology%') OR  UPPER(NEWS_URL) LIKE  UPPER('%bio%chem%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%biology%') OR  UPPER(NEWS_URL) LIKE  UPPER('%insect%') OR  UPPER(NEWS_URL) LIKE  UPPER('%animal%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%fish%') OR  UPPER(NEWS_URL) LIKE  UPPER('%life%') OR  UPPER(NEWS_URL) LIKE  UPPER('%plant%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%tree%') OR  UPPER(NEWS_URL) LIKE  UPPER('%chimpa%') OR  UPPER(NEWS_URL) LIKE  UPPER('%monkey%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'engg'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%engineer%') OR UPPER(NEWS_URL) LIKE  UPPER('%techn%') OR  UPPER(NEWS_URL) LIKE  UPPER('%technolog%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%electronic%') OR  UPPER(NEWS_URL) LIKE  UPPER('%metallurg%') OR  UPPER(NEWS_URL) LIKE  UPPER('%mechanical%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'engg'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%engineer%') OR UPPER(NEWS_URL) LIKE  UPPER('%techn%') OR  UPPER(NEWS_URL) LIKE  UPPER('%technolog%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%electronic%') OR  UPPER(NEWS_URL) LIKE  UPPER('%metallurg%') OR  UPPER(NEWS_URL) LIKE  UPPER('%mechanical%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'compsci'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%comput%') OR UPPER(NEWS_URL) LIKE  UPPER('%microproc%') OR  UPPER(NEWS_URL) LIKE  UPPER('%big%data%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%byte%') OR  UPPER(NEWS_URL) LIKE  UPPER('%artif%intel%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'compsci'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%comput%') OR UPPER(NEWS_URL) LIKE  UPPER('%microproc%') OR  UPPER(NEWS_URL) LIKE  UPPER('%big%data%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%byte%') OR  UPPER(NEWS_URL) LIKE  UPPER('%artif%intel%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'genetics'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%genetic%') OR UPPER(NEWS_URL) LIKE  UPPER('%gene%') OR  UPPER(NEWS_URL) LIKE  UPPER('%genome%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%dna%') OR  UPPER(NEWS_URL) LIKE  UPPER('%chromoso%') OR  UPPER(NEWS_URL) LIKE  UPPER('%notype%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%CRISPR%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'genetics'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%genetic%') OR UPPER(NEWS_URL) LIKE  UPPER('%gene%') OR  UPPER(NEWS_URL) LIKE  UPPER('%genome%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%dna%') OR  UPPER(NEWS_URL) LIKE  UPPER('%chromoso%') OR  UPPER(NEWS_URL) LIKE  UPPER('%notype%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%CRISPR%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'med'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%medicin%') OR UPPER(NEWS_URL) LIKE  UPPER('%therapy%') OR  UPPER(NEWS_URL) LIKE  UPPER('%treatment%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%cure%') OR  UPPER(NEWS_URL) LIKE  UPPER('%disease%') OR  UPPER(NEWS_URL) LIKE  UPPER('%doctor%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%stem%cell%') OR  UPPER(NEWS_URL) LIKE  UPPER('%cancer%') OR  UPPER(NEWS_URL) LIKE  UPPER('%physician%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'med'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%medicin%') OR UPPER(NEWS_URL) LIKE  UPPER('%therapy%') OR  UPPER(NEWS_URL) LIKE  UPPER('%treatment%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%cure%') OR  UPPER(NEWS_URL) LIKE  UPPER('%disease%') OR  UPPER(NEWS_URL) LIKE  UPPER('%doctor%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%stem%cell%') OR  UPPER(NEWS_URL) LIKE  UPPER('%cancer%') OR  UPPER(NEWS_URL) LIKE  UPPER('%physician%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'evo'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%evolution%') OR UPPER(NEWS_URL) LIKE  UPPER('%darwin%') OR  UPPER(NEWS_URL) LIKE  UPPER('%fossil%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%saur%') OR  UPPER(NEWS_URL) LIKE  UPPER('%evolv%') OR UPPER(NEWS_URL) LIKE  UPPER('%neander%')
OR UPPER(NEWS_URL) LIKE  UPPER('%archeo%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'evo'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%evolution%') OR UPPER(NEWS_URL) LIKE  UPPER('%darwin%') OR  UPPER(NEWS_URL) LIKE  UPPER('%fossil%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%saur%') OR  UPPER(NEWS_URL) LIKE  UPPER('%evolv%') OR UPPER(NEWS_URL) LIKE  UPPER('%neander%')
OR UPPER(NEWS_URL) LIKE  UPPER('%archeo%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';


UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'robot'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%robot%') OR UPPER(NEWS_URL) LIKE  UPPER('%automat%') OR  UPPER(NEWS_URL) LIKE  UPPER('%self%drive%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'robot'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%robot%') OR UPPER(NEWS_URL) LIKE  UPPER('%automat%') OR  UPPER(NEWS_URL) LIKE  UPPER('%self%drive%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sosci'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%social%') OR UPPER(NEWS_URL) LIKE  UPPER('%psych%') OR  UPPER(NEWS_URL) LIKE  UPPER('%sociolo%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%behavio%') OR UPPER(NEWS_URL) LIKE  UPPER('%communi%') OR  UPPER(NEWS_URL) LIKE  UPPER('%socie%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sosci'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%social%') OR UPPER(NEWS_URL) LIKE  UPPER('%psych%') OR  UPPER(NEWS_URL) LIKE  UPPER('%sociolo%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%behavio%') OR UPPER(NEWS_URL) LIKE  UPPER('%communi%') OR  UPPER(NEWS_URL) LIKE  UPPER('%socie%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'env'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%environ%') OR UPPER(NEWS_URL) LIKE  UPPER('%climate%') OR  UPPER(NEWS_URL) LIKE  UPPER('%weather%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%storm%') OR UPPER(NEWS_URL) LIKE  UPPER('%warming%') OR  UPPER(NEWS_URL) LIKE  UPPER('%sierra%') 
OR  UPPER(NEWS_URL) LIKE  UPPER('%solar%') OR  UPPER(NEWS_URL) LIKE  UPPER('%energy%') OR  UPPER(NEWS_URL) LIKE  UPPER('%conservation%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'env'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%environ%') OR UPPER(NEWS_URL) LIKE  UPPER('%climate%') OR  UPPER(NEWS_URL) LIKE  UPPER('%weather%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%storm%') OR UPPER(NEWS_URL) LIKE  UPPER('%warming%') OR  UPPER(NEWS_URL) LIKE  UPPER('%sierra%') 
OR  UPPER(NEWS_URL) LIKE  UPPER('%solar%') OR  UPPER(NEWS_URL) LIKE  UPPER('%energy%') OR  UPPER(NEWS_URL) LIKE  UPPER('%conservation%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'space'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%space%') OR UPPER(NEWS_URL) LIKE  UPPER('%nasa%') OR  UPPER(NEWS_URL) LIKE  UPPER('%satelli%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%galax%') OR UPPER(NEWS_URL) LIKE  UPPER('%black%hole%') OR  UPPER(NEWS_URL) LIKE  UPPER('%mars%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%jupite%') OR UPPER(NEWS_URL) LIKE  UPPER('%saturn%') OR  UPPER(NEWS_URL) LIKE  UPPER('%venus%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%light%year%') OR UPPER(NEWS_URL) LIKE  UPPER('%planet%') OR  UPPER(NEWS_URL) LIKE  UPPER('%astrono%') 

)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'space'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_URL) LIKE  UPPER('%space%') OR UPPER(NEWS_URL) LIKE  UPPER('%nasa%') OR  UPPER(NEWS_URL) LIKE  UPPER('%satelli%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%galax%') OR UPPER(NEWS_URL) LIKE  UPPER('%black%hole%') OR  UPPER(NEWS_URL) LIKE  UPPER('%mars%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%jupite%') OR UPPER(NEWS_URL) LIKE  UPPER('%saturn%') OR  UPPER(NEWS_URL) LIKE  UPPER('%venus%') 
OR UPPER(NEWS_URL) LIKE  UPPER('%light%year%') OR UPPER(NEWS_URL) LIKE  UPPER('%planet%') OR  UPPER(NEWS_URL) LIKE  UPPER('%astrono%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'physics'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%physics%%') OR UPPER(NEWS_HEADLINE) 
LIKE  UPPER('%PARTICLE%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%QUANTUM%%')
 OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%PHYSICIS%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%GRAVITY%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%NEUTRIN%%') 
 OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%ACCELERA%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%HADRON%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%CERN%%'))
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'physics'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%physics%%') OR UPPER(NEWS_HEADLINE) 
LIKE  UPPER('%PARTICLE%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%QUANTUM%%')
 OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%PHYSICIS%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%GRAVITY%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%NEUTRIN%%') 
 OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%ACCELERA%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%HADRON%%')  OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%CERN%%'))
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%chem%%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%MATERIAL%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%chem%%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%MATERIAL%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'chem'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('CHEMISTRY') AND UPPER(SCRAPE_TAG2) = UPPER('CHEMISTRY');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'math'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%math%%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%algo%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'math'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_HEADLINE) LIKE  UPPER('%math%%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%algo%') )
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'bio'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%bio%chem%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%biology%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%bio%chem%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%biology%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%insect%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%animal%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%fish%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%life%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%plant%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%tree%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%chimpa%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%monkey%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'bio'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%bio%chem%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%biology%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%bio%chem%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%biology%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%insect%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%animal%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%fish%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%life%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%plant%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%tree%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%chimpa%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%monkey%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'engg'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%engineer%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%techn%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%technolog%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%electronic%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%metallurg%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%mechanical%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'engg'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%engineer%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%techn%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%technolog%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%electronic%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%metallurg%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%mechanical%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'compsci'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%comput%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%microproc%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%big%data%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%byte%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%artif%intel%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'compsci'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%comput%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%microproc%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%big%data%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%byte%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%artif%intel%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'genetics'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%genetic%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%gene%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%genome%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%dna%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%chromoso%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%notype%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%CRISPR%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'genetics'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%genetic%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%gene%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%genome%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%dna%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%chromoso%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%notype%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%CRISPR%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'med'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%medicin%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%therapy%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%treatment%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%cure%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%disease%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%doctor%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%stem%cell%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%cancer%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%physician%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'med'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%medicin%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%therapy%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%treatment%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%cure%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%disease%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%doctor%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%stem%cell%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%cancer%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%physician%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'evo'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%evolution%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%darwin%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%fossil%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%saur%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%evolv%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%neander%')
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%archeo%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'evo'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%evolution%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%darwin%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%fossil%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%saur%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%evolv%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%neander%')
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%archeo%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';


UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'robot'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%robot%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%automat%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%self%drive%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'robot'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%robot%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%automat%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%self%drive%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sosci'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%social%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%psych%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%sociolo%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%behavio%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%communi%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%socie%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sosci'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%social%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%psych%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%sociolo%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%behavio%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%communi%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%socie%')
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'env'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%environ%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%climate%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%weather%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%storm%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%warming%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%sierra%') 
OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%solar%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%energy%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%conservation%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'env'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%environ%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%climate%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%weather%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%storm%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%warming%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%sierra%') 
OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%solar%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%energy%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%conservation%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'space'    , SCRAPE_TAG3 = 'H'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%space%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%nasa%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%satelli%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%galax%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%black%hole%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%mars%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%jupite%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%saturn%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%venus%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%light%year%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%planet%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%astrono%') 

)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE'  LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'space'    , SCRAPE_TAG3 = 'L'    WHERE  MOVED_TO_POST_FLAG = 'N' AND 
(UPPER(NEWS_HEADLINE) LIKE  UPPER('%space%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%nasa%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%satelli%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%galax%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%black%hole%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%mars%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%jupite%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%saturn%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%venus%') 
OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%light%year%') OR UPPER(NEWS_HEADLINE) LIKE  UPPER('%planet%') OR  UPPER(NEWS_HEADLINE) LIKE  UPPER('%astrono%') 
)
AND 1=1  AND SCRAPE_TOPIC = 'SCIENCE';

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'BIO'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('BIOLOGY') AND UPPER(SCRAPE_TAG2) = UPPER('BIOLOGY');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'EVO'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('EVO') AND UPPER(SCRAPE_TAG2) = UPPER('EVO');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'MATH'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('MATH') AND UPPER(SCRAPE_TAG2) = UPPER('MATH');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'SPACE'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('SPACE') AND UPPER(SCRAPE_TAG2) = UPPER('SPACE');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'MED'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('MED') AND UPPER(SCRAPE_TAG2) = UPPER('MED');

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'biotech3'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND 1=1  AND UPPER(SCRAPE_TAG1) = UPPER('BIOTECH') AND UPPER(SCRAPE_TAG2) = UPPER('BIOTECH');


-- CALL STP_STAG23_1KWINSERT('space', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('space', 'L', 3) ;
CALL STP_STAG23_MICRO('space', 'L') ;

-- CALL STP_STAG23_1KWINSERT('env', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('env', 'L', 3) ;
CALL STP_STAG23_MICRO('env', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sosci', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('sosci', 'L', 3) ;
CALL STP_STAG23_MICRO('sosci', 'L') ;

-- CALL STP_STAG23_1KWINSERT('robot', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('robot', 'L', 3) ;
CALL STP_STAG23_MICRO('robot', 'L') ;


-- CALL STP_STAG23_1KWINSERT('evo', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('evo', 'L', 3) ;
CALL STP_STAG23_MICRO('evo', 'L') ;

-- CALL STP_STAG23_1KWINSERT('med', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('med', 'L', 3) ;
CALL STP_STAG23_MICRO('med', 'L') ;

-- CALL STP_STAG23_1KWINSERT('genetics', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('genetics', 'L', 3) ;
CALL STP_STAG23_MICRO('genetics', 'L') ;

-- CALL STP_STAG23_1KWINSERT('compsci', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('compsci', 'L', 3) ;
CALL STP_STAG23_MICRO('compsci', 'L') ;

-- CALL STP_STAG23_1KWINSERT('engg', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('engg', 'L', 2) ;
CALL STP_STAG23_MICRO('engg', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bio', 'H', 3) ;

-- CALL STP_STAG23_1KWINSERT('bio', 'L', 6) ;
CALL STP_STAG23_MICRO('bio', 'L') ;

-- CALL STP_STAG23_1KWINSERT('math', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('math', 'L', 2) ;
CALL STP_STAG23_MICRO('math', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chem', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('chem', 'L', 2) ;
CALL STP_STAG23_MICRO('chem', 'L') ;

-- CALL STP_STAG23_1KWINSERT('physics', 'H', 1) ;

-- CALL STP_STAG23_1KWINSERT('physics', 'L', 2) ;
CALL STP_STAG23_MICRO('physics', 'L') ;

CALL STP_STAG23_MICRO('biotech3', 'L') ;


INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('SCIENCE') AND 1=1  AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T3', 'SCIENCE', 'GGG', POSTCOUNT, UNTAGCOUNT, NOW()) ;
  
  
  
END ; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T4IND //
CREATE PROCEDURE STP_GRAND_T4IND()
THISPROC: BEGIN

/* 
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/19/2020 AST: Adding BUSINESSNEWS4 STP steps
10/04/2020 AST: adding filter to BUSINESSNEWS4 to avoid: old news, stock market update
 10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'INDBIZ', SCRAPE_TAG2 = 'INDBIZ', SCRAPE_TAG3 = 'INDBIZ' WHERE COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC = 'BUSINESS'
AND (SCRAPE_SOURCE LIKE 'ET%' OR UPPER(SCRAPE_SOURCE) LIKE 'INDIAN%' OR SCRAPE_SOURCE LIKE 'DP%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ril'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIL-%'  OR UPPER(NEWS_URL) LIKE     '%RELIANCE%' 
OR UPPER(NEWS_URL) LIKE     '%MUKESH%'  OR UPPER(NEWS_URL) LIKE     '%JIO-%') AND  UPPER(NEWS_URL) NOT LIKE '%APRIL%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ril'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RIL-%'  OR UPPER(NEWS_URL) LIKE     '%RELIANCE%' 
OR UPPER(NEWS_URL) LIKE     '%MUKESH%'  OR UPPER(NEWS_URL) LIKE     '%JIO-%') AND  UPPER(NEWS_URL) NOT LIKE '%APRIL%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tata'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TATA%'  OR UPPER(NEWS_URL) LIKE     '%DOCOMO%' 
) AND  UPPER(NEWS_URL) NOT LIKE '%TCS%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tata'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TATA%'  OR UPPER(NEWS_URL) LIKE     '%DOCOMO%' 
) AND  UPPER(NEWS_URL) NOT LIKE '%TCS%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'birla', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%BIRLA%' OR UPPER(NEWS_URL) LIKE '%GRASIM%' 
OR UPPER(NEWS_URL) LIKE  '%HINDALCO%' OR UPPER(NEWS_URL) LIKE '%IDEA-%' OR UPPER(NEWS_URL) LIKE  '%ULTRATECH%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'birla', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE '%BIRLA%' OR UPPER(NEWS_URL) LIKE '%GRASIM%' 
OR UPPER(NEWS_URL) LIKE  '%HINDALCO%' OR UPPER(NEWS_URL) LIKE '%IDEA-%' OR UPPER(NEWS_URL) LIKE  '%ULTRATECH%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anilambani'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RELIANCE%'  OR UPPER(NEWS_URL) LIKE     '%BSES%' 
OR UPPER(NEWS_URL) LIKE     '%ANIL%AMBANI%' ) AND  UPPER(NEWS_URL) NOT LIKE '%-RIL-%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'anilambani'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RELIANCE%'  OR UPPER(NEWS_URL) LIKE     '%BSES%' 
OR UPPER(NEWS_URL) LIKE     '%ANIL%AMBANI%' ) AND  UPPER(NEWS_URL) NOT LIKE '%-RIL-%' AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airtel'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AIRTEL%'  OR UPPER(NEWS_URL) LIKE     '%BHARTI-%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airtel'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%AIRTEL%'  OR UPPER(NEWS_URL) LIKE     '%BHARTI-%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'infy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INFOSYS%'  OR UPPER(NEWS_URL) LIKE     '%NARAY%MURTHY%' 
OR UPPER(NEWS_URL) LIKE     '%INFY%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'infy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INFOSYS%'  OR UPPER(NEWS_URL) LIKE     '%NARAY%MURTHY%' 
OR UPPER(NEWS_URL) LIKE     '%INFY%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tcs'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TCS%'  OR UPPER(NEWS_URL) LIKE     '%TATA%CONSULT%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tcs'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TCS%'  OR UPPER(NEWS_URL) LIKE     '%TATA%CONSULT%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wipro'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%WIPRO%'  OR UPPER(NEWS_URL) LIKE     '%PREMJI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wipro'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%WIPRO%'  OR UPPER(NEWS_URL) LIKE     '%PREMJI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cogni'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%COGNIZ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cogni'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%COGNIZ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'itc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ITC-%' 
OR UPPER(NEWS_URL) LIKE     '%-ITC%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'itc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ITC-%' 
OR UPPER(NEWS_URL) LIKE     '%-ITC%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'icici'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ICICI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'icici'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ICICI%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sbi'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SBI%' 
OR UPPER(NEWS_URL) LIKE     '%STATE%BANK%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sbi'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SBI%' 
OR UPPER(NEWS_URL) LIKE     '%STATE%BANK%'  )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bajaj'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BAJAJ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bajaj'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BAJAJ%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mahindra'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MAHINDRA%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mahindra'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MAHINDRA%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hdfc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HDFC%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hdfc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HDFC%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'spice'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SPICE%JET%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'spice'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SPICE%JET%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indigo'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INDIGO%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'indigo'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%INDIGO%' 
 )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'INDBIZ'     AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('indigo', 'H', 2) ;
CALL STP_STAG23_MICRO('indigo', 'H') ;

-- CALL STP_STAG23_1KWINSERT('indigo', 'L', 2) ;
CALL STP_STAG23_MICRO('indigo', 'L') ;

-- CALL STP_STAG23_1KWINSERT('spice', 'H', 2) ;
CALL STP_STAG23_MICRO('spice', 'H') ;

-- CALL STP_STAG23_1KWINSERT('spice', 'L', 2) ;
CALL STP_STAG23_MICRO('spice', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hdfc', 'H', 2) ;
CALL STP_STAG23_MICRO('hdfc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hdfc', 'L', 2) ;
CALL STP_STAG23_MICRO('hdfc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mahindra', 'H', 2) ;
CALL STP_STAG23_MICRO('mahindra', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mahindra', 'L', 2) ;
CALL STP_STAG23_MICRO('mahindra', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bajaj', 'H', 2) ;
CALL STP_STAG23_MICRO('bajaj', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bajaj', 'L', 2) ;
CALL STP_STAG23_MICRO('bajaj', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sbi', 'H', 2) ;
CALL STP_STAG23_MICRO('sbi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sbi', 'L', 2) ;
CALL STP_STAG23_MICRO('sbi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('icici', 'H', 2) ;
CALL STP_STAG23_MICRO('icici', 'H') ;

-- CALL STP_STAG23_1KWINSERT('icici', 'L', 2) ;
CALL STP_STAG23_MICRO('icici', 'L') ;

-- CALL STP_STAG23_1KWINSERT('itc', 'H', 2) ;
CALL STP_STAG23_MICRO('itc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('itc', 'L', 2) ;
CALL STP_STAG23_MICRO('itc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cogni', 'H', 2) ;
CALL STP_STAG23_MICRO('cogni', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cogni', 'L', 2) ;
CALL STP_STAG23_MICRO('cogni', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wipro', 'H', 2) ;
CALL STP_STAG23_MICRO('wipro', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wipro', 'L', 2) ;
CALL STP_STAG23_MICRO('wipro', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tcs', 'H', 2) ;
CALL STP_STAG23_MICRO('tcs', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tcs', 'L', 2) ;
CALL STP_STAG23_MICRO('tcs', 'L') ;

-- CALL STP_STAG23_1KWINSERT('infy', 'H', 2) ;
CALL STP_STAG23_MICRO('infy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('infy', 'L', 2) ;
CALL STP_STAG23_MICRO('infy', 'L') ;

-- CALL STP_STAG23_1KWINSERT('airtel', 'H', 2) ;
CALL STP_STAG23_MICRO('airtel', 'H') ;

-- CALL STP_STAG23_1KWINSERT('airtel', 'L', 2) ;
CALL STP_STAG23_MICRO('airtel', 'L') ;

-- CALL STP_STAG23_1KWINSERT('anilambani', 'H', 2) ;
CALL STP_STAG23_MICRO('anilambani', 'H') ;

-- CALL STP_STAG23_1KWINSERT('anilambani', 'L', 2) ;
CALL STP_STAG23_MICRO('anilambani', 'L') ;

-- CALL STP_STAG23_1KWINSERT('birla', 'H', 2) ;
CALL STP_STAG23_MICRO('birla', 'H') ;

-- CALL STP_STAG23_1KWINSERT('birla', 'L', 2) ;
CALL STP_STAG23_MICRO('birla', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ril', 'H', 2) ;
CALL STP_STAG23_MICRO('ril', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ril', 'L', 2) ;
CALL STP_STAG23_MICRO('ril', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tata', 'H', 3) ;
CALL STP_STAG23_MICRO('tata', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tata', 'L', 3) ;
CALL STP_STAG23_MICRO('tata', 'L') ;

/* 091920 AST: COMPLETING THE ADDITION OF BUSINESSNEWS4 */

CALL STP_STAG23_MICRO('businessnews4', 'L') ;

CALL STP_STAG23_MICRO('businessnews4', 'H') ;



/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T4IND', 'BUSINESS', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T4USA //
CREATE PROCEDURE STP_GRAND_T4USA()
THISPROC: BEGIN

/* 
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

        09/19/2020 AST: Adding BUSINESSNEWS4 STP steps
        10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
        10/09/2020 AST: fixing the date issue in XYZNEWS  addition - also moving it to the front of the UPDATE
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

-- 

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USABIZ', SCRAPE_TAG2 = 'USABIZ', SCRAPE_TAG3 = 'USABIZ' WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' ;
 
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'apple', SCRAPE_TAG3 = 'L'  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%APPLE%'     
OR UPPER(NEWS_URL) LIKE     '%TIM%COOK%'     OR UPPER(NEWS_URL) LIKE     '%IPHONE%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'apple', SCRAPE_TAG3 = 'H'  WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%APPLE%'     
OR UPPER(NEWS_URL) LIKE     '%TIM%COOK%'     OR UPPER(NEWS_URL) LIKE     '%IPHONE%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'auto', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TOPIC = 'BUSINESS' AND ( NEWS_URL LIKE '%AUTO%' OR NEWS_URL LIKE '%TOYO%' OR NEWS_URL LIKE '%HOND%' OR NEWS_URL LIKE '%BMW%'
OR NEWS_URL LIKE '%MERC%' OR NEWS_URL LIKE '%-FORD%' OR NEWS_URL LIKE '%GM%' OR NEWS_URL LIKE '%CHRYS%' OR NEWS_URL LIKE '%KIA%'
OR NEWS_URL LIKE '%HYND%' OR NEWS_URL LIKE '%-AUDI-%' OR NEWS_URL LIKE '%PORSCH%' OR NEWS_URL LIKE '%FERRAR%' OR NEWS_URL LIKE '%LAMBORG%' OR NEWS_URL LIKE '%MASERA%'
  OR NEWS_URL LIKE '%NISSAN%' OR NEWS_URL LIKE '%MAZDA%' OR NEWS_URL LIKE '%-CAR-%' OR NEWS_URL LIKE '%VEHICL%' OR NEWS_URL LIKE '%GEN%MOTO%'
  OR NEWS_URL LIKE '%VOLK%' OR NEWS_URL LIKE '%VW%' OR NEWS_URL LIKE '%-AUTOMO%') AND MOD(ROW_ID, 2) = 1;
 
  UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'auto', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TOPIC = 'BUSINESS' AND ( NEWS_URL LIKE '%AUTO%' OR NEWS_URL LIKE '%TOYO%' OR NEWS_URL LIKE '%HOND%' OR NEWS_URL LIKE '%BMW%'
OR NEWS_URL LIKE '%MERC%' OR NEWS_URL LIKE '%-FORD%' OR NEWS_URL LIKE '%GM%' OR NEWS_URL LIKE '%CHRYS%' OR NEWS_URL LIKE '%KIA%'
OR NEWS_URL LIKE '%HYND%' OR NEWS_URL LIKE '%-AUDI-%' OR NEWS_URL LIKE '%PORSCH%' OR NEWS_URL LIKE '%FERRAR%' OR NEWS_URL LIKE '%LAMBORG%' OR NEWS_URL LIKE '%MASERA%'
  OR NEWS_URL LIKE '%NISSAN%' OR NEWS_URL LIKE '%MAZDA%' OR NEWS_URL LIKE '%-CAR-%' OR NEWS_URL LIKE '%VEHICL%' OR NEWS_URL LIKE '%GEN%MOTO%'
  OR NEWS_URL LIKE '%VOLK%' OR NEWS_URL LIKE '%VW%' OR NEWS_URL LIKE '%-AUTOMO%') AND MOD(ROW_ID, 2) = 0;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'msft'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MICROSOFT%'     
OR UPPER(NEWS_URL) LIKE     '%NADEL%'     OR UPPER(NEWS_URL) LIKE     '%LINKEDIN%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'msft'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%MICROSOFT%'     
OR UPPER(NEWS_URL) LIKE     '%NADEL%'     OR UPPER(NEWS_URL) LIKE     '%LINKEDIN%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fb'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%FACEBOOK%'     
OR UPPER(NEWS_URL) LIKE     '%ZUCKER%'     OR UPPER(NEWS_URL) LIKE     '%INSTAG%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'fb'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%FACEBOOK%'     
OR UPPER(NEWS_URL) LIKE     '%ZUCKER%'     OR UPPER(NEWS_URL) LIKE     '%INSTAG%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'google'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%GOOGLE%'     
OR UPPER(NEWS_URL) LIKE     '%PICHAI%'     OR UPPER(NEWS_URL) LIKE     '%ALPHABET%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'google'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%GOOGLE%'     
OR UPPER(NEWS_URL) LIKE     '%PICHAI%'     OR UPPER(NEWS_URL) LIKE     '%ALPHABET%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orcl'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ORACLE%'     
OR UPPER(NEWS_URL) LIKE     '%LARRY%ELLI%'     OR UPPER(NEWS_URL) LIKE     '%ORCL%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'orcl'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%ORACLE%'     
OR UPPER(NEWS_URL) LIKE     '%LARRY%ELLI%'     OR UPPER(NEWS_URL) LIKE     '%ORCL%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfdc'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALES%FORCE%'     
OR UPPER(NEWS_URL) LIKE     '%BENIOF%'     OR UPPER(NEWS_URL) LIKE     '%CRM%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sfdc'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%SALES%FORCE%'     
OR UPPER(NEWS_URL) LIKE     '%BENIOF%'     OR UPPER(NEWS_URL) LIKE     '%CRM%' )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oil', SCRAPE_TAG3 = 'L' WHERE SCRAPE_TOPIC = 'BUSINESS' AND MOVED_TO_POST_FLAG = 'N' AND
( NEWS_URL LIKE '%OIL%' OR NEWS_URL LIKE '%ENERYGY%' OR NEWS_URL LIKE '%EXXON%' OR NEWS_URL LIKE '%CHEVRON%'
OR NEWS_URL LIKE '%CONOCO%' OR NEWS_URL LIKE '%-SHELL-%' OR NEWS_URL LIKE '%VALERO%' OR NEWS_URL LIKE '%REFINER%' OR NEWS_URL LIKE '%CRUDE%OIL%'
) AND MOD(ROW_ID, 2) = 1;
 
  UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oil', SCRAPE_TAG3 = 'H' WHERE SCRAPE_TOPIC = 'BUSINESS' AND MOVED_TO_POST_FLAG = 'N' AND
( NEWS_URL LIKE '%OIL%' OR NEWS_URL LIKE '%ENERYGY%' OR NEWS_URL LIKE '%EXXON%' OR NEWS_URL LIKE '%CHEVRON%'
OR NEWS_URL LIKE '%CONOCO%' OR NEWS_URL LIKE '%-SHELL-%' OR NEWS_URL LIKE '%VALERO%' OR NEWS_URL LIKE '%REFINER%' OR NEWS_URL LIKE '%CRUDE%OIL%'
) AND MOD(ROW_ID, 2) = 0;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'att'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ATT-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('ATT-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ATT-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'att'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ATT-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('ATT-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ATT-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ccast'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-COMCAST-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-COMCAST%')     OR UPPER(NEWS_URL) LIKE     UPPER('%COMCAST-%') )     AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ccast'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-COMCAST-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-COMCAST%')     OR UPPER(NEWS_URL) LIKE     UPPER('%COMCAST-%') )      AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'biotech'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-biotech-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-bio%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bio-%') OR UPPER(NEWS_URL) LIKE UPPER('%amgen%') OR UPPER(NEWS_URL) LIKE UPPER('%genen%'))     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'biotech'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-biotech-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('-bio%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bio-%') OR UPPER(NEWS_URL) LIKE UPPER('%amgen%') OR UPPER(NEWS_URL) LIKE UPPER('%genen%'))        
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'health'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-health-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%DRUG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%PHARMA%') OR UPPER(NEWS_URL) LIKE UPPER('%MEDICINE%') OR UPPER(NEWS_URL) LIKE UPPER('%MERCK%')
OR UPPER(NEWS_URL) LIKE     UPPER('%PFIZER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%NOVARTIS%') OR UPPER(NEWS_URL) LIKE UPPER('%GLAXO%') OR UPPER(NEWS_URL) LIKE UPPER('%NOVO%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ALLARG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ASTRA%') OR UPPER(NEWS_URL) LIKE UPPER('%RECKITT%') OR UPPER(NEWS_URL) LIKE UPPER('%ROCHE%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ABBOT%')     OR UPPER(NEWS_URL) LIKE     UPPER('%SANOFI%') OR UPPER(NEWS_URL) LIKE UPPER('%JOHN%JOHN%') OR UPPER(NEWS_URL) LIKE UPPER('%LILLY%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'health'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-health-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%DRUG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%PHARMA%') OR UPPER(NEWS_URL) LIKE UPPER('%MEDICINE%') OR UPPER(NEWS_URL) LIKE UPPER('%MERCK%')
OR UPPER(NEWS_URL) LIKE     UPPER('%PFIZER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%NOVARTIS%') OR UPPER(NEWS_URL) LIKE UPPER('%GLAXO%') OR UPPER(NEWS_URL) LIKE UPPER('%NOVO%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ALLARG%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ASTRA%') OR UPPER(NEWS_URL) LIKE UPPER('%RECKITT%') OR UPPER(NEWS_URL) LIKE UPPER('%ROCHE%')
OR UPPER(NEWS_URL) LIKE     UPPER('%ABBOT%')     OR UPPER(NEWS_URL) LIKE     UPPER('%SANOFI%') OR UPPER(NEWS_URL) LIKE UPPER('%JOHN%JOHN%') OR UPPER(NEWS_URL) LIKE UPPER('%LILLY%'))        
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'coke'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-coke-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%coca%')     OR UPPER(NEWS_URL) LIKE     UPPER('%cola%') OR UPPER(NEWS_URL) LIKE UPPER('%pepsi%') OR UPPER(NEWS_URL) LIKE UPPER('%beverage%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'coke'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-coke-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%coca%')     OR UPPER(NEWS_URL) LIKE     UPPER('%cola%') OR UPPER(NEWS_URL) LIKE UPPER('%pepsi%') OR UPPER(NEWS_URL) LIKE UPPER('%beverage%'))         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'insurance'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-insurance-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aig-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-aig%') OR UPPER(NEWS_URL) LIKE UPPER('%INSUR%') OR UPPER(NEWS_URL) LIKE UPPER('%state%farm%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'insurance'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-insurance-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aig-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-aig%') OR UPPER(NEWS_URL) LIKE UPPER('%INSUR%') OR UPPER(NEWS_URL) LIKE UPPER('%state%farm%'))         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twtr'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-twtr-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%TWITTER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%DORSEY%') OR UPPER(NEWS_URL) LIKE UPPER('%TWEET%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'twtr'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-twtr-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%TWITTER%')     OR UPPER(NEWS_URL) LIKE     UPPER('%DORSEY%') OR UPPER(NEWS_URL) LIKE UPPER('%TWEET%') )         
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amzn'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-amzn-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amazon%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bezos%') OR UPPER(NEWS_URL) LIKE UPPER('%whole%food%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amzn'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-amzn-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amazon%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bezos%') OR UPPER(NEWS_URL) LIKE UPPER('%whole%food%') )          
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'disney'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-disney-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%pixar%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-iger-%') OR UPPER(NEWS_URL) LIKE UPPER('%netflix%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'disney'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-disney-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%pixar%')     OR UPPER(NEWS_URL) LIKE     UPPER('%-iger-%') OR UPPER(NEWS_URL) LIKE UPPER('%netflix%') )       
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mcd'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-mcd-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%mcdonald%')     OR UPPER(NEWS_URL) LIKE     UPPER('%fast%food%') OR UPPER(NEWS_URL) LIKE UPPER('%burger%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mcd'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-mcd-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%mcdonald%')     OR UPPER(NEWS_URL) LIKE     UPPER('%fast%food%') OR UPPER(NEWS_URL) LIKE UPPER('%burger%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ge'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ge-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%general%electric%')     OR UPPER(NEWS_URL) LIKE     UPPER('%flannery%') OR UPPER(NEWS_URL) LIKE UPPER('%siemens%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%honeywell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%mmm%') OR UPPER(NEWS_URL) LIKE UPPER('%danaher%'))    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ge'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ge-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%general%electric%')     OR UPPER(NEWS_URL) LIKE     UPPER('%flannery%') OR UPPER(NEWS_URL) LIKE UPPER('%siemens%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%honeywell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%mmm%') OR UPPER(NEWS_URL) LIKE UPPER('%danaher%'))      
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ibm'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ibm-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%dell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ibm-%') OR UPPER(NEWS_URL) LIKE UPPER('%-ibm%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'ibm'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-ibm-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%dell%')     OR UPPER(NEWS_URL) LIKE     UPPER('%ibm-%') OR UPPER(NEWS_URL) LIKE UPPER('%-ibm%') ) 
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tesla'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-tesla-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%musc%')     OR UPPER(NEWS_URL) LIKE     UPPER('%tesla-%') OR UPPER(NEWS_URL) LIKE UPPER('%-tesla%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tesla'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-tesla-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%musc%')     OR UPPER(NEWS_URL) LIKE     UPPER('%tesla-%') OR UPPER(NEWS_URL) LIKE UPPER('%-tesla%') )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'boeing'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-boeing-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aircraft%')     OR UPPER(NEWS_URL) LIKE     UPPER('%boeing-%') OR UPPER(NEWS_URL) LIKE UPPER('%-boeing%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'boeing'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-boeing-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%aircraft%')     OR UPPER(NEWS_URL) LIKE     UPPER('%boeing-%') OR UPPER(NEWS_URL) LIKE UPPER('%-boeing%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airline'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-airline-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%air%travel%')     OR UPPER(NEWS_URL) LIKE     UPPER('%airline-%') OR UPPER(NEWS_URL) LIKE UPPER('%-airline%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%united%')     OR UPPER(NEWS_URL) LIKE     UPPER('%southwest%') OR UPPER(NEWS_URL) LIKE UPPER('%delta%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%american%air%')     OR UPPER(NEWS_URL) LIKE     UPPER('%jetblue%') OR UPPER(NEWS_URL) LIKE UPPER('%alaska%air%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'airline'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-airline-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%air%travel%')     OR UPPER(NEWS_URL) LIKE     UPPER('%airline-%') OR UPPER(NEWS_URL) LIKE UPPER('%-airline%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%united%')     OR UPPER(NEWS_URL) LIKE     UPPER('%southwest%') OR UPPER(NEWS_URL) LIKE UPPER('%delta%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%american%air%')     OR UPPER(NEWS_URL) LIKE     UPPER('%jetblue%') OR UPPER(NEWS_URL) LIKE UPPER('%alaska%air%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'visa'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-visa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amer%express%')     OR UPPER(NEWS_URL) LIKE     UPPER('%visa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-visa%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'visa'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-visa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%amer%express%')     OR UPPER(NEWS_URL) LIKE     UPPER('%visa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-visa%') )     
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nike'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-nike-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%footwear%')     OR UPPER(NEWS_URL) LIKE     UPPER('%nike-%') OR UPPER(NEWS_URL) LIKE UPPER('%-nike%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%sporting%')     OR UPPER(NEWS_URL) LIKE     UPPER('%lulu%') OR UPPER(NEWS_URL) LIKE UPPER('%under%armour%')
OR UPPER(NEWS_URL) LIKE     UPPER('%adidas%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'nike'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-nike-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%footwear%')     OR UPPER(NEWS_URL) LIKE     UPPER('%nike-%') OR UPPER(NEWS_URL) LIKE UPPER('%-nike%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%sporting%')     OR UPPER(NEWS_URL) LIKE     UPPER('%lulu%') OR UPPER(NEWS_URL) LIKE UPPER('%under%armour%')
OR UPPER(NEWS_URL) LIKE     UPPER('%adidas%')  )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wells'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-wells-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%fargo%')     OR UPPER(NEWS_URL) LIKE     UPPER('%wells-%') OR UPPER(NEWS_URL) LIKE UPPER('%-wells%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%-bank-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%banking%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wells'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-wells-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%fargo%')     OR UPPER(NEWS_URL) LIKE     UPPER('%wells-%') OR UPPER(NEWS_URL) LIKE UPPER('%-wells%') 
OR UPPER(NEWS_URL) LIKE     UPPER('%-bank-%')     OR UPPER(NEWS_URL) LIKE     UPPER('%banking%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bofa'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-bofa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%bank%ameri%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bofa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-bofa%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bofa'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-bofa-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%bank%ameri%')     OR UPPER(NEWS_URL) LIKE     UPPER('%bofa-%') OR UPPER(NEWS_URL) LIKE UPPER('%-bofa%') ) 
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chase'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-chase-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%j%morgan%')     OR UPPER(NEWS_URL) LIKE     UPPER('%chase-%') OR UPPER(NEWS_URL) LIKE UPPER('%-chase%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'chase'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     UPPER('%-chase-%')     
OR UPPER(NEWS_URL) LIKE     UPPER('%j%morgan%')     OR UPPER(NEWS_URL) LIKE     UPPER('%chase-%') OR UPPER(NEWS_URL) LIKE UPPER('%-chase%') )   
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'citi'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-citi-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%citibank%') OR UPPER(NEWS_URL) LIKE  UPPER('%citi-%') OR UPPER(NEWS_URL) LIKE UPPER('%-citi%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'citi'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-citi-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%citibank%') OR UPPER(NEWS_URL) LIKE  UPPER('%citi-%') OR UPPER(NEWS_URL) LIKE UPPER('%-citi%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dupont'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-dupont-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%chemical%') OR UPPER(NEWS_URL) LIKE  UPPER('%dupont-%') OR UPPER(NEWS_URL) LIKE UPPER('%-dupont%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'dupont'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-dupont-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%chemical%') OR UPPER(NEWS_URL) LIKE  UPPER('%dupont-%') OR UPPER(NEWS_URL) LIKE UPPER('%-dupont%') )       
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pg'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-proctor-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-gamble-%') OR UPPER(NEWS_URL) LIKE  UPPER('%clorox%') OR UPPER(NEWS_URL) LIKE UPPER('%lever%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pg'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-proctor-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-gamble-%') OR UPPER(NEWS_URL) LIKE  UPPER('%clorox%') OR UPPER(NEWS_URL) LIKE UPPER('%lever%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macy'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-macy-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-retail-%') OR UPPER(NEWS_URL) LIKE  UPPER('%penney%') OR UPPER(NEWS_URL) LIKE UPPER('%shopper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'macy'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-macy-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-retail-%') OR UPPER(NEWS_URL) LIKE  UPPER('%penney%') OR UPPER(NEWS_URL) LIKE UPPER('%shopper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sears'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-sears-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-k-mart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%kmart%') OR UPPER(NEWS_URL) LIKE UPPER('%kenmore%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sears'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-sears-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-k-mart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%kmart%') OR UPPER(NEWS_URL) LIKE UPPER('%kenmore%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wmt'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-wmt-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-walmart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%walton%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'wmt'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-wmt-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-walmart-%') OR UPPER(NEWS_URL) LIKE  UPPER('%walton%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cisco'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-cisco-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-networking-%') OR UPPER(NEWS_URL) LIKE  UPPER('%juniper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'cisco'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-cisco-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-networking-%') OR UPPER(NEWS_URL) LIKE  UPPER('%juniper%') )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'snap'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-snap-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-snapchat-%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'   AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'snap'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' 
AND (UPPER(NEWS_URL) LIKE  UPPER('%-snap-%')  OR UPPER(NEWS_URL) LIKE  UPPER('%-snapchat-%')  )    
AND UPPER(SCRAPE_TAG1) = 'USABIZ'  AND MOD(ROW_ID, 2) = 0 ;



/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('snap', 'L', 1) ;
CALL STP_STAG23_MICRO('snap', 'L') ;

-- CALL STP_STAG23_1KWINSERT('snap', 'H', 1) ;
CALL STP_STAG23_MICRO('snap', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cisco', 'L', 1) ;
CALL STP_STAG23_MICRO('cisco', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cisco', 'H', 1) ;
CALL STP_STAG23_MICRO('cisco', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wmt', 'L', 1) ;
CALL STP_STAG23_MICRO('wmt', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wmt', 'H', 1) ;
CALL STP_STAG23_MICRO('wmt', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sears', 'L', 1) ;
CALL STP_STAG23_MICRO('sears', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sears', 'H', 1) ;
CALL STP_STAG23_MICRO('sears', 'H') ;

-- CALL STP_STAG23_1KWINSERT('macy', 'L', 1) ;
CALL STP_STAG23_MICRO('macy', 'L') ;

-- CALL STP_STAG23_1KWINSERT('macy', 'H', 1) ;
CALL STP_STAG23_MICRO('macy', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pg', 'L', 1) ;
CALL STP_STAG23_MICRO('pg', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pg', 'H', 1) ;
CALL STP_STAG23_MICRO('pg', 'H') ;

-- CALL STP_STAG23_1KWINSERT('dupont', 'L', 1) ;
CALL STP_STAG23_MICRO('dupont', 'L') ;

-- CALL STP_STAG23_1KWINSERT('dupont', 'H', 1) ;
CALL STP_STAG23_MICRO('dupont', 'H') ;

-- CALL STP_STAG23_1KWINSERT('citi', 'L', 1) ;
CALL STP_STAG23_MICRO('citi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('citi', 'H', 1) ;
CALL STP_STAG23_MICRO('citi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('chase', 'L', 1) ;
CALL STP_STAG23_MICRO('chase', 'L') ;

-- CALL STP_STAG23_1KWINSERT('chase', 'H', 1) ;
CALL STP_STAG23_MICRO('chase', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bofa', 'L', 1) ;
CALL STP_STAG23_MICRO('bofa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bofa', 'H', 1) ;
CALL STP_STAG23_MICRO('bofa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('wells', 'L', 1) ;
CALL STP_STAG23_MICRO('wells', 'L') ;

-- CALL STP_STAG23_1KWINSERT('wells', 'H', 1) ;
CALL STP_STAG23_MICRO('wells', 'H') ;

-- CALL STP_STAG23_1KWINSERT('nike', 'L', 1) ;
CALL STP_STAG23_MICRO('nike', 'L') ;

-- CALL STP_STAG23_1KWINSERT('nike', 'H', 1) ;
CALL STP_STAG23_MICRO('nike', 'H') ;

-- CALL STP_STAG23_1KWINSERT('visa', 'L', 1) ;
CALL STP_STAG23_MICRO('visa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('visa', 'H', 1) ;
CALL STP_STAG23_MICRO('visa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('airline', 'L', 1) ;
CALL STP_STAG23_MICRO('airline', 'L') ;

-- CALL STP_STAG23_1KWINSERT('airline', 'H', 1) ;
CALL STP_STAG23_MICRO('airline', 'H') ;

-- CALL STP_STAG23_1KWINSERT('boeing', 'L', 1) ;
CALL STP_STAG23_MICRO('boeing', 'L') ;

-- CALL STP_STAG23_1KWINSERT('boeing', 'H', 1) ;
CALL STP_STAG23_MICRO('boeing', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tesla', 'L', 1) ;
CALL STP_STAG23_MICRO('tesla', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tesla', 'H', 1) ;
CALL STP_STAG23_MICRO('tesla', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ibm', 'L', 1) ;
CALL STP_STAG23_MICRO('ibm', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ibm', 'H', 1) ;
CALL STP_STAG23_MICRO('ibm', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ge', 'L', 1) ;
CALL STP_STAG23_MICRO('ge', 'L') ;

-- CALL STP_STAG23_1KWINSERT('ge', 'H', 1) ;
CALL STP_STAG23_MICRO('ge', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mcd', 'L', 1) ;
CALL STP_STAG23_MICRO('mcd', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mcd', 'H', 1) ;
CALL STP_STAG23_MICRO('mcd', 'H') ;

-- CALL STP_STAG23_1KWINSERT('disney', 'L', 1) ;
CALL STP_STAG23_MICRO('disney', 'L') ;

-- CALL STP_STAG23_1KWINSERT('disney', 'H', 1) ;
CALL STP_STAG23_MICRO('disney', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amzn', 'L', 1) ;
CALL STP_STAG23_MICRO('amzn', 'L') ;

-- CALL STP_STAG23_1KWINSERT('amzn', 'H', 1) ;
CALL STP_STAG23_MICRO('amzn', 'H') ;

-- CALL STP_STAG23_1KWINSERT('twtr', 'L', 1) ;
CALL STP_STAG23_MICRO('twtr', 'L') ;

-- CALL STP_STAG23_1KWINSERT('twtr', 'H', 1) ;
CALL STP_STAG23_MICRO('twtr', 'H') ;

-- CALL STP_STAG23_1KWINSERT('insurance', 'L', 1) ;
CALL STP_STAG23_MICRO('insurance', 'L') ;

-- CALL STP_STAG23_1KWINSERT('insurance', 'H', 1) ;
CALL STP_STAG23_MICRO('insurance', 'H') ;

-- CALL STP_STAG23_1KWINSERT('coke', 'L', 1) ;
CALL STP_STAG23_MICRO('coke', 'L') ;

-- CALL STP_STAG23_1KWINSERT('coke', 'H', 1) ;
CALL STP_STAG23_MICRO('coke', 'H') ;

-- CALL STP_STAG23_1KWINSERT('health', 'L', 1) ;
CALL STP_STAG23_MICRO('health', 'L') ;

-- CALL STP_STAG23_1KWINSERT('health', 'H', 1) ;
CALL STP_STAG23_MICRO('health', 'H') ;

-- CALL STP_STAG23_1KWINSERT('biotech', 'L', 1) ;
CALL STP_STAG23_MICRO('biotech', 'L') ;

-- CALL STP_STAG23_1KWINSERT('biotech', 'H', 1) ;
CALL STP_STAG23_MICRO('biotech', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ccast', 'H', 3) ;
CALL STP_STAG23_MICRO('ccast', 'H') ;

-- CALL STP_STAG23_1KWINSERT('ccast', 'L', 3) ;
CALL STP_STAG23_MICRO('ccast', 'L') ;

-- CALL STP_STAG23_1KWINSERT('att', 'H', 3) ;
CALL STP_STAG23_MICRO('att', 'H') ;

-- CALL STP_STAG23_1KWINSERT('att', 'L', 3) ;
CALL STP_STAG23_MICRO('att', 'L') ;

-- CALL STP_STAG23_1KWINSERT('apple', 'L', 1) ;
CALL STP_STAG23_MICRO('apple', 'L') ;

-- CALL STP_STAG23_1KWINSERT('apple', 'H', 1) ;
CALL STP_STAG23_MICRO('apple', 'H') ;
 
-- CALL STP_STAG23_1KWINSERT('auto', 'L', 1) ;
CALL STP_STAG23_MICRO('auto', 'L') ;

-- CALL STP_STAG23_1KWINSERT('auto', 'H', 1) ;
CALL STP_STAG23_MICRO('auto', 'H') ;

-- CALL STP_STAG23_1KWINSERT('msft', 'L', 1) ;
CALL STP_STAG23_MICRO('msft', 'L') ;

-- CALL STP_STAG23_1KWINSERT('msft', 'H', 1) ;
CALL STP_STAG23_MICRO('msft', 'H') ;

-- CALL STP_STAG23_1KWINSERT('fb', 'L', 1) ;
CALL STP_STAG23_MICRO('fb', 'L') ;

-- CALL STP_STAG23_1KWINSERT('fb', 'H', 1) ;
CALL STP_STAG23_MICRO('fb', 'H') ;

-- CALL STP_STAG23_1KWINSERT('google', 'L', 1) ;
CALL STP_STAG23_MICRO('google', 'L') ;

-- CALL STP_STAG23_1KWINSERT('google', 'H', 1) ;
CALL STP_STAG23_MICRO('google', 'H') ;

-- CALL STP_STAG23_1KWINSERT('orcl', 'L', 1) ;
CALL STP_STAG23_MICRO('orcl', 'L') ;

-- CALL STP_STAG23_1KWINSERT('orcl', 'H', 1) ;
CALL STP_STAG23_MICRO('orcl', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sfdc', 'L', 1) ;
CALL STP_STAG23_MICRO('sfdc', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sfdc', 'H', 1) ;
CALL STP_STAG23_MICRO('sfdc', 'H') ;

-- CALL STP_STAG23_1KWINSERT('oil', 'L', 1) ;
CALL STP_STAG23_MICRO('oil', 'L') ;

-- CALL STP_STAG23_1KWINSERT('oil', 'H', 1) ;
CALL STP_STAG23_MICRO('oil', 'H') ;

/* 091920 AST: COMPLETING THE ADDITION OF BUSINESSNEWS4 */

CALL STP_STAG23_MICRO('businessnews4', 'L') ;

CALL STP_STAG23_MICRO('businessnews4', 'H') ;

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC = 'BUSINESS' AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T4USA', 'BUSINESS', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T5IND //
CREATE PROCEDURE STP_GRAND_T5IND()
THISPROC: BEGIN

DECLARE POSTCOUNT, UNTAGCOUNT INT ;


UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'BOLLYWOOD', SCRAPE_TAG2 = 'BOLLYWOOD', SCRAPE_TAG3 = 'BOLLYWOOD'
WHERE UPPER(SCRAPE_TOPIC) IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

/* 

06/12/2018 Added veere, raazi, 102, bhavesh, highjack, kaala, daasdev, hahm
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

09/19/2020 AST: Adding the tagging of 25 untagged scrapes to entertainmentnews5 KW
    10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padmavati'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PADMAAV%'  OR UPPER(NEWS_URL) LIKE     '%BHANSALI%' ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padmavati'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PADMAAV%'  OR UPPER(NEWS_URL) LIKE     '%BHANSALI%' ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mukka'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  '%MUKKAB%'  OR UPPER(NEWS_URL) LIKE '%VINEET%' 
OR UPPER(NEWS_URL) LIKE '%ZOYA%' OR UPPER(NEWS_URL) LIKE '%KASHYAP%') 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'mukka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  '%MUKKAB%'  OR UPPER(NEWS_URL) LIKE '%VINEET%' 
OR UPPER(NEWS_URL) LIKE '%ZOYA%' OR UPPER(NEWS_URL) LIKE '%KASHYAP%') 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pari'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%pari%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pari'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%pari%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonu'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%SONU%TITU%') OR UPPER(NEWS_URL) LIKE  UPPER('%KARTHIK%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%ARYAN%')  OR UPPER(NEWS_URL) LIKE  UPPER('%SUNNY%SINGH%')  OR UPPER(NEWS_URL) LIKE  UPPER('%NUSHRAT%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sonu'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%SONU%TITU%') OR UPPER(NEWS_URL) LIKE  UPPER('%KARTHIK%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%ARYAN%')  OR UPPER(NEWS_URL) LIKE  UPPER('%SUNNY%SINGH%')  OR UPPER(NEWS_URL) LIKE  UPPER('%NUSHRAT%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raid'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%-raid-%') OR UPPER(NEWS_URL) LIKE  UPPER('%raid-%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%-raid%')  OR UPPER(NEWS_URL) LIKE  UPPER('%devgn%')  OR UPPER(NEWS_URL) LIKE  UPPER('%ileana%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raid'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%-raid-%') OR UPPER(NEWS_URL) LIKE  UPPER('%raid-%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%-raid%')  OR UPPER(NEWS_URL) LIKE  UPPER('%devgn%')  OR UPPER(NEWS_URL) LIKE  UPPER('%ileana%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '3story'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%3%storey%') OR UPPER(NEWS_URL) LIKE  UPPER('%richa%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%aisha%')  OR UPPER(NEWS_URL) LIKE  UPPER('%tarun%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '3story'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%3%storey%') OR UPPER(NEWS_URL) LIKE  UPPER('%richa%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%aisha%')  OR UPPER(NEWS_URL) LIKE  UPPER('%tarun%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aiyaary'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%aiyaary%') OR UPPER(NEWS_URL) LIKE  UPPER('%manoj%bajpai%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%sid%malho%')  OR UPPER(NEWS_URL) LIKE  UPPER('%naseer%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'aiyaary'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%aiyaary%') OR UPPER(NEWS_URL) LIKE  UPPER('%manoj%bajpai%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%sid%malho%')  OR UPPER(NEWS_URL) LIKE  UPPER('%naseer%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hichki'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%hichki%') OR UPPER(NEWS_URL) LIKE  UPPER('%rani%muk%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%asif%')  OR UPPER(NEWS_URL) LIKE  UPPER('%supriya%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hichki'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%hichki%') OR UPPER(NEWS_URL) LIKE  UPPER('%rani%muk%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%asif%')  OR UPPER(NEWS_URL) LIKE  UPPER('%supriya%') )  
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'baaghi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%baaghi%') OR UPPER(NEWS_URL) LIKE  UPPER('%tiger%shr%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%disha%')  OR UPPER(NEWS_URL) LIKE  UPPER('%randeep%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'baaghi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%baaghi%') OR UPPER(NEWS_URL) LIKE  UPPER('%tiger%shr%') 
 OR UPPER(NEWS_URL) LIKE  UPPER('%disha%')  OR UPPER(NEWS_URL) LIKE  UPPER('%randeep%') ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yhm'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%ye%hai%moh%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'yhm'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%ye%hai%moh%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'supdancer'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%super%dance%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'supdancer'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%super%dance%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kapilsharma'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%KAPIL%SHARMA%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kapilsharma'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%KAPIL%SHARMA%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'veere'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%VEERE%WEDDING%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'veere'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%VEERE%WEDDING%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raazi'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%RAAZI%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raazi'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%RAAZI%%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '102'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%102%NOT%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     '102'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%102%NOT%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kaala'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%KAALA%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'kaala'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%KAALA%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bhavesh'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%BHAVESH%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'bhavesh'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%BHAVESH%')  )  
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'highjack'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%HIGH%JACK%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'highjack'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%HIGH%JACK%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'daasdev'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%DAAS%DEV%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'daasdev'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%DAAS%DEV%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hahm'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%HOPE%HUM%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hahm'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE  UPPER('%HOPE%HUM%')  ) 
AND COUNTRY_CODE = 'IND' AND UPPER(SCRAPE_TAG1) = 'BOLLYWOOD'     AND MOD(ROW_ID, 2) = 0 ;


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('hahm', 'H', 2) ;
CALL STP_STAG23_MICRO('hahm', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hahm', 'L', 2) ;
CALL STP_STAG23_MICRO('hahm', 'L') ;

-- CALL STP_STAG23_1KWINSERT('daasdev', 'H', 2) ;
CALL STP_STAG23_MICRO('daasdev', 'H') ;

-- CALL STP_STAG23_1KWINSERT('daasdev', 'L', 2) ;
CALL STP_STAG23_MICRO('daasdev', 'L') ;

-- CALL STP_STAG23_1KWINSERT('highjack', 'H', 2) ;
CALL STP_STAG23_MICRO('highjack', 'H') ;

-- CALL STP_STAG23_1KWINSERT('highjack', 'L', 2) ;
CALL STP_STAG23_MICRO('highjack', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bhavesh', 'H', 2) ;
CALL STP_STAG23_MICRO('bhavesh', 'H') ;

-- CALL STP_STAG23_1KWINSERT('bhavesh', 'L', 2) ;
CALL STP_STAG23_MICRO('bhavesh', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kaala', 'H', 2) ;
CALL STP_STAG23_MICRO('kaala', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kaala', 'L', 2) ;
CALL STP_STAG23_MICRO('kaala', 'L') ;

-- CALL STP_STAG23_1KWINSERT('102', 'H', 2) ;
CALL STP_STAG23_MICRO('102', 'H') ;

-- CALL STP_STAG23_1KWINSERT('102', 'L', 2) ;
CALL STP_STAG23_MICRO('102', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raazi', 'H', 2) ;
CALL STP_STAG23_MICRO('raazi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raazi', 'L', 2) ;
CALL STP_STAG23_MICRO('raazi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('veere', 'H', 2) ;
CALL STP_STAG23_MICRO('veere', 'H') ;

-- CALL STP_STAG23_1KWINSERT('veere', 'L', 2) ;
CALL STP_STAG23_MICRO('veere', 'L') ;

-- CALL STP_STAG23_1KWINSERT('kapilsharma', 'H', 2) ;
CALL STP_STAG23_MICRO('kapilsharma', 'H') ;

-- CALL STP_STAG23_1KWINSERT('kapilsharma', 'L', 2) ;
CALL STP_STAG23_MICRO('kapilsharma', 'L') ;

-- CALL STP_STAG23_1KWINSERT('supdancer', 'H', 2) ;
CALL STP_STAG23_MICRO('supdancer', 'H') ;

-- CALL STP_STAG23_1KWINSERT('supdancer', 'L', 2) ;
CALL STP_STAG23_MICRO('supdancer', 'L') ;

-- CALL STP_STAG23_1KWINSERT('yhm', 'H', 2) ;
CALL STP_STAG23_MICRO('yhm', 'H') ;

-- CALL STP_STAG23_1KWINSERT('yhm', 'L', 2) ;
CALL STP_STAG23_MICRO('yhm', 'L') ;

-- CALL STP_STAG23_1KWINSERT('baaghi', 'H', 2) ;
CALL STP_STAG23_MICRO('baaghi', 'H') ;

-- CALL STP_STAG23_1KWINSERT('baaghi', 'L', 2) ;
CALL STP_STAG23_MICRO('baaghi', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hichki', 'H', 2) ;
CALL STP_STAG23_MICRO('hichki', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hichki', 'L', 2) ;
CALL STP_STAG23_MICRO('hichki', 'L') ;

-- CALL STP_STAG23_1KWINSERT('aiyaary', 'H', 2) ;
CALL STP_STAG23_MICRO('aiyaary', 'H') ;

-- CALL STP_STAG23_1KWINSERT('aiyaary', 'L', 2) ;
CALL STP_STAG23_MICRO('aiyaary', 'L') ;

-- CALL STP_STAG23_1KWINSERT('3story', 'H', 2) ;
CALL STP_STAG23_MICRO('3story', 'H') ;

-- CALL STP_STAG23_1KWINSERT('3story', 'L', 2) ;
CALL STP_STAG23_MICRO('3story', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raid', 'H', 2) ;
CALL STP_STAG23_MICRO('raid', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raid', 'L', 2) ;
CALL STP_STAG23_MICRO('raid', 'L') ;

-- CALL STP_STAG23_1KWINSERT('sonu', 'H', 2) ;
CALL STP_STAG23_MICRO('sonu', 'H') ;

-- CALL STP_STAG23_1KWINSERT('sonu', 'L', 2) ;
CALL STP_STAG23_MICRO('sonu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pari', 'H', 2) ;
CALL STP_STAG23_MICRO('pari', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pari', 'L', 2) ;
CALL STP_STAG23_MICRO('pari', 'L') ;

-- CALL STP_STAG23_1KWINSERT('mukka', 'H', 2) ;
CALL STP_STAG23_MICRO('mukka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('mukka', 'L', 2) ;
CALL STP_STAG23_MICRO('mukka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('padmavati', 'H', 2) ;
CALL STP_STAG23_MICRO('padmavati', 'H') ;

-- CALL STP_STAG23_1KWINSERT('padmavati', 'L', 2) ;
CALL STP_STAG23_MICRO('padmavati', 'L') ;

/*  Completing the entertainmentnews5 addition with STp MICRo call  */

CALL STP_STAG23_MICRO('entertainmentnews5', 'H') ;

CALL STP_STAG23_MICRO('entertainmentnews5', 'L') ;

/*  END OF Completing the entertainmentnews5 addition with STp MICRo call  */


/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, ENT/CELEB should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'Y' ;


INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('ENT', 'CELEB') AND COUNTRY_CODE = 'IND' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T10IND', 'CELEB', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T5IND', 'ENT', 'IND', POSTCOUNT, UNTAGCOUNT, NOW()) ;

  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T5USA //
CREATE PROCEDURE STP_GRAND_T5USA()
THISPROC: BEGIN

/* 
	07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE
    
    09/19/2020 AST: Adding the tagging of 25 untagged scrapes to entertainmentnews5 KW
    10/04/2020 AST: adding filter to XYZNEWS to avoid: old news, stock market update, SHOPPING ADS ETC.
    10/10/2020 AST: removed the above - as a new proc was created for this purpose

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAENT', SCRAPE_TAG2 = 'USAENT', SCRAPE_TAG3 = 'USAENT'  
WHERE COUNTRY_CODE = 'USA' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'ENT') AND MOVED_TO_POST_FLAG = 'N' 
AND SCRAPE_TOPIC IN ('ENT', 'CELEB');
  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blackpanther', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%PANTHER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blackpanther', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%PANTHER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gamenight', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%NIGHT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gamenight', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%NIGHT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'redsparrow', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%RED%SPARROW%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'redsparrow', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%RED%SPARROW%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'annihilation', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ANNIHIL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'annihilation', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ANNIHIL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'peterrabbit', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%PETER%RABBIT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'peterrabbit', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%PETER%RABBIT%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jumanji', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JUMANJI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jumanji', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JUMANJI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'everyday', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVERY%DAY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'everyday', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVERY%DAY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tgshowman', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GREAT%SHOWMAN%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tgshowman', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GREAT%SHOWMAN%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deathwish', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DEATH%WISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'deathwish', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DEATH%WISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '50freed', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%SHADES%FREED%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '50freed', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%SHADES%FREED%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'darkest', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DARKEST%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'darkest', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%DARKEST%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tonya', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TONYA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tonya', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TONYA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tombraider', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TOMB%RAIDER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tombraider', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%TOMB%RAIDER%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'entebbe', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ENTEBBE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'entebbe', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ENTEBBE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'journey', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JOURNEY%END%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'journey', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JOURNEY%END%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jjones', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JESS%JONES%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jjones', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%JESS%JONES%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'counterpart', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%COUNTERPART%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'counterpart', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%COUNTERPART%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '7sec', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%7%SEC%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = '7sec', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%7%SEC%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altcarbon', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ALTER%CARBON%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'altcarbon', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ALTER%CARBON%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'atlanta', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ATLANTA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'atlanta', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%ATLANTA%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'homeland', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%HOMELAND%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'homeland', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%HOMELAND%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gothrones', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%THRONE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'gothrones', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GAME%THRONE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blightning', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%LIGHT%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'blightning', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%BLACK%LIGHT%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'chi', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%THE%CHI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'chi', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%THE%CHI%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'versace', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CRIME%STORY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'versace', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CRIME%STORY%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'endofworld', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%END%WORLD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'endofworld', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%END%WORLD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'corporate', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CORPORATE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'corporate', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%CORPORATE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'goodgirls', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GOOD%GIRL%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'goodgirls', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GOOD%GIRL%%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'grownish', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GROWN%ISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'grownish', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%GROWN%ISH%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'willgrace', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%WILL%GRACE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'willgrace', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%WILL%GRACE%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'idol', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%AMERI%IDOL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'idol', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE 'AMERI%IDOL%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'evildead', SCRAPE_TAG3 = 'L' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVIL%DEAD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'evildead', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' AND UPPER(NEWS_URL) 
LIKE '%EVIL%DEAD%' AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB')
AND COUNTRY_CODE = 'USA' AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'dp2', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%DEADPOOL%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'dp2', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%DEADPOOL%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'infiwar', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%AVENGERS%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'infiwar', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND UPPER(NEWS_URL) LIKE '%AVENGERS%' 
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'quiet', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%QUIET%PLACE%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'quiet', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%QUIET%PLACE%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oboard', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%OVERBOARD%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'oboard', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%OVERBOARD%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bookclub', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%BOOK%CLUB%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'  ORDER BY RAND() LIMIT 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bookclub', SCRAPE_TAG3 = 'H' WHERE  MOVED_TO_POST_FLAG = 'N' 
AND ( UPPER(NEWS_URL) LIKE '%BOOK%CLUB%'  )
AND UPPER(SCRAPE_TAG1) IN ('USAENT', 'CELEB', 'USACELEB') AND UPPER(SCRAPE_TAG2) IN ('USAENT', 'CELEB', 'USACELEB')
AND COUNTRY_CODE = 'USA'   ;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG1_1KW(5, 'USAENT', 'USA') ;

-- CALL STP_STAG23_1KWINSERT('bookclub','L',1) ;
CALL STP_STAG23_MICRO('bookclub','L') ;
-- CALL STP_STAG23_1KWINSERT('bookclub','H',1) ;
CALL STP_STAG23_MICRO('bookclub','H') ;

-- CALL STP_STAG23_1KWINSERT('oboard','L',1) ;
CALL STP_STAG23_MICRO('oboard','L') ;
-- CALL STP_STAG23_1KWINSERT('oboard','H',1) ;
CALL STP_STAG23_MICRO('oboard','H') ;

-- CALL STP_STAG23_1KWINSERT('quiet','L',1) ;
CALL STP_STAG23_MICRO('quiet','L') ;
-- CALL STP_STAG23_1KWINSERT('quiet','H',1) ;
CALL STP_STAG23_MICRO('quiet','H') ;

-- CALL STP_STAG23_1KWINSERT('infiwar','L',1) ;
CALL STP_STAG23_MICRO('infiwar','L') ;
-- CALL STP_STAG23_1KWINSERT('infiwar','H',1) ;
CALL STP_STAG23_MICRO('infiwar','H') ;

-- CALL STP_STAG23_1KWINSERT('dp2','L',1) ;
CALL STP_STAG23_MICRO('dp2','L') ;
-- CALL STP_STAG23_1KWINSERT('dp2','H',1) ;
CALL STP_STAG23_MICRO('dp2','H') ;

-- CALL STP_STAG23_1KWINSERT('blackpanther','L',1) ;
CALL STP_STAG23_MICRO('blackpanther','L') ;
-- CALL STP_STAG23_1KWINSERT('blackpanther','H',1) ;
CALL STP_STAG23_MICRO('blackpanther','H') ;
-- CALL STP_STAG23_1KWINSERT('gamenight','L',1) ;
CALL STP_STAG23_MICRO('gamenight','L') ;
-- CALL STP_STAG23_1KWINSERT('gamenight','H',1) ;
CALL STP_STAG23_MICRO('gamenight','H') ;
-- CALL STP_STAG23_1KWINSERT('redsparrow','L',1) ;
CALL STP_STAG23_MICRO('redsparrow','L') ;
-- CALL STP_STAG23_1KWINSERT('redsparrow','H',1) ;
CALL STP_STAG23_MICRO('redsparrow','H') ;
-- CALL STP_STAG23_1KWINSERT('annihilation','L',1) ;
CALL STP_STAG23_MICRO('annihilation','L') ;
-- CALL STP_STAG23_1KWINSERT('annihilation','H',1) ;
CALL STP_STAG23_MICRO('annihilation','H') ;
-- CALL STP_STAG23_1KWINSERT('peterrabbit','L',1) ;
CALL STP_STAG23_MICRO('peterrabbit','L') ;
-- CALL STP_STAG23_1KWINSERT('peterrabbit','H',1) ;
CALL STP_STAG23_MICRO('peterrabbit','H') ;
-- CALL STP_STAG23_1KWINSERT('jumanji','L',1) ;
CALL STP_STAG23_MICRO('jumanji','L') ;
-- CALL STP_STAG23_1KWINSERT('jumanji','H',1) ;
CALL STP_STAG23_MICRO('jumanji','H') ;
-- CALL STP_STAG23_1KWINSERT('everyday','L',1) ;
CALL STP_STAG23_MICRO('everyday','L') ;
-- CALL STP_STAG23_1KWINSERT('everyday','H',1) ;
CALL STP_STAG23_MICRO('everyday','H') ;
-- CALL STP_STAG23_1KWINSERT('tgshowman','L',1) ;
CALL STP_STAG23_MICRO('tgshowman','L') ;
-- CALL STP_STAG23_1KWINSERT('tgshowman','H',1) ;
CALL STP_STAG23_MICRO('tgshowman','H') ;
-- CALL STP_STAG23_1KWINSERT('deathwish','L',1) ;
CALL STP_STAG23_MICRO('deathwish','L') ;
-- CALL STP_STAG23_1KWINSERT('deathwish','H',1) ;
CALL STP_STAG23_MICRO('deathwish','H') ;
-- CALL STP_STAG23_1KWINSERT('50freed','L',1) ;
CALL STP_STAG23_MICRO('50freed','L') ;
-- CALL STP_STAG23_1KWINSERT('50freed','H',1) ;
CALL STP_STAG23_MICRO('50freed','H') ;
-- CALL STP_STAG23_1KWINSERT('darkest','L',1) ;
CALL STP_STAG23_MICRO('darkest','L') ;
-- CALL STP_STAG23_1KWINSERT('darkest','H',1) ;
CALL STP_STAG23_MICRO('darkest','H') ;
-- CALL STP_STAG23_1KWINSERT('tonya','L',1) ;
CALL STP_STAG23_MICRO('tonya','L') ;
-- CALL STP_STAG23_1KWINSERT('tonya','H',1) ;
CALL STP_STAG23_MICRO('tonya','H') ;
-- CALL STP_STAG23_1KWINSERT('tombraider','L',1) ;
CALL STP_STAG23_MICRO('tombraider','L') ;
-- CALL STP_STAG23_1KWINSERT('tombraider','H',1) ;
CALL STP_STAG23_MICRO('tombraider','H') ;
-- CALL STP_STAG23_1KWINSERT('entebbe','L',1) ;
CALL STP_STAG23_MICRO('entebbe','L') ;
-- CALL STP_STAG23_1KWINSERT('entebbe','H',1) ;
CALL STP_STAG23_MICRO('entebbe','H') ;
-- CALL STP_STAG23_1KWINSERT('journey','L',1) ;
CALL STP_STAG23_MICRO('journey','L') ;
-- CALL STP_STAG23_1KWINSERT('journey','H',1) ;
CALL STP_STAG23_MICRO('journey','H') ;
-- CALL STP_STAG23_1KWINSERT('jjones','L',1) ;
CALL STP_STAG23_MICRO('jjones','L') ;
-- CALL STP_STAG23_1KWINSERT('jjones','H',1) ;
CALL STP_STAG23_MICRO('jjones','H') ;
-- CALL STP_STAG23_1KWINSERT('counterpart','L',1) ;
CALL STP_STAG23_MICRO('counterpart','L') ;
-- CALL STP_STAG23_1KWINSERT('counterpart','H',1) ;
CALL STP_STAG23_MICRO('counterpart','H') ;
-- CALL STP_STAG23_1KWINSERT('7sec','L',1) ;
CALL STP_STAG23_MICRO('7sec','L') ;
-- CALL STP_STAG23_1KWINSERT('7sec','H',1) ;
CALL STP_STAG23_MICRO('7sec','H') ;
-- CALL STP_STAG23_1KWINSERT('altcarbon','L',1) ;
CALL STP_STAG23_MICRO('altcarbon','L') ;
-- CALL STP_STAG23_1KWINSERT('altcarbon','H',1) ;
CALL STP_STAG23_MICRO('altcarbon','H') ;
-- CALL STP_STAG23_1KWINSERT('atlanta','L',1) ;
CALL STP_STAG23_MICRO('atlanta','L') ;
-- CALL STP_STAG23_1KWINSERT('atlanta','H',1) ;
CALL STP_STAG23_MICRO('atlanta','H') ;
-- CALL STP_STAG23_1KWINSERT('homeland','L',1) ;
CALL STP_STAG23_MICRO('homeland','L') ;
-- CALL STP_STAG23_1KWINSERT('homeland','H',1) ;
CALL STP_STAG23_MICRO('homeland','H') ;
-- CALL STP_STAG23_1KWINSERT('gothrones','L',1) ;
CALL STP_STAG23_MICRO('gothrones','L') ;
-- CALL STP_STAG23_1KWINSERT('gothrones','H',1) ;
CALL STP_STAG23_MICRO('gothrones','H') ;
-- CALL STP_STAG23_1KWINSERT('walkdead','L',1) ;
CALL STP_STAG23_MICRO('walkdead','L') ;
-- CALL STP_STAG23_1KWINSERT('walkdead','H',1) ;
CALL STP_STAG23_MICRO('walkdead','H') ;
-- CALL STP_STAG23_1KWINSERT('blightning','L',1) ;
CALL STP_STAG23_MICRO('blightning','L') ;
-- CALL STP_STAG23_1KWINSERT('blightning','H',1) ;
CALL STP_STAG23_MICRO('blightning','H') ;
-- CALL STP_STAG23_1KWINSERT('chi','L',1) ;
CALL STP_STAG23_MICRO('chi','L') ;
-- CALL STP_STAG23_1KWINSERT('chi','H',1) ;
CALL STP_STAG23_MICRO('chi','H') ;
-- CALL STP_STAG23_1KWINSERT('sneaky','L',1) ;
CALL STP_STAG23_MICRO('sneaky','L') ;
-- CALL STP_STAG23_1KWINSERT('sneaky','H',1) ;
CALL STP_STAG23_MICRO('sneaky','H') ;
-- CALL STP_STAG23_1KWINSERT('versace','L',1) ;
CALL STP_STAG23_MICRO('versace','L') ;
-- CALL STP_STAG23_1KWINSERT('versace','H',1) ;
CALL STP_STAG23_MICRO('versace','H') ;
-- CALL STP_STAG23_1KWINSERT('endofworld','L',1) ;
CALL STP_STAG23_MICRO('endofworld','L') ;
-- CALL STP_STAG23_1KWINSERT('endofworld','H',1) ;
CALL STP_STAG23_MICRO('endofworld','H') ;
-- CALL STP_STAG23_1KWINSERT('corporate','L',1) ;
CALL STP_STAG23_MICRO('corporate','L') ;
-- CALL STP_STAG23_1KWINSERT('corporate','H',1) ;
CALL STP_STAG23_MICRO('corporate','H') ;
-- CALL STP_STAG23_1KWINSERT('queer','L',1) ;
CALL STP_STAG23_MICRO('queer','L') ;
-- CALL STP_STAG23_1KWINSERT('queer','H',1) ;
CALL STP_STAG23_MICRO('queer','H') ;
-- CALL STP_STAG23_1KWINSERT('goodgirls','L',1) ;
CALL STP_STAG23_MICRO('goodgirls','L') ;
-- CALL STP_STAG23_1KWINSERT('goodgirls','H',1) ;
CALL STP_STAG23_MICRO('goodgirls','H') ;
-- CALL STP_STAG23_1KWINSERT('grownish','L',1) ;
CALL STP_STAG23_MICRO('grownish','L') ;
-- CALL STP_STAG23_1KWINSERT('grownish','H',1) ;
CALL STP_STAG23_MICRO('grownish','H') ;
-- CALL STP_STAG23_1KWINSERT('willgrace','L',1) ;
CALL STP_STAG23_MICRO('willgrace','L') ;
-- CALL STP_STAG23_1KWINSERT('willgrace','H',1) ;
CALL STP_STAG23_MICRO('willgrace','H') ;
-- CALL STP_STAG23_1KWINSERT('idol','L',1) ;
CALL STP_STAG23_MICRO('idol','L') ;
-- CALL STP_STAG23_1KWINSERT('idol','H',1) ;
CALL STP_STAG23_MICRO('idol','H') ;
-- CALL STP_STAG23_1KWINSERT('evildead','L',1) ;
CALL STP_STAG23_MICRO('evildead','L') ;
-- CALL STP_STAG23_1KWINSERT('evildead','H',1) ;
CALL STP_STAG23_MICRO('evildead','H') ;

/*  Completing the entertainmentnews5 addition with STp MICRo call  */

CALL STP_STAG23_MICRO('entertainmentnews5', 'H') ;

CALL STP_STAG23_MICRO('entertainmentnews5', 'L') ;

/*  END OF Completing the entertainmentnews5 addition with STp MICRo call  */

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' ;

SET POSTCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO WSR_UNTAGGED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;

SET UNTAGCOUNT = (SELECT COUNT(*) FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N') ;

DELETE FROM WEB_SCRAPE_RAW
WHERE SCRAPE_TOPIC IN ('CELEB', 'ENT') AND COUNTRY_CODE = 'USA' AND MOVED_TO_POST_FLAG = 'N' ;  

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_T5USA', 'ENT', 'USA', POSTCOUNT, UNTAGCOUNT, NOW()) ;

/* End of STP logging */




  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T9IND //
CREATE PROCEDURE STP_GRAND_T9IND()
THISPROC: BEGIN

/* 

07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE

*/
  
-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hpguj'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HIMACHAL%'     
OR UPPER(NEWS_URL) LIKE     '%GUJARAT%' OR UPPER(NEWS_URL) LIKE     '%BJP%WIN%') AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'hpguj'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%HIMACHAL%'     
OR UPPER(NEWS_URL) LIKE     '%GUJARAT%' OR UPPER(NEWS_URL) LIKE     '%BJP%WIN%') AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'        AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawarmh'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PAWAR%'     
OR UPPER(NEWS_URL) LIKE     '%RASHTRAVADI%' OR UPPER(NEWS_URL) LIKE     '%RCP%') AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'       AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pawarmh'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PAWAR%'     
OR UPPER(NEWS_URL) LIKE     '%RASHTRAVADI%' OR UPPER(NEWS_URL) LIKE     '%RCP%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'judges'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JUDGES%'     
OR UPPER(NEWS_URL) LIKE     '%SUPREME%COURT%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'judges'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JUDGES%'     
OR UPPER(NEWS_URL) LIKE     '%SUPREME%COURT%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'budget'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BUDGET%'     
OR UPPER(NEWS_URL) LIKE     '%JAITLEY%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'budget'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%BUDGET%'     
OR UPPER(NEWS_URL) LIKE     '%JAITLEY%' )   AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'naidu'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%V%NAIDU%'     
OR UPPER(NEWS_URL) LIKE     '%VICE%PRESI%' OR UPPER(NEWS_URL) LIKE     '%VP%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'naidu'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%V%NAIDU%'     
OR UPPER(NEWS_URL) LIKE     '%VICE%PRESI%' OR UPPER(NEWS_URL) LIKE     '%VP%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padmaa'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PADMAAVAT%'     
OR UPPER(NEWS_URL) LIKE     '%KARNI%SENA%' OR UPPER(NEWS_URL) LIKE     '%PADMA%VAT%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'padmaa'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PADMAAVAT%'     
OR UPPER(NEWS_URL) LIKE     '%KARNI%SENA%' OR UPPER(NEWS_URL) LIKE     '%PADMA%VAT%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raph'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RAFAEL%'     
OR UPPER(NEWS_URL) LIKE     '%CORRUPTION%DEAL%' OR UPPER(NEWS_URL) LIKE     '%RAFALE%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'raph'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%RAFAEL%'     
OR UPPER(NEWS_URL) LIKE     '%CORRUPTION%DEAL%' OR UPPER(NEWS_URL) LIKE     '%RAFALE%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tiger'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TIGER%'     
OR UPPER(NEWS_URL) LIKE     '%ZINDA%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'BOLLYWOOD'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'tiger'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%TIGER%'     
OR UPPER(NEWS_URL) LIKE     '%ZINDA%' )  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'BOLLYWOOD'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pad'    , SCRAPE_TAG3 = 'L'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PAD-MAN-%'     
OR UPPER(NEWS_URL) LIKE     '%-PAD-MAN%' OR UPPER(NEWS_URL) LIKE     '%PAD%MAN%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'BOLLYWOOD'      AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'pad'    , SCRAPE_TAG3 = 'H'     WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%PAD-MAN-%'     
OR UPPER(NEWS_URL) LIKE     '%-PAD-MAN%' OR UPPER(NEWS_URL) LIKE     '%PAD%MAN%')  AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'BOLLYWOOD'      AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amujinnah'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JINNA%'     
OR UPPER(NEWS_URL) LIKE     '%-AMU%' OR UPPER(NEWS_URL) LIKE     '%ALIGARH%'
OR UPPER(NEWS_URL) LIKE     '%AMU-%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'amujinnah'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%JINNA%'     
OR UPPER(NEWS_URL) LIKE     '%-AMU%' OR UPPER(NEWS_URL) LIKE     '%ALIGARH%'
OR UPPER(NEWS_URL) LIKE     '%AMU-%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'impeachcji'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CJI%'     
OR UPPER(NEWS_URL) LIKE     '%IMPEACH%' OR UPPER(NEWS_URL) LIKE     '%DIPAK%MIS%%'
OR UPPER(NEWS_URL) LIKE     '%SUPRE%COURT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'impeachcji'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%CJI%'     
OR UPPER(NEWS_URL) LIKE     '%IMPEACH%' OR UPPER(NEWS_URL) LIKE     '%DIPAK%MIS%%'
OR UPPER(NEWS_URL) LIKE     '%SUPRE%COURT%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'karnataka'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KARNAT%'     
OR UPPER(NEWS_URL) LIKE     '%ASSEMBLY%' OR UPPER(NEWS_URL) LIKE     '%ELECTION%'
OR UPPER(NEWS_URL) LIKE     '%SIDDARA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'karnataka'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KARNAT%'     
OR UPPER(NEWS_URL) LIKE     '%ASSEMBLY%' OR UPPER(NEWS_URL) LIKE     '%ELECTION%'
OR UPPER(NEWS_URL) LIKE     '%SIDDARA%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rapecult'    , SCRAPE_TAG3 = 'L'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATHUA%'     
OR UPPER(NEWS_URL) LIKE     '%UNNAO%' OR UPPER(NEWS_URL) LIKE     '%RAPE%'
OR UPPER(NEWS_URL) LIKE     '%CULTU%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 1 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'rapecult'    , SCRAPE_TAG3 = 'H'     
WHERE  MOVED_TO_POST_FLAG = 'N' AND (UPPER(NEWS_URL) LIKE     '%KATHUA%'     
OR UPPER(NEWS_URL) LIKE     '%UNNAO%' OR UPPER(NEWS_URL) LIKE     '%RAPE%'
OR UPPER(NEWS_URL) LIKE     '%CULTU%' ) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TAG1 = 'POLITICS'     AND MOD(ROW_ID, 2) = 0 ;

--
/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */
--

-- CALL STP_STAG23_1KWINSERT('rapecult', 'H', 2) ;
CALL STP_STAG23_MICRO('rapecult', 'H') ;

-- CALL STP_STAG23_1KWINSERT('rapecult', 'L', 3) ;
CALL STP_STAG23_MICRO('rapecult', 'L') ;

-- CALL STP_STAG23_1KWINSERT('karnataka', 'H', 2) ;
CALL STP_STAG23_MICRO('karnataka', 'H') ;

-- CALL STP_STAG23_1KWINSERT('karnataka', 'L', 3) ;
CALL STP_STAG23_MICRO('karnataka', 'L') ;

-- CALL STP_STAG23_1KWINSERT('impeachcji', 'H', 2) ;
CALL STP_STAG23_MICRO('impeachcji', 'H') ;

-- CALL STP_STAG23_1KWINSERT('impeachcji', 'L', 3) ;
CALL STP_STAG23_MICRO('impeachcji', 'L') ;


-- CALL STP_STAG23_1KWINSERT('amujinnah', 'H', 2) ;
CALL STP_STAG23_MICRO('amujinnah', 'H') ;

-- CALL STP_STAG23_1KWINSERT('amujinnah', 'L', 3) ;
CALL STP_STAG23_MICRO('amujinnah', 'L') ;

-- CALL STP_STAG23_1KWINSERT('hpguj', 'H', 2) ;
CALL STP_STAG23_MICRO('hpguj', 'H') ;

-- CALL STP_STAG23_1KWINSERT('hpguj', 'L', 3) ;
CALL STP_STAG23_MICRO('hpguj', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pawar', 'H', 2) ;
CALL STP_STAG23_MICRO('pawar', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pawar', 'L', 1) ;
CALL STP_STAG23_MICRO('pawar', 'L') ;

-- CALL STP_STAG23_1KWINSERT('judges', 'H', 3) ;
CALL STP_STAG23_MICRO('judges', 'H') ;

-- CALL STP_STAG23_1KWINSERT('judges', 'L', 3) ;
CALL STP_STAG23_MICRO('judges', 'L') ;

-- CALL STP_STAG23_1KWINSERT('budget', 'H', 3) ;
CALL STP_STAG23_MICRO('budget', 'H') ;

-- CALL STP_STAG23_1KWINSERT('budget', 'L', 3) ;
CALL STP_STAG23_MICRO('budget', 'L') ;

-- CALL STP_STAG23_1KWINSERT('naidu', 'H', 3) ;
CALL STP_STAG23_MICRO('naidu', 'H') ;

-- CALL STP_STAG23_1KWINSERT('naidu', 'L', 3) ;
CALL STP_STAG23_MICRO('naidu', 'L') ;

-- CALL STP_STAG23_1KWINSERT('padmaa', 'H', 3) ;
CALL STP_STAG23_MICRO('padmaa', 'H') ;

-- CALL STP_STAG23_1KWINSERT('padmaa', 'L', 3) ;
CALL STP_STAG23_MICRO('padmaa', 'L') ;

-- CALL STP_STAG23_1KWINSERT('raph', 'H', 3) ;
CALL STP_STAG23_MICRO('raph', 'H') ;

-- CALL STP_STAG23_1KWINSERT('raph', 'L', 3) ;
CALL STP_STAG23_MICRO('raph', 'L') ;

-- CALL STP_STAG23_1KWINSERT('tiger', 'H', 3) ;
CALL STP_STAG23_MICRO('tiger', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tiger', 'L', 3) ;
CALL STP_STAG23_MICRO('tiger', 'L') ;

-- CALL STP_STAG23_1KWINSERT('pad', 'H', 1) ;
CALL STP_STAG23_MICRO('pad', 'H') ;

-- CALL STP_STAG23_1KWINSERT('pad', 'L', 1) ;
CALL STP_STAG23_MICRO('pad', 'L') ;


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_T9USA //
CREATE PROCEDURE STP_GRAND_T9USA()
THISPROC: BEGIN

/* 
06/12/2018 Added bakergay, trumppardon, swimsuit
07/19/2020 AST: ADDED TAG_DONE_FLAG = 'Y' AFTER UPDATE


*/

-- PRIOR TO THIS, THE WEB_SCRAPE_RAW MUST BE DEDUPED
  
UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'qtrump', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MUELLER%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') -- AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;
-- CALL STP_STAG23_1KWINSERT('qtrump', 'L', 3) ;
CALL STP_STAG23_MICRO('qtrump', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'qtrump', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MUELLER%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') -- AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;
-- CALL STP_STAG23_1KWINSERT('qtrump', 'H', 5) ;
CALL STP_STAG23_MICRO('qtrump', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumpimmi', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%IMMI%' OR UPPER(NEWS_URL) LIKE '%IMMI%PLAN%' OR UPPER(NEWS_URL) LIKE '%DACA%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumpimmi', 'H', 5) ;
CALL STP_STAG23_MICRO('trumpimmi', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumpimmi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%IMMI%' OR UPPER(NEWS_URL) LIKE '%IMMI%PLAN%' OR UPPER(NEWS_URL) LIKE '%DACA%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumpimmi', 'L', 3) ;
CALL STP_STAG23_MICRO('trumpimmi', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumptax', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%TAX%' OR UPPER(NEWS_URL) LIKE '%GOP%TAX%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumptax', 'H', 5) ;
CALL STP_STAG23_MICRO('trumptax', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumptax', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%TAX%' OR UPPER(NEWS_URL) LIKE '%GOP%TAX%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumptax', 'L', 3) ;
CALL STP_STAG23_MICRO('trumptax', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumponfbi', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%FBI%' OR UPPER(NEWS_URL) LIKE '%FBI%TRUMP%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumponfbi', 'H', 5) ;
CALL STP_STAG23_MICRO('trumponfbi', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumponfbi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%FBI%' OR UPPER(NEWS_URL) LIKE '%FBI%TRUMP%')  -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumponfbi', 'L', 3) ;
CALL STP_STAG23_MICRO('trumponfbi', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumputah', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%UTAH%' OR UPPER(NEWS_URL) LIKE '%TRUMP%MONUM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumputah', 'H', 5) ;
CALL STP_STAG23_MICRO('trumputah', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumputah', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%UTAH%' OR UPPER(NEWS_URL) LIKE '%TRUMP%MONUM%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('trumputah', 'L', 3) ;
CALL STP_STAG23_MICRO('trumputah', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'h1b', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%H1B%' OR UPPER(NEWS_URL) LIKE '%H1B%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('h1b', 'H', 5) ;
CALL STP_STAG23_MICRO('h1b', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'h1b', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%H1B%' OR UPPER(NEWS_URL) LIKE '%H1B%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('h1b', 'L', 3) ;
CALL STP_STAG23_MICRO('h1b', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'shithole', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%SHIT%' OR UPPER(NEWS_URL) LIKE '%TRUMP%AFRICA%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('shithole', 'H', 5) ;
CALL STP_STAG23_MICRO('shithole', 'H') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'shithole', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%SHIT%' OR UPPER(NEWS_URL) LIKE '%TRUMP%AFRICA%') -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('shithole', 'L', 3) ;
CALL STP_STAG23_MICRO('shithole', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'superbowl', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'NFL'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%SUPER%BOWL%' OR UPPER(NEWS_URL) LIKE '%LII%' ) -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('superbowl', 'L', 5) ;
CALL STP_STAG23_MICRO('superbowl', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'grammy', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'CELEB'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%GRAMM%' OR UPPER(NEWS_URL) LIKE '%AWARD%2018%' ) -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('grammy', 'L', 5) ;
CALL STP_STAG23_MICRO('grammy', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'jedi', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'CELEB'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%STAR%WAR%' OR UPPER(NEWS_URL) LIKE '%LAST%JEDI%' ) -- AND UPPER(NEWS_URL) NOT LIKE '%TRUMP%' 
;
-- CALL STP_STAG23_1KWINSERT('jedi', 'L', 5) ;
CALL STP_STAG23_MICRO('jedi', 'L') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'parkland', SCRAPE_TAG3 = 'L'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%CNN%' OR SCRAPE_SOURCE LIKE '%YAHOO%')
AND (UPPER(NEWS_URL) LIKE '%PARKLAND%' OR UPPER(NEWS_URL) LIKE '%STONEMAN%' OR UPPER(NEWS_URL) LIKE '%SCHOOL%SHOOT%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'parkland', SCRAPE_TAG3 = 'H'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%RCP%' OR SCRAPE_SOURCE LIKE '%FOX%')
AND (UPPER(NEWS_URL) LIKE '%PARKLAND%' OR UPPER(NEWS_URL) LIKE '%STONEMAN%' OR UPPER(NEWS_URL) LIKE '%SCHOOL%SHOOT%' ) ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'teachers', SCRAPE_TAG3 = 'L'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%CNN%' OR SCRAPE_SOURCE LIKE '%YAHOO%')
AND (UPPER(NEWS_URL) LIKE '%TEACHER%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'teachers', SCRAPE_TAG3 = 'H'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%RCP%' OR SCRAPE_SOURCE LIKE '%FOX%')
AND (UPPER(NEWS_URL) LIKE '%TEACHER%' ) ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'cambridge', SCRAPE_TAG3 = 'L'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%CNN%' OR SCRAPE_SOURCE LIKE '%YAHOO%')
AND (UPPER(NEWS_URL) LIKE '%CAMBRIDGE%' OR UPPER(NEWS_URL) LIKE '%FACEBOOK%' OR UPPER(NEWS_URL) LIKE '%ZUCKERB%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'cambridge', SCRAPE_TAG3 = 'H'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%RCP%' OR SCRAPE_SOURCE LIKE '%FOX%')
AND (UPPER(NEWS_URL) LIKE '%CAMBRIDGE%' OR UPPER(NEWS_URL) LIKE '%FACEBOOK%' OR UPPER(NEWS_URL) LIKE '%ZUCKERB%' ) ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'syria', SCRAPE_TAG3 = 'H'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%CNN%' OR SCRAPE_SOURCE LIKE '%YAHOO%')
AND (UPPER(NEWS_URL) LIKE '%TRUMP%SYRIA%' OR UPPER(NEWS_URL) LIKE '%ASSAD%' OR UPPER(NEWS_URL) LIKE '%SYRIA%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'syria', SCRAPE_TAG3 = 'L'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%RCP%' OR SCRAPE_SOURCE LIKE '%FOX%')
AND (UPPER(NEWS_URL) LIKE '%TRUMP%SYRIA%' OR UPPER(NEWS_URL) LIKE '%ASSAD%' OR UPPER(NEWS_URL) LIKE '%SYRIA%' ) ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tfirem', SCRAPE_TAG3 = 'H'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%CNN%' OR SCRAPE_SOURCE LIKE '%YAHOO%')
AND (UPPER(NEWS_URL) LIKE '%TRUMP%MUELLER%' OR UPPER(NEWS_URL) LIKE '%MUELLER%TRUMP%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'tfirem', SCRAPE_TAG3 = 'L'  WHERE COUNTRY_CODE = 'USA'  AND MOVED_TO_POST_FLAG = 'N'
AND ( SCRAPE_SOURCE LIKE '%RCP%' OR SCRAPE_SOURCE LIKE '%FOX%')
AND (UPPER(NEWS_URL) LIKE '%TRUMP%MUELLER%' OR UPPER(NEWS_URL) LIKE '%MUELLER%TRUMP%' OR UPPER(NEWS_URL) LIKE '%SPECIAL%COUNSEL%') ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bakergay', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BAKER%' OR UPPER(NEWS_URL) LIKE '%WEDDING%CAKE%'
OR UPPER(NEWS_URL) LIKE '%JACK%PHILLIP%' OR UPPER(NEWS_URL) LIKE '%COLORADO%GAY%') -- AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'bakergay', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%BAKER%' OR UPPER(NEWS_URL) LIKE '%WEDDING%CAKE%'
OR UPPER(NEWS_URL) LIKE '%JACK%PHILLIP%' OR UPPER(NEWS_URL) LIKE '%COLORADO%GAY%') -- AND UPPER(NEWS_URL) NOT LIKE '%BUFFET%' 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumppardon', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%PARDON%' OR UPPER(NEWS_URL) LIKE '%PARDON%TRUMP%' )
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'trumppardon', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%TRUMP%PARDON%' OR UPPER(NEWS_URL) LIKE '%PARDON%TRUMP%' ) 
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'swimsuit', SCRAPE_TAG3 = 'L'  WHERE SCRAPE_TAG1 = 'USAPOLLW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MISS%AMERICA%' OR UPPER(NEWS_URL) LIKE '%BEAUTY%PAGEANT%' OR UPPER(NEWS_URL) LIKE '%SCRAP%SWIMSUIT%')
;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 = 'swimsuit', SCRAPE_TAG3 = 'H'  WHERE SCRAPE_TAG1 = 'USAPOLRW'  AND MOVED_TO_POST_FLAG = 'N'
AND (UPPER(NEWS_URL) LIKE '%MISS%AMERICA%' OR UPPER(NEWS_URL) LIKE '%BEAUTY%PAGEANT%' OR UPPER(NEWS_URL) LIKE '%SCRAP%SWIMSUIT%')
;

/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

-- CALL STP_STAG23_1KWINSERT('swimsuit', 'L', 3) ;
CALL STP_STAG23_MICRO('swimsuit', 'L') ;

-- CALL STP_STAG23_1KWINSERT('swimsuit', 'H', 5) ;
CALL STP_STAG23_MICRO('swimsuit', 'H') ;

-- CALL STP_STAG23_1KWINSERT('trumppardon', 'L', 3) ;
CALL STP_STAG23_MICRO('trumppardon', 'L') ;

-- CALL STP_STAG23_1KWINSERT('trumppardon', 'H', 5) ;
CALL STP_STAG23_MICRO('trumppardon', 'H') ;

-- CALL STP_STAG23_1KWINSERT('parkland', 'H', 5) ;
CALL STP_STAG23_MICRO('parkland', 'H') ;

-- CALL STP_STAG23_1KWINSERT('parkland', 'L', 5) ;
CALL STP_STAG23_MICRO('parkland', 'L') ;

-- CALL STP_STAG23_1KWINSERT('teachers', 'H', 5) ;
CALL STP_STAG23_MICRO('teachers', 'H') ;

-- CALL STP_STAG23_1KWINSERT('teachers', 'L', 5) ;
CALL STP_STAG23_MICRO('teachers', 'L') ;

-- CALL STP_STAG23_1KWINSERT('cambridge', 'H', 5) ;
CALL STP_STAG23_MICRO('cambridge', 'H') ;

-- CALL STP_STAG23_1KWINSERT('cambridge', 'L', 5) ;
CALL STP_STAG23_MICRO('cambridge', 'L') ;

-- CALL STP_STAG23_1KWINSERT('syria', 'H', 5) ;
CALL STP_STAG23_MICRO('syria', 'H') ;

-- CALL STP_STAG23_1KWINSERT('syria', 'L', 5) ;
CALL STP_STAG23_MICRO('syria', 'L') ;
	
-- CALL STP_STAG23_1KWINSERT('tfirem', 'H', 5) ;
CALL STP_STAG23_MICRO('tfirem', 'H') ;

-- CALL STP_STAG23_1KWINSERT('tfirem', 'L', 5) ;
CALL STP_STAG23_MICRO('tfirem', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bakergay', 'L', 3) ;
CALL STP_STAG23_MICRO('bakergay', 'L') ;

-- CALL STP_STAG23_1KWINSERT('bakergay', 'H', 5) ;
CALL STP_STAG23_MICRO('bakergay', 'H') ;


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_USA //
CREATE PROCEDURE STP_GRAND_USA()
THISPROC: BEGIN

/* 
08/24/2018 AST: changed the order to do all the USA dedupes first - otherwise we were getting tons of dupes due to mismatch of the topic order
*/

SET SQL_SAFE_UPDATES = 0;

/*UPDATE WEB_SCRAPE_RAW SET NEWS_URL = CONCAT('https://www.eonline.com', NEWS_URL) 
WHERE NEWS_URL LIKE '/%' AND SCRAPE_SOURCE = 'EONLINE/CELEB'; 

04042019 AST: THE ABOVE LINE IS REMOVED BECAUSE THE SCRAPER HAS BEEN FIXED TO BRING THE CORRECT URLS
ALSO, ADDED CNN/ENT TO DEDUPE LIST*/

/* 06/12/2019 AST: Replaced the indiv dedupe calls with WSR_DEDUPE_ALL 
            Also added the EX and HL calls of the MLB, NBA, NFL */

/*
CALL WSR_DEDUPE('CNBC/BIZ') ;
CALL WSR_DEDUPE('USATODAY/BIZ') ;

CALL WSR_DEDUPE('CNN/POLITICS') ;
CALL WSR_DEDUPE('FOX/POLITICS') ;
CALL WSR_DEDUPE('RCP/POLITICS') ;
CALL WSR_DEDUPE('YAHOO/POLITICS') ;

CALL WSR_DEDUPE('CNN/CELEB') ; -- 'EONLINE/CELEB'
CALL WSR_DEDUPE('EONLINE/CELEB') ; 
CALL WSR_DEDUPE('ETONLINE/CELEB') ; 
CALL WSR_DEDUPE('CNNTV/ENT') ; 
CALL WSR_DEDUPE('CNN/ENT') ; 
CALL WSR_DEDUPE('HOLLY/ENT') ;

CALL WSR_DEDUPE('ESPN/NFL') ;
CALL WSR_DEDUPE('ESPN/NBA') ;
CALL WSR_DEDUPE('ESPN/MLB') ;

CALL WSR_DEDUPE('USATODAY/MLB') ;
CALL WSR_DEDUPE('USATODAY/NBA') ;
CALL WSR_DEDUPE('USATODAY/NFL') ;
*/

CALL WSR_DEDUPE_ALL() ;

CALL STP_GRAND_T4USA() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T9USA() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T1USA() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T10USA() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T5USA() ;
DELETE FROM OPN_POSTS WHERE POST_CONTENT IS NULL;

CALL STP_GRAND_T2MLBUSA() ;

CALL STP_GRAND_T2MLBUSA_HL() ;
CALL STP_GRAND_T2MLBUSA_EX() ;

CALL STP_GRAND_T2NBAUSA() ;

CALL STP_GRAND_T2NBAUSA_HL() ;
CALL STP_GRAND_T2NBAUSA_EX() ;

CALL STP_GRAND_T2NFLUSA() ;

CALL STP_GRAND_T2NFLUSA_HL() ;
CALL STP_GRAND_T2NFLUSA_EX() ;

DELETE FROM OPN_POSTS WHERE LENGTH(POST_CONTENT) < 4 AND POST_DATETIME > NOW()- INTERVAL 5 DAY ;


  
  
  
END; //
 DELIMITER ;
 
 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS STP_GRAND_XYZNEWS //
CREATE PROCEDURE STP_GRAND_XYZNEWS()
THISPROC: BEGIN

/* 

10/10/2020 AST: this proc is being built to run ust the XYzNEWS STP process
This will run prior to all other STPs so that the XYZNEWS will always have some data

10/11/2020 AST: Corrected various small mistakes (that were causing 0 rows updated) 
	mostly SCRAPE_TAG1 = 'POLITICS' changed to SCRAPE_TOPIC = 'POLITICS'
    ALSO CCODE MISMATCHES IN A FEW PLACES

*/

DECLARE POSTCOUNT, UNTAGCOUNT INT ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_HEADLINE LIKE '%SALE%' OR NEWS_HEADLINE LIKE '% SHOP%' OR NEWS_HEADLINE LIKE '%DISCOUNT%'
OR NEWS_HEADLINE LIKE '%OFF%' OR NEWS_HEADLINE LIKE '%SAVE%' OR NEWS_HEADLINE LIKE '%TIKTOK%' OR NEWS_HEADLINE LIKE '%BOTOX%') ;

DELETE FROM WEB_SCRAPE_RAW WHERE 1=1 AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('ENT', 'CELEB') 
AND (NEWS_URL LIKE '%SALE%' OR NEWS_URL LIKE '% SHOP%' OR NEWS_URL LIKE '%DISCOUNT%'
OR NEWS_URL LIKE '%OFF%' OR NEWS_URL LIKE '%SAVE%' OR NEWS_URL LIKE '%TIKTOK%' OR NEWS_URL LIKE '%BOTOX%') ;

-- 

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAPOLLW', SCRAPE_TAG2 = 'USAPOLLW', SCRAPE_TAG3 = 'USAPOLLW' 
WHERE (SCRAPE_SOURCE LIKE 'CNN%' OR SCRAPE_SOURCE LIKE 'YAHOO%' OR SCRAPE_SOURCE LIKE 'WAPO%' 
OR SCRAPE_SOURCE LIKE 'HILL%' OR SCRAPE_SOURCE LIKE 'VOX%')
AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG1 = 'USAPOLRW', SCRAPE_TAG2 = 'USAPOLRW', SCRAPE_TAG3 = 'USAPOLRW' 
WHERE (SCRAPE_SOURCE LIKE 'FOX%' OR SCRAPE_SOURCE LIKE 'RCP%' OR SCRAPE_SOURCE LIKE 'NR%' OR SCRAPE_SOURCE LIKE 'BBRT%') 
AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

-- 

/*  adding 20 POLNEWS SCRAPES FOR L AND  1 POLNEWS SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'USAPOLRW' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DATE, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 20   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'USAPOLRW' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DATE, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 1   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'USAPOLLW' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DATE, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 20   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TAG1 = 'USAPOLLW' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DATE, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 1   ;

/*  END OF adding 20 POLNEWS SCRAPES FOR L AND  1 POLNEWS SCRAPES FOR H   */

/*  adding 5 POLNEWS SCRAPES FOR MODI  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND (NEWS_HEADLINE LIKE     '%NARENDRA%MODI%'     
OR NEWS_HEADLINE LIKE     '%PM%MODI%' OR NEWS_HEADLINE LIKE     '%NAMO%' OR NEWS_EXCERPT LIKE     '%MODI%GOV%'
) 
AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC = 'POLITICS' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

/*  END OF adding 5 POLNEWS SCRAPES FOR MODI  */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC = 'POLITICS' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 15   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'POLNEWS' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC = 'POLITICS' AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 1   ;

/*  END OF adding 15 POLNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 sportsnews2 SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_SOURCE LIKE ('%NBA%') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_SOURCE LIKE ('%NFL%') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_SOURCE LIKE ('%MLB%') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('SPORTS') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 3   ;

/*  END OF adding 15 sportsnews2 SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 sportsnews2 SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('SPORTS') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'sportsnews2' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('SPORTS') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 1   ;

/*  END OF adding 15 sportsnews2 SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  START OF SCIENCENEWS3 ADDITION */

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sciencenews3'    , SCRAPE_TAG3 = 'L'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND TAG_DONE_FLAG = 'N' AND SCRAPE_TOPIC = 'SCIENCE' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5 ;

UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y', SCRAPE_TAG2 =     'sciencenews3'    , SCRAPE_TAG3 = 'H'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND TAG_DONE_FLAG = 'N' AND SCRAPE_TOPIC = 'SCIENCE' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 1 ;

/*  END OF SCIENCENEWS3 ADDITION */

/* businessnews4 added for STP */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'businessnews4' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y'  
WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TOPIC = 'BUSINESS'
AND TAG_DONE_FLAG = 'N'  AND COUNTRY_CODE = 'USA' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
AND NEWS_URL NOT LIKE ('%STOCK%MARKET%') AND  NEWS_URL NOT LIKE ('%MARKET%STOCK%')
ORDER BY RAND() LIMIT 25 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'businessnews4' , SCRAPE_TAG3 = 'H'  , TAG_DONE_FLAG = 'Y'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TOPIC = 'BUSINESS'
AND TAG_DONE_FLAG = 'N' AND COUNTRY_CODE = 'USA' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
AND NEWS_URL NOT LIKE ('%STOCK%MARKET%') AND  NEWS_URL NOT LIKE ('%MARKET%STOCK%')
ORDER BY RAND() LIMIT 2 ;

/* END OF businessnews4 added for STP */

/* businessnews4 added for STP */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'businessnews4' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y'  
WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TOPIC = 'BUSINESS' AND TAG_DONE_FLAG = 'N'  AND COUNTRY_CODE = 'IND' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
AND NEWS_URL NOT LIKE ('%STOCK%MARKET%') AND  NEWS_URL NOT LIKE ('%MARKET%STOCK%')
ORDER BY RAND() LIMIT 30 ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'businessnews4' , SCRAPE_TAG3 = 'H'  , TAG_DONE_FLAG = 'Y'    
WHERE  MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TOPIC = 'BUSINESS'
AND TAG_DONE_FLAG = 'N' AND COUNTRY_CODE = 'IND' 
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
AND NEWS_URL NOT LIKE ('%STOCK%MARKET%') AND  NEWS_URL NOT LIKE ('%MARKET%STOCK%')
ORDER BY RAND() LIMIT 2 ;

/* END OF businessnews4 added for STP */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 entertainmentnews5 SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'entertainmentnews5' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 20   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'entertainmentnews5' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 2   ;

/*  END OF adding 15 entertainmentnews5 SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 entertainmentnews5 SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'entertainmentnews5' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 20   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'entertainmentnews5' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 2   ;

/*  END OF adding 15 entertainmentnews5 SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  adding 15 CELEBNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'CELEBNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 25   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'CELEBNEWS' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'USA' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 2   ;

/*  END OF adding 15 CELEBNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */

/*  adding 15 POLNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H  */

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'CELEBNEWS' , SCRAPE_TAG3 = 'L', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 20   ;

UPDATE WEB_SCRAPE_RAW SET SCRAPE_TAG2 =     'CELEBNEWS' , SCRAPE_TAG3 = 'H', TAG_DONE_FLAG = 'Y' 
WHERE  MOVED_TO_POST_FLAG = 'N' AND COUNTRY_CODE = 'IND' AND SCRAPE_TOPIC IN ('CELEB', 'ENT') AND TAG_DONE_FLAG = 'N'
AND LENGTH(NEWS_DTM_RAW) > 2 AND STR_TO_DATE(SUBSTRING(NEWS_DTM_RAW, 1, 10), '%Y-%m-%d') >= CURRENT_DATE() - INTERVAL 1 DAY
ORDER BY RAND() LIMIT 5   ;

/*  END OF adding 15 POLNEWS SCRAPES FOR L AND  5 POLNEWS SCRAPES FOR H   */


/*	07/19/2020 AST: Added the TAG_DONE_FLAG = 'Y' to make it compatible with the new STP_STAG23_MICRO */

-- UPDATE WEB_SCRAPE_RAW SET TAG_DONE_FLAG = 'Y' WHERE MOVED_TO_POST_FLAG = 'N' AND SCRAPE_TAG3 IN ('L', 'H') ;

/* 	END OF 07/19/2020 AST ADDITION */

/*  Completing the POLNEWS addition with STp MICRo call  */

CALL STP_STAG23_MICRO('POLNEWS', 'H') ;

CALL STP_STAG23_MICRO('POLNEWS', 'L') ;

CALL STP_STAG23_MICRO('sportsnews2', 'H') ;

CALL STP_STAG23_MICRO('sportsnews2', 'L') ;

CALL STP_STAG23_MICRO('sciencenews3', 'H') ;

CALL STP_STAG23_MICRO('sciencenews3', 'L') ;

CALL STP_STAG23_MICRO('businessnews4', 'H') ;

CALL STP_STAG23_MICRO('businessnews4', 'L') ;

CALL STP_STAG23_MICRO('entertainmentnews5', 'H') ;

CALL STP_STAG23_MICRO('entertainmentnews5', 'L') ;

CALL STP_STAG23_MICRO('CELEBNEWS', 'H') ;

CALL STP_STAG23_MICRO('CELEBNEWS', 'L') ;

/*  END OF Completing the POLNEWS addition with STp MICRo call  */

/* 05/26/2018 AST: adding below: After this proc is executed, the scrapes that were converted into posts
should be swept into the WSR_CONVERTED table 

And the scrapes that remained untagged (and specific to IND, OLITICS should be swept to WSR_UNTAGGED 
This kind of step should be taken at the end of each topic STP - but combo topics
such as trending + politics, celeb + media become an issue. We will deal with it later.
*/

INSERT INTO WSR_CONVERTED(SCRAPE_TOPIC, SCRAPE_SOURCE, SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE
, NEWS_EXCERPT, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE)
SELECT SCRAPE_TOPIC, SCRAPE_SOURCE,  SCRAPE_DATE, NEWS_DATE, NEWS_HEADLINE, NEWS_EXCERPT
, NEWS_PIC_URL, NEWS_URL, COUNTRY_CODE FROM WEB_SCRAPE_RAW
WHERE  MOVED_TO_POST_FLAG = 'Y' ;

/* 10/10/2020 AST: COMMENTING OUT THE INSERT INTO OPN_WEB_LINKS - BECAUSE WE DON'T NEED ANYMORE 

INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_PIC_URL IS NOT NULL AND SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' ;

 END OF COMMENTING OUT THE INSERT INTO OPN_WEB_LINKS */

SET POSTCOUNT = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW
WHERE  MOVED_TO_POST_FLAG = 'Y') ;

DELETE FROM WEB_SCRAPE_RAW WHERE  MOVED_TO_POST_FLAG = 'Y' ;

INSERT INTO OPN_STP_LOG(PROC_NAME, STP_TOPIC, STP_COUNTRY_CODE, POST_COUNT, UNTAG_COUNT, STP_PROC_DTM)
VALUES('STP_GRAND_XYZNEWS', 'XYZ', 'ALL', POSTCOUNT, 0, NOW()) ;

/* End of STP logging */
  
  
  
END; //
 DELIMITER ;
 
 -- -- STP_MONITOR

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS STP_MONITOR //
CREATE PROCEDURE STP_MONITOR(WSR_FILE VARCHAR(300))
THISPROC: BEGIN

/* 
07/19/2019 AST: This proc is for calling all the UKW and STP GRAND procs and logging the WSR and POST counts at each stage
03/04/2020 AST: Removed WFD from inputs and turned it into a var
08/11/2020 Kapil: Confirmed
10/11/2020 AST: Adding the STP_GRAND_XYZNEWS portion
*/


DECLARE SPC, SWC, DWC, DPC, R_ID INT;
DECLARE WSR_TO_POST_RATIO DOUBLE;
DECLARE CDTM DATETIME ;
DECLARE WFD DATE ;

SET SQL_SAFE_UPDATES = 0;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
SET CDTM = NOW() ;
SET WFD = CURRENT_DATE() ;

DELETE FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD ;
  
INSERT INTO OPN_STP_MONITOR(WSR_FILE_NAME, WSR_FILE_DATE, STP_MONITOR_PROCESS
, STARTING_POST_COUNT, STARTING_WSR_COUNT, CREATION_DTM)
VALUES(WSR_FILE, WFD, 'INITIAL_WSR_LOAD', SPC, SWC, CDTM);

INSERT INTO OPN_STP_MONITOR(WSR_FILE_NAME, WSR_FILE_DATE, STP_MONITOR_PROCESS, CREATION_DTM)
VALUES (WSR_FILE, WFD, 'STP_GRAND_XYZNEWS', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(10)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(5)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(9)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(4)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(1)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(2)', CDTM)
, (WSR_FILE, WFD, 'OPN_UKW_TAGGING(3)', CDTM)
, (WSR_FILE, WFD, 'STP_GRAND_USA()', CDTM)
, (WSR_FILE, WFD, 'STP_GRAND_IND()', CDTM)
, (WSR_FILE, WFD, 'STP_GRAND_GGG()', CDTM)
;

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' AND CREATION_DTM = CDTM) ;
CALL WSR_DEDUPE_ALL() ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR M SET M.DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = SPC WHERE M.ROW_ID = R_ID ;

-- Adding the STP_GRAND_XYZNEWS 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_XYZNEWS' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_XYZNEWS() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;


-- End of STP_GRAND_XYZNEWS -- Starting TID 10

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(10)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(10) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 10 - Starting TID 5 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(5)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(5) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 5 - Starting TID 9 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(9)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(9) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 9 - Starting TID 4 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(1)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(1) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 4 - Starting TID 1 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(4)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(4) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 1 - Starting TID 2 

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(2)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(2) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 2 - Starting TID 3

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'OPN_UKW_TAGGING(3)' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL OPN_UKW_TAGGING(3) ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of TID 3 - Starting USA

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_USA()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_USA() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of USA - Starting IND

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_IND()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_IND() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

-- End of IND - Starting GGG

SET R_ID = (SELECT ROW_ID FROM OPN_STP_MONITOR WHERE WSR_FILE_NAME = WSR_FILE AND STP_MONITOR_PROCESS = 'STP_GRAND_GGG()' AND CREATION_DTM = CDTM) ;
SET SPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET SWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
CALL STP_GRAND_GGG() ;
CALL OPN_SUPPRESS_DUPES(1, 3 , 'DAY');
SET DPC = (SELECT COUNT(1) FROM OPN_POSTS WHERE CLEAN_POST_FLAG = 'Y') ;
SET DWC = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW) ;
UPDATE OPN_STP_MONITOR SET STARTING_POST_COUNT = SPC, STARTING_WSR_COUNT = SWC, DEDUPED_WSR_COUNT = DWC, DEDUPED_POST_COUNT = DPC WHERE ROW_ID = R_ID ;

UPDATE OPN_STP_MONITOR SET DEDUPED_POST_COUNT = DPC WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' ;
UPDATE OPN_STP_MONITOR SET POST_COUNT = (DEDUPED_POST_COUNT - STARTING_POST_COUNT) WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD ;
UPDATE OPN_STP_MONITOR SET POST_TO_WSR_RATIO = ROUND(POST_COUNT*100/DEDUPED_WSR_COUNT, 2)
WHERE WSR_FILE_NAME = WSR_FILE AND WSR_FILE_DATE = WFD AND STP_MONITOR_PROCESS = 'INITIAL_WSR_LOAD' ;


END //
DELIMITER ;

-- -- STP_STAG23_MICRO

DELIMITER //
DROP PROCEDURE IF EXISTS STP_STAG23_MICRO //
CREATE PROCEDURE STP_STAG23_MICRO( STAG2V VARCHAR(50), STAG3V VARCHAR(50))
thisProc: BEGIN
  DECLARE SCRAPEID, PBUID, PBUID2, KID, TID, USERCNT, SCRAPECNT INT;
  DECLARE SCRAPEURL, URLTITLE VARCHAR(1000);
  DECLARE CCODE VARCHAR(5);
  DECLARE SCRPTPC VARCHAR(30) ;
  DECLARE SCRDATE DATE ;

/* 07/01/2020 AST:

	Rebuilding this very important proc.
    
    This proc is the main culmination of the entire STP Engine. Every STP script and 
    the critical OPN_UKW_TAGGING finally culminates into this proc call
    
    Problem Statement: The problem is that a globally relevant KW, such as 'coronavirus' 
    Why is it a problem: This KW was created by a user with IND ccode. Hence no USA 
    BOT users have been assigned this KW in their cart. But lots of USA users can be 
    expected to add it to their carts. But they will not get any news items because
    no USA BOTs have it.
    
    This requires a 2-step solution:
    
    Step 1: Fix the ADD_NUSERS_4K1 proc. Currently it inserts KW in only matching ccode users
    Make it so that it will also add users for the remaining 2 ccodes,
    Impact: If the KW is truly global then the scrapes will find enough links to create posts
    for all ccodes.
    If the KW is not really global, for ex. a mainly IND kw - such as 'COVID HANDLING IN MUMBAI',
    there won't be many scrapes from USA websites. When STP tries to push scrapes to USA BOTs,
    it will not find any scrapes to do so. No harm in that.
    
    Step 2: Then fix this proc (STP_STAG23_MICRO) - Turning around this proc completely.
    Instead of cursor being the userid, it should be the scrape_id - and find users to 
    push the scrape as a post from.
    
    07/06/2020 AST: Added condition handling for NULL PBUID
    
    07/07/2020 AST: Added URL_TITLE to the cursor and INSERT
    
    09/05/2020 AST: confirmed

*/

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR 
  SELECT W.ROW_ID, IFNULL(STR_TO_DATE(W.NEWS_DATE, '%Y-%m-%d'), W.SCRAPE_DATE) SCRAPE_DATE
  , W.SCRAPE_TOPIC, SUBSTR(W.NEWS_URL, 1, 999) NEWS_URL, W.NEWS_HEADLINE, W.COUNTRY_CODE, K.KEYID, K.TOPICID
  FROM WEB_SCRAPE_RAW W, OPN_P_KW K
  WHERE W.SCRAPE_TAG2 = K.SCRAPE_TAG2 AND W.MOVED_TO_POST_FLAG = 'N' AND W.TAG_DONE_FLAG = 'Y'
  AND W.SCRAPE_TAG2 = STAG2V AND W.SCRAPE_TAG3 = STAG3V  ;


   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO SCRAPEID, SCRDATE, SCRPTPC, SCRAPEURL, URLTITLE, CCODE, KID, TID ;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      
      /*
SET USERCNT = (SELECT COUNT(DISTINCT C.USERID) FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE) ;

SET SCRAPECNT = (SELECT COUNT(1) FROM WEB_SCRAPE_RAW WHERE SCRAPE_TAG2 = STAG2V AND SCRAPE_TAG3 = STAG3V 
AND MOVED_TO_POST_FLAG = 'N' AND TAG_DONE_FLAG = 'Y') ;

CASE WHEN USERCNT <= SCRAPECNT * 0.2 THEN

CALL ADD_NUSERS_4K1(KID, CCODE, TID) ; END CASE ;
*/

SET PBUID = (SELECT DISTINCT C.USERID FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.CART = STAG3V AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE 
AND U1.BOT_FLAG = 'Y' ORDER BY RAND() LIMIT 1)  ;

CASE WHEN PBUID IS NOT NULL THEN 

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, TAG1_KEYID, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID, SCRAPEURL, 'Y', '', 'N', CCODE, SCRAPEID, URLTITLE, KID, 'STP_STAG23_MICRO', '', 'N');

  UPDATE WEB_SCRAPE_RAW SET MOVED_TO_POST_FLAG = 'Y' WHERE ROW_ID = SCRAPEID ;
  
  WHEN PBUID IS NULL THEN 
  
  CALL ADD_NUSERS_4K1(KID, CCODE, TID) ; 
  
  SET PBUID2 = (SELECT DISTINCT C.USERID FROM OPN_USER_CARTS C, OPN_USERLIST U1
WHERE C.KEYID = KID AND C.CART = STAG3V AND C.USERID = U1.USERID AND U1.COUNTRY_CODE = CCODE 
AND U1.BOT_FLAG = 'Y' ORDER BY RAND() LIMIT 1)  ;
  
  INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG 
, EMBEDDED_CONTENT, EMBEDDED_FLAG, POSTOR_COUNTRY_CODE, SCRAPE_ROW_ID, URL_TITLE, TAG1_KEYID, STP_PROC_NAME
, MEDIA_CONTENT, MEDIA_FLAG)
VALUES( TID, SCRDATE, PBUID2, SCRAPEURL, 'Y', '', 'N', CCODE, SCRAPEID, URLTITLE, KID, 'STP_STAG23_MICRO', '', 'N');

  UPDATE WEB_SCRAPE_RAW SET MOVED_TO_POST_FLAG = 'Y' WHERE ROW_ID = SCRAPEID ;
 
  LEAVE thisProc ;

 end case ;
 
        END LOOP;
  CLOSE CURSOR_I;
 
END

; //
 DELIMITER ;
 
 -- END OF STP_STAG23_MICRO

 -- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS WSRU_SEARCH //
CREATE PROCEDURE WSRU_SEARCH(CCODE VARCHAR(5), K1 VARCHAR(30), K2 VARCHAR(30))
THISPROC: BEGIN

/* 


*/

DECLARE STERM VARCHAR(60) ;

SET @STERM = (SELECT CONCAT( '%', K1, '%', K2, '%')) ;

-- SELECT @STERM ;


SELECT DISTINCT SCRAPE_DATE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT FROM WSR_UNTAGGED WHERE 
(NEWS_URL LIKE @STERM OR NEWS_HEADLINE LIKE @STERM OR NEWS_EXCERPT LIKE @STERM ) AND COUNTRY_CODE = CCODE
AND SCRAPE_DATE > NOW() - INTERVAL 1 MONTH ORDER BY SCRAPE_DATE DESC LIMIT 40;


  
END; //
 DELIMITER ;
 
 -- -- 

DELIMITER //
DROP PROCEDURE IF EXISTS WSRU_T_SEARCH //
CREATE PROCEDURE WSRU_T_SEARCH(CCODE VARCHAR(5), TPC VARCHAR(30), FROMIN INT, TOIN INT)
THISPROC: BEGIN

/* 


*/


SELECT DISTINCT SCRAPE_DATE, NEWS_URL, NEWS_HEADLINE, NEWS_EXCERPT FROM WSR_UNTAGGED WHERE 
 COUNTRY_CODE = CCODE AND SCRAPE_TOPIC = TPC
AND SCRAPE_DATE > NOW() - INTERVAL 1 MONTH ORDER BY SCRAPE_DATE DESC LIMIT FROMIN, TOIN ;


  
END; //
 DELIMITER ;
 
 -- 
-- WSR_DEDUPE

 DELIMITER //
DROP PROCEDURE IF EXISTS WSR_DEDUPE //
CREATE PROCEDURE WSR_DEDUPE(SCRAPESRC varchar(45))
BEGIN

/* 12/12/2018 AST: Added NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT to the dedupe logic  
 12/18/2018 ADDED  SCRAPE_DATE, NEW_DATE 
 
 06/16/2019 AST:  Added the case sts below to replace the blanks in NEWS_HEADLINE AND NEWS_EXCERPT
 
 07/29/2019 AST: Added SUBSTR(XYZ, 1, 300) for all the major scraped columns - this is because some of them sometimes came in too big and caused 
 error in INSERT
 
 10/15/2020 AST: Rebuilding this proc to ensure: 1. The scrapes with no NDTM are given an older date
					2. dedupe is done without losing the NDTM info
 
 */
 
 SET SQL_SAFE_UPDATES = 0;

DELETE FROM WEB_SCRAPE_DEDUPE WHERE SCRAPE_SOURCE = SCRAPESRC ;
DELETE FROM WSR_DEDUPE_NDTM WHERE SCRAPE_SOURCE = SCRAPESRC ;

UPDATE WEB_SCRAPE_RAW SET NEWS_DTM_RAW = NOW() - INTERVAL 3 DAY WHERE SCRAPE_SOURCE = SCRAPESRC
AND LENGTH(NEWS_DTM_RAW) < 3 ;

INSERT INTO WEB_SCRAPE_DEDUPE(SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL
, NEWS_HEADLINE, NEWS_EXCERPT, MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT DISTINCT SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NEWS_PIC_URL
, SUBSTR(NEWS_HEADLINE, 1, 500), SUBSTR(NEWS_EXCERPT, 1, 300), MOVED_TO_POST_FLAG, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WEB_SCRAPE_RAW WHERE MOVED_TO_POST_FLAG = 'N' AND SCRAPE_SOURCE = SCRAPESRC  ;

INSERT INTO WSR_DEDUPE_NDTM(SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, NDTM)
SELECT SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL, MIN(NEWS_DTM_RAW)
FROM WEB_SCRAPE_RAW WHERE MOVED_TO_POST_FLAG = 'N' AND SCRAPE_SOURCE = SCRAPESRC
GROUP BY SCRAPE_SOURCE, SCRAPE_TOPIC, NEWS_URL ;

DELETE FROM WEB_SCRAPE_RAW WHERE SCRAPE_SOURCE = SCRAPESRC ;

INSERT INTO WEB_SCRAPE_RAW(SCRAPE_SOURCE, SCRAPE_TOPIC, SCRAPE_DATE, NEWS_DATE
, NEWS_URL, NEWS_PIC_URL, NEWS_HEADLINE, NEWS_EXCERPT, MOVED_TO_POST_FLAG
, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3)
SELECT SCRAPE_SOURCE, SCRAPE_TOPIC, CURDATE(), CURDATE()
, NEWS_URL, NEWS_PIC_URL
, (CASE WHEN LENGTH(NEWS_HEADLINE) < 5 AND LENGTH(NEWS_EXCERPT) < 5 THEN REPLACE(SUBSTRING_INDEX(NEWS_URL, '/', -1), '-', ' ') 
WHEN LENGTH(NEWS_HEADLINE) < 5 AND LENGTH(NEWS_EXCERPT) > 5 THEN SUBSTRING(NEWS_EXCERPT, 1, 300)
WHEN LENGTH(NEWS_HEADLINE) > 4 THEN SUBSTRING(NEWS_HEADLINE, 1, 300) END ) NEWS_HEADLINE
, (CASE WHEN LENGTH(NEWS_EXCERPT) < 5 AND LENGTH(NEWS_HEADLINE) < 5 THEN REPLACE(SUBSTRING_INDEX(NEWS_URL, '/', -1), '-', ' ') 
WHEN LENGTH(NEWS_EXCERPT) < 5 AND LENGTH(NEWS_HEADLINE) > 5 THEN NEWS_HEADLINE
WHEN LENGTH(NEWS_EXCERPT) > 4 THEN NEWS_EXCERPT END ) NEWS_EXCERPT
, MOVED_TO_POST_FLAG
, COUNTRY_CODE, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_TAG3
FROM WEB_SCRAPE_DEDUPE WHERE MOVED_TO_POST_FLAG = 'N' AND SCRAPE_SOURCE = SCRAPESRC ;

UPDATE WEB_SCRAPE_RAW R, WSR_DEDUPE_NDTM N SET R.NEWS_DTM_RAW = N.NDTM 
WHERE R.NEWS_URL = N.NEWS_URL ;

DELETE FROM WEB_SCRAPE_RAW  WHERE NEWS_URL IN (SELECT NEWS_URL FROM WSR_CONVERTED WHERE SCRAPE_SOURCE = SCRAPESRC ) ;
DELETE FROM WSR_DEDUPE_NDTM WHERE SCRAPE_SOURCE = SCRAPESRC ;

/* INSERT INTO OPN_WEB_LINKS(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM, CLEAN_FLAG)
SELECT NEWS_URL, IFNULL(NEWS_HEADLINE, NEWS_EXCERPT), IFNULL(NEWS_EXCERPT
, NEWS_HEADLINE), NEWS_PIC_URL, NOW(), 'Y'
FROM WEB_SCRAPE_RAW WHERE NEWS_URL NOT IN (SELECT WEB_URL FROM OPN_WEB_LINKS) 
AND NEWS_PIC_URL IS NOT NULL AND SCRAPE_SOURCE = SCRAPESRC ;
*/


END //
DELIMITER ;

-- 
-- WSR_DEDUPE_ALL

 DELIMITER //
DROP PROCEDURE IF EXISTS WSR_DEDUPE_ALL //
CREATE PROCEDURE WSR_DEDUPE_ALL()
thisProc: BEGIN

/* 10/15/2020 AST: Confirmed  */

  DECLARE  SCR_SRC VARCHAR(50) ;

    DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_2L CURSOR FOR SELECT DISTINCT SCRAPE_SOURCE FROM WEB_SCRAPE_RAW WHERE MOVED_TO_POST_FLAG = 'N';

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_2L;
   READ_LOOP: LOOP
    FETCH CURSOR_2L INTO SCR_SRC;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;

CALL WSR_DEDUPE(SCR_SRC) ;
 
        END LOOP;
  CLOSE CURSOR_2L;

END //
DELIMITER ;

-- -- addCleanDomain

 DELIMITER //
DROP PROCEDURE IF EXISTS addCleanDomain //
CREATE PROCEDURE addCleanDomain(sitename varchar(100), udomain VARCHAR(100))
BEGIN

/* 04/22/2020 AST: Adding an example of the call
 addCleanDomain('DIAWI', 'DIAWI.COM')*/

INSERT INTO OPN_CLEAN_DOMAINS(SITE_NAME, U_DOMAIN) VALUES(sitename, udomain) ;


END //
DELIMITER ;

-- -- addSearchKwToCart

 DELIMITER //
DROP PROCEDURE IF EXISTS addSearchKwToCart //
CREATE PROCEDURE addSearchKwToCart(tid INT -- , ccode VARCHAR(5)
, uuid varchar(45), cartv VARCHAR(3), kid INT)
thisProc: BEGIN

/* This proc is for adding the KWs to a user's cart where the KWs 
are selected from the results of a search
This proc is the first usage of the composite key for OUC. 
OUC now has a composite key of UID+TOPICID+KEYID

This will use the INSERT OR UPDATE  strategy
It will also not invoke the CLustering - 
as a new network algo has been developed that eliminates clustering

addSearchKwToCart(tid , ccode , uuid , cartv , kid )

04/25/2020 AST: Actually removed the cluster call today. 

05/26/2020 AST: Removing the ccode from Input Params
08/19/2020 Kapil: Confirmed

*/

  DECLARE  UID INT ;
  DECLARE SUSP VARCHAR(5) ;

SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE

SET UID = (SELECT bringUserid(uuid)) ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(bringUsernameByUUID(uuid), UID, uuid, NOW()
, 'addSearchKwToCart', CONCAT(tid, '-',cartv,'-', kid));

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( cartv, kid, UID, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = cartv;

-- CALL NEWCART_TOP_NOTAILOR(uuid, tid) ;
END IF ;   


END //
DELIMITER ;

-- -- changeCountryCode

 DELIMITER //
DROP PROCEDURE IF EXISTS changeCountryCode //
CREATE PROCEDURE changeCountryCode(userid varchar(45),country_code varchar(5))
BEGIN

/* 	08/09/2020 AST: Confirmed Version  */
/* 	08/14/2020 Kapil: Confirmed Version  */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('changeCountryCode', NOW(), 'UUID', userid);

UPDATE OPN_USERLIST U SET U.COUNTRY_CODE = country_code , U.P_Q_CHANGE_DT = NOW()
WHERE U.USER_UUID = userid AND U.USERID>0;

END //
DELIMITER ;

-- -- checkNewKwOK

 DELIMITER //
DROP PROCEDURE IF EXISTS checkNewKwOK //
CREATE PROCEDURE checkNewKwOK(uuid VARCHAR(45), tid INT, userKW varchar(60))
THISPROC: BEGIN

/*
11/02/2018 AST: Adding check if the KW already exists in the TID

TBD: add a check that a user can add only 3 new KW per day
Also make sure that the user is not blacklisted
08/19/2020 Kapil: Confirmed
*/


  DECLARE VPH, KWTRIM, VPHWILD VARCHAR(60);
  DECLARE VERBO, KWTIDEXISTS INT;
  DECLARE SUSP VARCHAR(5) ;
  /*
  DECLARE DONE INT DEFAULT FALSE;
  DECLARE CURSOR_I CURSOR FOR  SELECT VERBOTEN_PHRASE FROM OPN_VERBOTEN;

   DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
  OPEN CURSOR_I;
   READ_LOOP: LOOP
    FETCH CURSOR_I INTO VPH;
     IF DONE THEN
      LEAVE READ_LOOP;
      END IF;
      */
SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE 

SET KWTRIM = UPPER(removeAlpha(userKW)) ;
-- SET VPHWILD = CONCAT("'%", VPH, "%'") ;
SET VERBO = (SELECT MAX(INSTR(KWTRIM, VERBOTEN_PHRASE) )FROM OPN_VERBOTEN  );

SET KWTIDEXISTS = (SELECT COUNT(*) FROM OPN_P_KW WHERE TOPICID = tid AND UPPER(KEYWORDS) = UPPER(REPLACE(userKW, ' ', '') ) ) ;

CASE WHEN KWTIDEXISTS = 0 THEN 

CASE WHEN VERBO  = 0 THEN SELECT 1 CHKSTATUS;

-- INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
-- VALUES(bringUsernameByUUID(uuid), bringUserid(uuid), uuid, NOW(), 'checkNewKwOK', CONCAT(tid, '-', userKW));

-- LEAVE THISPROC;

WHEN VERBO > 0 THEN SELECT NULL CHKSTATUS;

-- INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
-- VALUES(bringUsernameByUUID(uuid), bringUserid(uuid), uuid, NOW(), 'checkNewKwOK', CONCAT(tid, '-', userKW));

END CASE ;

 WHEN KWTIDEXISTS > 0 THEN SELECT NULL CHKSTATUS;
 
 END CASE ;
 END IF ;

     --   END LOOP;
  -- CLOSE CURSOR_I;


END //
DELIMITER ;

-- -- 

DELIMITER //
DROP PROCEDURE IF EXISTS checkusername //
CREATE PROCEDURE `checkusername`(uname varchar(30))
BEGIN

/* 26/03/2020 Rohit: -Create this store proc to find is there username available in the database
Call checkusername("rohit123");
Return 1 if already in use.
return 0 if available for use.

12/13/2020 AST CONFIRMED

 */

SELECT COUNT(USERNAME) as count FROM OPN_USERLIST WHERE USERNAME= uname;

END //
DELIMITER ;

-- -- commentsByPostANTI

DELIMITER //
DROP PROCEDURE IF EXISTS commentsByPostANTI //
CREATE PROCEDURE commentsByPostANTI(postid INT, usid varchar(45), sortOrder varchar(10)
, fromindex INT, toindex INT )
BEGIN

/* 04272018 AST: Adding userid (the user_uuid of the logged in user) as an input param. 
The PHP (API) will have to be changed
to provide the value.

This is being done in order to filter the comments that are from users who have been 
kicked out by the current logged in user 

08/15/2019 AST: Changed the old cluster-based networking algo that was used 
for comments from within the network */

/* 26/03/2020 Rohit :- Add the OU.DP_URL in the select statement */
/* 04/22/2020: AST: Rebuilding this as NW proc. Also adding the Parent Post/comment */

/* 05/15/2020 AST: Added logic to filter when parent CBUID is also not in network 

	08/09/2020 AST: COnfirmed */
    
/* 	11/08/2020 AST: Now the non-clean posts are being changed to a standard warning replacement. 
	Hence, removing the filter AND OPC.CLEAN_COMMENT_FLAG = 'Y' from all cases below */

DECLARE ORIG_UID, TID, CAUSE_POST_BYUID, PARENT_CMT_BYUID INT ;
DECLARE THIS_UNAME, PARENT_UNAME, CAUSE_POST_UNAME, SORTBY VARCHAR(40) ;

SELECT U1.USERID, U1.USERNAME INTO ORIG_UID, THIS_UNAME 
FROM OPN_USERLIST U1 WHERE U1.USER_UUID = usid ;
SELECT OP1.TOPICID, OP1.POST_BY_USERID INTO TID, CAUSE_POST_BYUID 
FROM OPN_POSTS OP1 WHERE OP1.POST_ID = postid ;
SELECT U2.USERNAME INTO PARENT_UNAME FROM OPN_USERLIST U2 
WHERE U2.USERID = CAUSE_POST_BYUID ;

CASE WHEN sortOrder = 'NEWONTOP' THEN  

SELECT OPC.TOPICID, OPC.CAUSE_POST_ID,OPC.COMMENT_ID
, OPC.COMMENT_BY_USERID, OU.USERNAME COMMENT_BY_UNAME
, OU.DP_URL, OPC.COMMENT_CONTENT, OPC.COMMENT_DTM
, OPC.EMBEDDED_CONTENT, OPC.EMBEDDED_FLAG
, (CASE WHEN OPC.COMMENT_TYPE = 'CONP' THEN OPC.COMMENT_ID ELSE OPC.PARENT_COMMENT_ID END ) PARENT_COMMENT_ID
, OPC.PARENT_COMMENT_UNAME, OPC.PARENT_COMMENT_DTM
, OPC.PARENT_COMMENT_CONTENT, OPC.PARENT_MEDIA_CONTENT
, OPC.PARENT_COMMENT_BYUID, OPC.COMMENT_TYPE
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG
FROM OPN_POST_COMMENTS OPC, OPN_USERLIST OU
WHERE OPC.COMMENT_BY_USERID = OU.USERID
AND OPC.COMMENT_BY_USERID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART <> B.CART )
AND OPC.PARENT_COMMENT_BYUID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART <> B.CART )
AND OPC.CAUSE_POST_ID = postid
-- AND OPC.CLEAN_COMMENT_FLAG = 'Y'
AND OPC.COMMENT_DELETE_FLAG = 'N'
ORDER BY  OPC.COMMENT_DTM DESC ;


WHEN sortOrder = 'OLDONTOP' THEN 

SELECT OPC.TOPICID, OPC.CAUSE_POST_ID,OPC.COMMENT_ID
, OPC.COMMENT_BY_USERID, OU.USERNAME COMMENT_BY_UNAME
, OU.DP_URL, OPC.COMMENT_CONTENT, OPC.COMMENT_DTM
, OPC.EMBEDDED_CONTENT, OPC.EMBEDDED_FLAG
, (CASE WHEN OPC.COMMENT_TYPE = 'CONP' THEN OPC.COMMENT_ID ELSE OPC.PARENT_COMMENT_ID END ) PARENT_COMMENT_ID
, OPC.PARENT_COMMENT_UNAME, OPC.PARENT_COMMENT_DTM
, OPC.PARENT_COMMENT_CONTENT, OPC.PARENT_MEDIA_CONTENT
, OPC.PARENT_COMMENT_BYUID, OPC.COMMENT_TYPE
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG
FROM OPN_POST_COMMENTS OPC, OPN_USERLIST OU
WHERE OPC.COMMENT_BY_USERID = OU.USERID
AND OPC.COMMENT_BY_USERID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART <> B.CART)
AND OPC.PARENT_COMMENT_BYUID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART <> B.CART)
AND OPC.CAUSE_POST_ID = postid
-- AND OPC.CLEAN_COMMENT_FLAG = 'Y'
AND OPC.COMMENT_DELETE_FLAG = 'N'
ORDER BY  OPC.COMMENT_DTM ASC ;


 END CASE ;
  
END//
DELIMITER ;

-- -- commentsByPostNW

DELIMITER //
DROP PROCEDURE IF EXISTS commentsByPostNW //
CREATE PROCEDURE commentsByPostNW(postid INT, usid varchar(45), sortOrder varchar(10)
, fromindex INT, toindex INT )
BEGIN

/* 04272018 AST: Adding userid (the user_uuid of the logged in user) as an input param. 
The PHP (API) will have to be changed
to provide the value.

This is being done in order to filter the comments that are from users who have been 
kicked out by the current logged in user 

08/15/2019 AST: Changed the old cluster-based networking algo that was used 
for comments from within the network */

/* 26/03/2020 Rohit :- Add the OU.DP_URL in the select statement */
/* 04/22/2020: AST: Rebuilding this as NW proc. Also adding the Parent Post/comment */

/* 05/15/2020 AST: Added logic to filter when parent CBUID is also not in network 
	06/18/2020 AST: Added  AND A.CART = B.CART to the OLDONTOP case - had been left out inadvertantly
    
    08/09/2020 AST: COnfirmed  */
    
/* 	11/08/2020 AST: Now the non-clean posts are being changed to a standard warning replacement. 
	Hence, removing the filter AND OPC.CLEAN_COMMENT_FLAG = 'Y' from all cases below */

DECLARE ORIG_UID, TID, CAUSE_POST_BYUID, PARENT_CMT_BYUID INT ;
DECLARE THIS_UNAME, PARENT_UNAME, CAUSE_POST_UNAME, SORTBY VARCHAR(40) ;

SELECT U1.USERID, U1.USERNAME INTO ORIG_UID, THIS_UNAME 
FROM OPN_USERLIST U1 WHERE U1.USER_UUID = usid ;
SELECT OP1.TOPICID, OP1.POST_BY_USERID INTO TID, CAUSE_POST_BYUID 
FROM OPN_POSTS OP1 WHERE OP1.POST_ID = postid ;
SELECT U2.USERNAME INTO PARENT_UNAME FROM OPN_USERLIST U2 
WHERE U2.USERID = CAUSE_POST_BYUID ;

CASE WHEN sortOrder = 'NEWONTOP' THEN  

SELECT OPC.TOPICID, OPC.CAUSE_POST_ID,OPC.COMMENT_ID
, OPC.COMMENT_BY_USERID, OU.USERNAME COMMENT_BY_UNAME
, OU.DP_URL, OPC.COMMENT_CONTENT, OPC.COMMENT_DTM
, OPC.EMBEDDED_CONTENT, OPC.EMBEDDED_FLAG
, (CASE WHEN OPC.COMMENT_TYPE = 'CONP' THEN OPC.COMMENT_ID ELSE OPC.PARENT_COMMENT_ID END ) PARENT_COMMENT_ID
, OPC.PARENT_COMMENT_UNAME, OPC.PARENT_COMMENT_DTM
, OPC.PARENT_COMMENT_CONTENT, OPC.PARENT_MEDIA_CONTENT
, OPC.PARENT_COMMENT_BYUID, OPC.COMMENT_TYPE
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG
FROM OPN_POST_COMMENTS OPC, OPN_USERLIST OU
WHERE OPC.COMMENT_BY_USERID = OU.USERID
AND OPC.COMMENT_BY_USERID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART = B.CART )
AND OPC.PARENT_COMMENT_BYUID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.CART = B.CART )
AND OPC.CAUSE_POST_ID = postid
-- AND OPC.CLEAN_COMMENT_FLAG = 'Y'
AND OPC.COMMENT_DELETE_FLAG = 'N'
ORDER BY  OPC.COMMENT_DTM DESC ;


WHEN sortOrder = 'OLDONTOP' THEN 

SELECT OPC.TOPICID, OPC.CAUSE_POST_ID,OPC.COMMENT_ID
, OPC.COMMENT_BY_USERID, OU.USERNAME COMMENT_BY_UNAME
, OU.DP_URL, OPC.COMMENT_CONTENT, OPC.COMMENT_DTM
, OPC.EMBEDDED_CONTENT, OPC.EMBEDDED_FLAG
, (CASE WHEN OPC.COMMENT_TYPE = 'CONP' THEN OPC.COMMENT_ID ELSE OPC.PARENT_COMMENT_ID END ) PARENT_COMMENT_ID
, OPC.PARENT_COMMENT_UNAME, OPC.PARENT_COMMENT_DTM
, OPC.PARENT_COMMENT_CONTENT, OPC.PARENT_MEDIA_CONTENT
, OPC.PARENT_COMMENT_BYUID, OPC.COMMENT_TYPE
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG
FROM OPN_POST_COMMENTS OPC, OPN_USERLIST OU
WHERE OPC.COMMENT_BY_USERID = OU.USERID
AND OPC.COMMENT_BY_USERID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID  AND A.CART = B.CART)
AND OPC.PARENT_COMMENT_BYUID IN (SELECT DISTINCT B.USERID  FROM
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID AND USERID = ORIG_UID) A ,
(SELECT USERID, TOPICID, CART, KEYID FROM OPN_USER_CARTS 
WHERE TOPICID = TID  
AND USERID NOT IN (SELECT ON_USERID FROM OPN_USER_USER_ACTION 
WHERE TOPICID = TID AND BY_USERID = ORIG_UID AND ACTION_TYPE IN ('KO', 'CKO'))
) B
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID  AND A.CART = B.CART)
AND OPC.CAUSE_POST_ID = postid
-- AND OPC.CLEAN_COMMENT_FLAG = 'Y'
AND OPC.COMMENT_DELETE_FLAG = 'N'
ORDER BY  OPC.COMMENT_DTM ASC ;


 END CASE ;
  
END//
DELIMITER ;

-- -- convertGuestUserAppNew

 DELIMITER //
DROP PROCEDURE IF EXISTS convertGuestUserAppNew //
CREATE PROCEDURE convertGuestUserAppNew(guestuuid varchar(45), newUName varchar(20), username varchar(100)
, userid varchar(60), dp_url VARCHAR(255),CONVERTTYPE VARCHAR(40))
thisproc:BEGIN
/* 	26/03/2020 Rohit: -Create this store proc to register the Guest user 
	to the data based on there register type like facebook or google
	there are two case one for fb and one for google 
	Call convertGuestUserAppNew("uuid","rohit","Androu7867","userid","dp_url","com.facebook");
	Return the created user list.

	07/09/2020 AST: Added handling of the case where guest user comes back again and again
    in order to circumvent the 5 profiles per FG id.

 */
DECLARE ISGUEST, USEREXISTS INT;
DECLARE status varchar(30);
SET status= "error";

SET ISGUEST = (SELECT COUNT(*) FROM OPN_USERLIST 
WHERE USER_UUID = guestuuid AND USER_TYPE = 'GUEST');

SET USEREXISTS = (SELECT COUNT(1) FROM OPN_USERLIST UU1 WHERE UU1.FB_USERID = userid 
OR UU1.G_USERID = userid OR UU1.A_USERID = userid) ;

CASE WHEN USEREXISTS > 0 THEN 

SELECT 'YES' existFlag ; LEAVE thisproc ;

WHEN USEREXISTS  = 0 THEN

CASE WHEN ISGUEST = 1 THEN

CASE WHEN CONVERTTYPE = 'com.facebook' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName, U.FB_USER_NAME =username
, U.FB_USER_FLAG= 'Y', U.FB_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;

WHEN CONVERTTYPE= 'com.google' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName,U.G_UNAME =username
,U.FB_USER_FLAG= 'G', U.G_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;

WHEN CONVERTTYPE= 'com.apple' THEN
UPDATE OPN_USERLIST U SET U.USERNAME = newUName,U.A_UNAME =username
,U.FB_USER_FLAG= 'A', U.A_USERID = userid,U.DP_URL = dp_url
,  U.P_Q_CHANGE_DT = NOW(), U.USER_TYPE = 'USER'
 WHERE U.USER_UUID = guestuuid AND U.USERID>0;
 
END CASE ;

SELECT U.USERNAME, U.USERID, U.USER_UUID, U.USER_TYPE, U.COUNTRY_CODE 
FROM OPN_USERLIST U WHERE U.USER_UUID = guestuuid;

WHEN ISGUEST = 0 THEN
SELECT status;
END CASE ;

END CASE ;

END //
DELIMITER ;

-- 
-- copyPostToTID

 DELIMITER //
DROP PROCEDURE IF EXISTS copyPostToTID //
CREATE PROCEDURE copyPostToTID(postid INT, totid INT, tokid INT, touname varchar(40))
BEGIN

/* 	

	10192020 AST: Initial Creation for copying a post from one TID to another TID
	This proc is internal. It will be used only for copying any interesting news item (post) to Trending News KW
    Specific usernames for the three ccodes will be created. They will be used only for posting the Trending News
                  

*/

declare UIDFROM, UIDTO, FROMCARTCNT, TOCARTCNT, TIDTO INT;
declare UNAMEFROM, UNAMETO varchar(40) ;
declare CCODEFROM, CCODETO varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT U1.USERID, U1.USERNAME, U1.COUNTRY_CODE INTO UIDFROM, UNAMEFROM, CCODEFROM 
FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuidFrom ;

SELECT U2.USERID, U2.USERNAME, U2.COUNTRY_CODE INTO UIDTO, UNAMETO, CCODETO 
FROM OPN_USERLIST U2 WHERE U2.USER_UUID = uuidTo ;

SET TIDTO = (SELECT IFNULL(MAX(TOPICID),0) FROM OPN_USER_CARTS WHERE USERID = UIDFROM 
AND CREATION_DTM = (SELECT MAX(CREATION_DTM) FROM OPN_USER_CARTS WHERE USERID = UIDFROM) ) ;
SET TOCARTCNT = (SELECT COUNT(1) FROM OPN_USER_CARTS WHERE USERID = UIDTO) ;

/* 	When the Inviter has an empty cart - then the invitee carts are also kept empty or unchanged */

CASE WHEN tid = 0 THEN

CASE WHEN TIDTO = 0 THEN 

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID
, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom
, NOW(), 'copyUserCarts', CONCAT(UIDTO, '-', 'inviter killed his carts'));

SELECT uuidTo, 0, 0 ;

WHEN TIDTO <> 0 THEN

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts', CONCAT(UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, 0 ;

END CASE ;

WHEN tid <> 0 THEN

CASE WHEN postID = 0 THEN 

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts', CONCAT(UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, 0 ;

WHEN  postID <> 0 THEN 

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts', CONCAT(UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, postID ;

END CASE ;

END CASE ;


END //
DELIMITER ;

-- -- copyUserCarts

DROP PROCEDURE IF EXISTS `copyUserCarts`;
DELIMITER //
CREATE PROCEDURE copyUserCarts(uuidFrom varchar(45), uuidTo varchar(45), tid INT, postID INT)
BEGIN

/* 	

	07/13/2020 AST: Initial Creation for copying an inviter user's carts to invitee user
					Handling the cases where the inviter kills the cart after the invite
                    
	08/09/2020 AST: COnfirmed
	12/09/2020 AST: Added enhannced BHV LOG. Added OU update to track the invites

*/

declare UIDFROM, UIDTO, FROMCARTCNT, TOCARTCNT, TIDTO INT;
declare UNAMEFROM, UNAMETO varchar(40) ;
declare CCODEFROM, CCODETO varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT U1.USERID, U1.USERNAME, U1.COUNTRY_CODE INTO UIDFROM, UNAMEFROM, CCODEFROM 
FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuidFrom ;

SELECT U2.USERID, U2.USERNAME, U2.COUNTRY_CODE INTO UIDTO, UNAMETO, CCODETO 
FROM OPN_USERLIST U2 WHERE U2.USER_UUID = uuidTo ;

SET TIDTO = (SELECT IFNULL(MAX(TOPICID),0) FROM OPN_USER_CARTS WHERE USERID = UIDFROM 
AND CREATION_DTM = (SELECT MAX(CREATION_DTM) FROM OPN_USER_CARTS WHERE USERID = UIDFROM) ) ;
SET TOCARTCNT = (SELECT COUNT(1) FROM OPN_USER_CARTS WHERE USERID = UIDTO) ;

/* 	When the Inviter has an empty cart - then the invitee carts are also kept empty or unchanged */

CASE WHEN tid = 0 THEN

CASE WHEN TIDTO = 0 THEN 

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID
, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom
, NOW(), 'copyUserCarts', CONCAT(UIDFROM, '-', UNAMEFROM, '-', UIDTO, '-', UNAMETO, '-', 'inviter killed his carts'));

SELECT uuidTo, 0, 0 ;

WHEN TIDTO <> 0 THEN

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

UPDATE OPN_USERLIST SET INVITEE_FLAG = 'Y', INVITER_UNAME = UNAMEFROM, INVITER_UID = UIDFROM
WHERE USERID = UIDTO ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts'
, CONCAT(UIDFROM, '-', UNAMEFROM, '-', UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, 0 ;

END CASE ;

WHEN tid <> 0 THEN

CASE WHEN postID = 0 THEN 

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

UPDATE OPN_USERLIST SET INVITEE_FLAG = 'Y', INVITER_UNAME = UNAMEFROM, INVITER_UID = UIDFROM
WHERE USERID = UIDTO ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts'
, CONCAT(UIDFROM, '-', UNAMEFROM, '-', UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, 0 ;

WHEN  postID <> 0 THEN 

DELETE FROM OPN_USER_INTERESTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, CREATION_DTM, USERNAME)
SELECT UIDTO, uuidTo, INTEREST_ID, INTEREST_NAME
, INTEREST_CODE, NOW(), UNAMETO FROM OPN_USER_INTERESTS WHERE USERID = UIDFROM ;

DELETE FROM OPN_USER_CARTS WHERE USERID = UIDTO ;

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
SELECT UIDTO, TOPICID, KEYID, CART, NOW(), NOW() FROM OPN_USER_CARTS WHERE USERID = UIDFROM ;

UPDATE OPN_USERLIST SET INVITEE_FLAG = 'Y', INVITER_UNAME = UNAMEFROM, INVITER_UID = UIDFROM
WHERE USERID = UIDTO ;

/* USER BHV LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAMEFROM, UIDFROM, uuidFrom, NOW(), 'copyUserCarts'
, CONCAT(UIDFROM, '-', UNAMEFROM, '-', UIDTO, '-', UNAMETO));

SELECT uuidTo, TIDTO, postID ;

END CASE ;

END CASE ;


END//
DELIMITER ;

-- -- createAppleUserTokenApp

USE `opntprod`;
DROP procedure IF EXISTS `createAppleUserTokenApp`;

DELIMITER $$
USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `createAppleUserTokenApp`
(username varchar(30), country_code varchar(5), fname varchar(150)
, lname varchar(150), Apple_userid varchar(100),dp_url varchar(500), device_serial VARCHAR(40))
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
    10172020 AST: Recreated with Default Cart assignment 
    		12102020 AST: Default Cart is done through vars now - instead of hard -code
        This is to ensure that the ptoc will work in any db instance
    */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;

CASE WHEN Apple_userid IS NOT NULL THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('createAppleUserTokenApp', NOW(), 'USERNAME', username) ;

INSERT INTO OPN_USERLIST(USERNAME, USER_UUID, CREATION_DATE, COUNTRY_CODE, FIRST_NAME
, LAST_NAME, A_USERID, FB_USER_FLAG, DP_URL)
VALUES (username, UUID(), NOW(), country_code, fname, lname, Apple_userid, 'A' , dp_url);

SET DEVICE_UUID = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = username);

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUseridFromUsername(username), DEVICE_UUID, NOW(), device_serial, 'Y');

END CASE;

/* 10172020 AST: Adding the default Cart below */

set UID = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USERNAME = username) ;

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

/* 10172020 AST: END OF : Adding the default Cart */

SELECT U.USER_UUID AS USERID, U.USERNAME, U.COUNTRY_CODE FROM OPN_USERLIST U WHERE U.USERNAME = username;

END$$

DELIMITER ;

-- 

-- createFBUserTokenApp

 DELIMITER //
DROP PROCEDURE IF EXISTS createFBUserTokenApp //
CREATE PROCEDURE createFBUserTokenApp(username varchar(30), country_code varchar(5), fb_username varchar(100)
, fb_userid varchar(20), device_serial VARCHAR(40), dp_url VARCHAR(255))
BEGIN

/* 04012018 AST: Added insret into proc log 
    Added insert into device log 
    
        10172020 AST: Recreated with Default Cart assignment  
            		12102020 AST: Default Cart is done through vars now - instead of hard -code
        This is to ensure that the ptoc will work in any db instance
        */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;

CASE WHEN fb_userid IS NOT NULL THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('createFBUserTokenApp', NOW(), 'USERNAME', username) ;

INSERT INTO OPN_USERLIST(USERNAME, USER_UUID, CREATION_DATE, COUNTRY_CODE, FB_USER_NAME, FB_USERID, FB_USER_FLAG,DP_URL)
VALUES (username, UUID(), NOW(), country_code, fb_username, fb_userid, 'Y',dp_url );

SET DEVICE_UUID = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = username);

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUseridFromUsername(username), DEVICE_UUID, NOW(), device_serial, 'Y');

END CASE;

/* 10172020 AST: Adding the default Cart below */

set UID = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USERNAME = username) ;

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

/* 10172020 AST: END OF : Adding the default Cart */

SELECT U.USER_UUID AS USERID, U.USERNAME, U.COUNTRY_CODE FROM OPN_USERLIST U WHERE U.USERNAME = username;
END //
DELIMITER ;

-- 

-- createGoogleUserTokenApp

 DELIMITER //
DROP PROCEDURE IF EXISTS createGoogleUserTokenApp //
CREATE PROCEDURE createGoogleUserTokenApp(username varchar(30), country_code varchar(5), fname varchar(150)
, lname varchar(150), google_email varchar(250), dp_url varchar(500) 
, Google_username varchar(100), Google_userid varchar(45), device_serial VARCHAR(40))
BEGIN

/* 04012018 AST: Added insret into proc log 
    Added insert into device log 
    
    10172020 AST: Recreated with Default Cart assignment 
        		12102020 AST: Default Cart is done through vars now - instead of hard -code
        This is to ensure that the ptoc will work in any db instance
    
    */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;


CASE WHEN Google_userid IS NOT NULL THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('createGoogleUserTokenApp', NOW(), 'USERNAME', username) ;

INSERT INTO OPN_USERLIST(USERNAME, USER_UUID, CREATION_DATE, COUNTRY_CODE, FIRST_NAME
, LAST_NAME, EMAIL_ADDR, G_UNAME, G_USERID, FB_USER_FLAG, DP_URL)
VALUES (username, UUID(), NOW(), country_code, fname, lname, google_email, Google_username, Google_userid, 'G' , dp_url);

SET DEVICE_UUID = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = username);

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUseridFromUsername(username), DEVICE_UUID, NOW(), device_serial, 'Y');

END CASE;

/* 10172020 AST: Adding the default Cart below */

set UID = (SELECT U.USERID FROM OPN_USERLIST U WHERE U.USERNAME = username) ;

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

/* 10172020 AST: END OF : Adding the default Cart */

SELECT U.USER_UUID AS USERID, U.USERNAME, U.COUNTRY_CODE FROM OPN_USERLIST U WHERE U.USERNAME = username;

END //
DELIMITER ;

-- 

-- 

DROP PROCEDURE IF EXISTS `createGuestUserApp`;
DELIMITER //
CREATE   PROCEDURE `createGuestUserApp`(devicename varchar(600), country_code varchar(5), device_serial VARCHAR(40))
BEGIN

/*    10172020 AST: Recreated with Default Cart assignment */


DECLARE RND4DIGIT, RND6DIGIT, DNAMEOK, G1OK, G2OK INT ;
DECLARE GUESTUNAME1, GUESTUNAME2 VARCHAR(30) ;
/* 04012018 AST: The below portion is added in order to track the device_serial of the user */

DECLARE DEVICE_UUID VARCHAR(45) ;
declare UID, T1, T2, T3, T4, T5, T8, T9, T10 INT ;

/* 04012018 AST: End of device_serial addition for declarations */

SET T1 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'POLNEWS' ) ;
SET T2 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sportsnews2' ) ;
SET T3 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'sciencenews3' ) ;
SET T4 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'businessnews4' ) ;
SET T5 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'entertainmentnews5' ) ;
SET T8 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'opnt' ) ;
SET T9 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'trendingnews9' ) ;
SET T10 = (SELECT KEYID FROM OPN_P_KW WHERE SCRAPE_TAG2 = 'CELEBNEWS' ) ;

SET RND4DIGIT = FLOOR(RAND()* (9999-1000) +1000);
SET RND6DIGIT = FLOOR(RAND()* (999999-100000) +100000);

SET GUESTUNAME1 = CONCAT(SUBSTR(devicename,1,6), RND4DIGIT);
SET GUESTUNAME2 = CONCAT(SUBSTR(devicename,1,6), RND6DIGIT);

SET DNAMEOK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6));
SET G1OK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1);
-- SET G2OK = (SELECT COUNT(*) FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2);

CASE WHEN DNAMEOK = 0 THEN

INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE) 
VALUES (SUBSTR(devicename,1,6), AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST');

/* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6) )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6) ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case DNAMEOK = 0 */

/* 10172020 AST: Adding the default Cart below */

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;


/* 10172020 AST: END OF : Adding the default Cart */

SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = SUBSTR(devicename,1,6);

WHEN DNAMEOK = 1 THEN

	CASE WHEN G1OK = 0 THEN
    
    INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE) 
	VALUES (GUESTUNAME1, AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST');
    
    /* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1 )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1 ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case G1OK = 0 */

/* 10172020 AST: Adding the default Cart below */

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

/* 10172020 AST: END OF : Adding the default Cart */
    
    SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME1;
    
		WHEN G1OK = 1 THEN 
            
            INSERT INTO OPN_USERLIST (USERNAME, PASSWORD, USER_UUID, CREATION_DATE, COUNTRY_CODE,FB_USER_FLAG, USER_TYPE) 
			VALUES (GUESTUNAME2, AES_ENCRYPT('dummypassword', '290317'), UUID(), NOW(), country_code,'N', 'GUEST');
            
                /* 04012018 AST: The below portion is added in order to track the device_serial of the user */

-- SET DEVICE_UUID = (SELECT USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2 )  ;

SELECT USER_UUID, USERID INTO DEVICE_UUID, UID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2 ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(DEVICE_UUID), DEVICE_UUID, NOW(), device_serial, 'Y');

/* 04012018 AST: End of device_serial addition for actual insert for case G1OK = 1 */

/* 10172020 AST: Adding the default Cart below */

INSERT INTO OPN_USER_CARTS(USERID, KEYID, CART, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (UID, T1, 'L', 1, NOW(), NOW()), (UID, T10, 'L', 10, NOW(), NOW()) 
, (UID, T5, 'L', 5, NOW(), NOW()), (UID, T3, 'L', 3, NOW(), NOW())
, (UID, T2, 'L', 2, NOW(), NOW()), (UID, T4, 'L', 4, NOW(), NOW())
, (UID, T8, 'L', 8, NOW(), NOW()), (UID, T9, 'L', 9, NOW(), NOW())
;

/* 10172020 AST: END OF : Adding the default Cart */
            
                SELECT USERNAME, USER_UUID FROM OPN_USERLIST WHERE USERNAME = GUESTUNAME2;
            
            END CASE;
            
		END CASE ;

END//
DELIMITER ;

-- -- createSearchKW

DELIMITER //
DROP PROCEDURE IF EXISTS createSearchKW //
CREATE PROCEDURE createSearchKW(tid INT, uuid varchar(45), userKW varchar(60), usercart varchar(3))
THISPROC: BEGIN

/*
06/17/2018 AST: Initial Proc creation for a new KW being created through the search screen
08/24/2018 AST: Added SCRAPE_TAG1, SCRAPE_TAG2 to INSERT INTO OPN_KW_TAGS
10/31/2018 AST: SCRAPE_TAG2 in the INSERT replaced with CONCAT(LOWER(REPLACE(KEYWORDS, ' ', '') ),TOPICID)
This is done to deal with the proposed change where the opn_p_kw will have keywords + topicid as composite key

CALL createSearchKW(9, bringUUID(1017079), 'IND', 'Mamata Didi and Congress Sleeping Together Again', 'H') ;

The Proc does 3 things: 
- It creates the new KW
- It puts the new KW in the creating user's cart (that is why there is the usercart param)
- And it also creates a post for the creating user with the new KW as the post content

04/10/2019 AST: Changed the TNAME to case statement - because earlier it was using the TOPICNAME from opn_topics
and that was causing issues in the downstream tagging and STP processes.

05/31/2020 AST: Removing the the ccode form input params. Also replaced newPost with newPostWithMedia call.

06/14/2020 AST: Added WHEN TOPICID = 11 THEN 'HEALTH' 
08/19/2020 Kapil: Confirmed

 */

declare  orig_uid , NEWKID INT;
DECLARE UNAME, TNAME VARCHAR(30) ;
DECLARE STAG24LLIST VARCHAR(60) ;
DECLARE ccode VARCHAR(5) ;
DECLARE SUSP VARCHAR(5) ;

SELECT  USER_SUSPEND_FLAG INTO SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;
IF SUSP = 'Y' THEN LEAVE thisproc ;
ELSE

SET TNAME := (SELECT CASE WHEN TOPICID = 1 THEN 'POLITICS'
WHEN TOPICID = 2 THEN 'SPORTS' 
WHEN TOPICID = 3 THEN 'SCIENCE'
WHEN TOPICID = 4 THEN 'BUSINESS' 
WHEN TOPICID = 5 THEN 'ENT'
WHEN TOPICID = 6 THEN 'RELIGION' 
WHEN TOPICID = 7 THEN 'LIFE'
WHEN TOPICID = 8 THEN 'MISC' 
WHEN TOPICID = 9 THEN 'TREND'
WHEN TOPICID = 10 THEN 'CELEB' 
WHEN TOPICID = 11 THEN 'HEALTH' 

END  FROM OPN_TOPICS WHERE TOPICID = tid );

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE INTO orig_uid, UNAME, ccode FROM OPN_USERLIST OU WHERE OU.USER_UUID = uuid ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'createSearchKW', CONCAT(tid, '-', userKW));


INSERT INTO OPN_P_KW(TOPICID, KEYWORDS, KW_TRIM, COUNTRY_CODE, DISPLAY_SEQ, CREATION_DTM
, LAST_UPDATE_DTM, CLUSTER_PRIO, ORIGIN_COUNTRY_CODE, NEW_KW_FLAG, SCRAPE_TAG1, SCRAPE_TAG2,
USER_CREATED_KW, CREATED_BY_UID, CREATED_BY_UUID, CREATED_BY_UNAME, CLEAN_KW_FLAG)
VALUES (tid, userKW, CONCAT(UPPER(REPLACE(KEYWORDS, ' ', '') ), TOPICID) , ccode, 5, NOW(), NOW(), 5, ccode, 'N'
, UPPER(TNAME), CONCAT(LOWER(REPLACE(KEYWORDS, ' ', '') ),TOPICID), 'Y', orig_uid, uuid, UNAME, 'Y' ); 

SET NEWKID = (SELECT MAX(KEYID) FROM OPN_P_KW WHERE KEYWORDS  = userKW AND TOPICID = tid) ;
SET STAG24LLIST = (SELECT SCRAPE_TAG2 FROM OPN_P_KW WHERE KEYID = NEWKID) ;

INSERT INTO OPN_USER_CARTS(CART, KEYID, USERID, TOPICID, CREATION_DTM, LAST_UPDATE_DTM)
VALUES( usercart, NEWKID, orig_uid, tid, NOW(), NOW()) ON DUPLICATE KEY UPDATE CART = usercart;

/* 03/11/2019  removing the clustering section - because it is not mneeded anymore after SQL-based network  */
 -- removed on 03/11/2019 CALL NEWCART_TOP_NOTAILOR(uuid, tid) ;

INSERT INTO OPN_KW_TAGS(TOPICID, KEYID, KEYWORDS, KW_TRIM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE
, SCRAPE_TAG1, SCRAPE_TAG2, SCRAPE_DESIGN_DONE, KW_DTM)
SELECT TOPICID, KEYID, KEYWORDS, KW_TRIM, COUNTRY_CODE, ORIGIN_COUNTRY_CODE
, SCRAPE_TAG1, SCRAPE_TAG2, 'N', CREATION_DTM FROM OPN_P_KW WHERE KEYID = NEWKID ;

CALL newPostWithMedia(tid, uuid, userKW, '', 'N', '', 'N') ;

/* 03/11/2019  Adding new users for the new KW - because we need at least 25-40 users in H and L in order to distribute the tagged posts  */

CALL ADD_NUSERS_4K1(NEWKID , ccode,  tid) ;

-- ADD_NUSERS_4K1 call added on 03/11/2019

CALL OPN_SCRAPE_DESIGN_GEN(tid, NEWKID, STAG24LLIST, userKW ) ;
END IF ;


END //
DELIMITER ;

-- -- deleteComment

 DELIMITER //
DROP PROCEDURE IF EXISTS deleteComment //
CREATE PROCEDURE deleteComment(userid varchar(45), commentID INT)
THISPROC: BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 CALL deleteComment(userid varchar(45), comment_id INT) 
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid, cbyuid INT;
DECLARE UNAME VARCHAR(40) ;
SET SQL_SAFE_UPDATES = 0;

SELECT U.USERID, U.USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST U WHERE U.USER_UUID = userid ;
SELECT COMMENT_BY_USERID INTO cbyuid FROM OPN_POST_COMMENTS WHERE COMMENT_ID = commentID ;

/* User Behavior Log Section */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'deleteComment', concat('COMMENT_ID',' = ',commentID));

/* End of User Behavior Log Section */

CASE WHEN orig_uid <> cbyuid THEN LEAVE THISPROC;

WHEN orig_uid = cbyuid THEN

UPDATE OPN_POST_COMMENTS SET COMMENT_DELETE_FLAG = 'Y', COMMENT_DELETE_DTM = NOW() 
, COMMENT_CONTENT = '-- Comment Deleted by User -- ', EMBEDDED_CONTENT = '', EMBEDDED_FLAG = 'N'
, MEDIA_CONTENT = '', MEDIA_FLAG = 'N'
WHERE OPN_POST_COMMENTS.COMMENT_ID = commentID ;

UPDATE OPN_POST_COMMENTS SET PARENT_COMMENT_CONTENT = '-- Comment Deleted by User -- '
, PARENT_MEDIA_CONTENT = '', PARENT_MEDIA_FLAG = 'N' 
WHERE OPN_POST_COMMENTS.PARENT_COMMENT_ID = commentID ;

END CASE ;

END  //
DELIMITER ;

-- -- deletePost

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS deletePost //
CREATE PROCEDURE deletePost(userid varchar(45), postid INT)
BEGIN

/* 04/25/2020 AST: Rebuilt: brought the comment inside the body
 CALL deletePost(userid varchar(45), postid INT) 
 08/11/2020 Kapil: Confirmed
 */

declare  orig_uid INT;

SET orig_uid := (SELECT  bringUserid(userid));

DELETE FROM OPN_POSTS  WHERE OPN_POSTS.POST_ID = postid AND OPN_POSTS.POST_BY_USERID = orig_uid ;


END //
DELIMITER ;

-- -- getAllTopicsCartsByUserByCountry

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getAllTopicsCartsByUserByCountry //
CREATE DEFINER=`root`@`%` PROCEDURE `getAllTopicsCartsByUserByCountry`(topicid INT, userid varchar(45), country_code VARCHAR(5))
BEGIN

/*  
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;

SET orig_uid := (SELECT  bringUserid(userid));
SET UNAME := (SELECT U5.USERNAME FROM OPN_USERLIST U5 WHERE U5.USER_UUID = userid) ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'getAllTopicsCartsByUserByCountry', CONCAT(topicid,'-',country_code));


/* end of use action tracking */


/* 04/05/2019 AST: Changed the ordering of the KW display depending on the TID 
    04/11/2019 AST: Changed the ordering on the first case (topicid in 5,9,10) to have IRANK numbers 4 for the cart and all others 5.
    This is done so that the ranking by KEYID DESC can take effect.
    The ordering is NOT changed on the rest of the topics because still considering the ranking first ordered by the global vs local etc.
    
    Also under consideration: remove the dichotomy of ORIGIN_COUNTRY_CODE VS COUNTRY_CODE.
    This is because the concept was introduced due to the lack of the Search and Create KW Feature. 
    
    Now with both the capabilities in place, no user can create a GGG KW while being a USA or IND user.
    
    We should consider updating all KW's with their country_code = Origin_country_code.
    
    That way, no USA user would be seeing the IND keywords at the top.
    
     12/17/2019 AST: Removed @ from code
     
     05/10/2020 AST: Including a filter where Private KWs will not be displayed in the list of non-selected KWs
    
*/

CASE WHEN topicid IN (5,9,10) THEN 

SELECT QQQ.USERID, QQQ.TOPICID, QQQ.CART, QQQ.KEYID, QQQ.KEYWORDS, QQQ.IRANK FROM (
SELECT UC2.USERID, UC2.TOPICID, UC2.CART, D.KEYID, D.KEYWORDS, 4 IRANK,  TCOUNT FROM        
(SELECT K.KEYID, K.KEYWORDS,'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K, OPN_USER_CARTS UC
        WHERE K.TOPICID = topicid -- AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN ('IND')
        AND K.KEYID = UC.KEYID
     AND K.KEYID  IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
        GROUP BY K.KEYID, K.KEYWORDS) D, OPN_USER_CARTS UC2 
        WHERE D.KEYID = UC2.KEYID AND UC2.USERID = orig_uid
        UNION ALL 
        SELECT orig_uid USERID, topicid TOPICID, ' ' CART, KEYID, KEYWORDS, IRANK, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
     /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */     
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN (country_code) AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
         AND K.ORIGIN_COUNTRY_CODE NOT IN ('GGG')
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE IN ('GGG')  AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE NOT IN ('GGG', country_code) AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY IRANK, CART, KEYID DESC 
                )QQQ;
                
WHEN  topicid NOT IN (5,9,10) THEN       

SELECT QQQ.USERID, QQQ.TOPICID, QQQ.CART, QQQ.KEYID, QQQ.KEYWORDS, QQQ.IRANK FROM (
SELECT UC2.USERID, UC2.TOPICID, UC2.CART, D.KEYID, D.KEYWORDS, 4 IRANK,  TCOUNT FROM        
(SELECT K.KEYID, K.KEYWORDS,'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K, OPN_USER_CARTS UC
        WHERE K.TOPICID = topicid -- AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN ('IND')
        AND K.KEYID = UC.KEYID
     AND K.KEYID  IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
        GROUP BY K.KEYID, K.KEYWORDS) D, OPN_USER_CARTS UC2 
        WHERE D.KEYID = UC2.KEYID AND UC2.USERID = orig_uid
        UNION ALL 
        SELECT orig_uid USERID, topicid TOPICID, ' ' CART, KEYID, KEYWORDS, IRANK, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 5 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN ('GGG') AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 6 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE  IN (country_code) AND K.ORIGIN_COUNTRY_CODE  IN (country_code)
         AND K.ORIGIN_COUNTRY_CODE NOT IN ('GGG')
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 7 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE IN ('GGG')  AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 8 IRANK, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC ON  K.KEYID = UC.KEYID
        WHERE K.TOPICID = topicid AND K.COUNTRY_CODE NOT IN ('GGG', country_code) AND K.ORIGIN_COUNTRY_CODE NOT IN (country_code)
     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid )
          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */    
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY IRANK, CART, TCOUNT DESC 
                )QQQ;
END CASE ;

END //
DELIMITER ;

-- -- getCartTopics

DELIMITER //
DROP PROCEDURE IF EXISTS getCartTopics //
CREATE PROCEDURE getCartTopics(uuid varchar(50))
BEGIN

-- 121817 TRYING THE RE-ORDER USING CODE COLUMN

-- SELECT * FROM OPN_TOPICS;
/* 
 08/11/2020 Kapil: Confirmed
 */

DECLARE UID INT ;
DECLARE UNAME, UTYPE VARCHAR(40) ;

SELECT USERID, USERNAME, USER_TYPE INTO UID, UNAME, UTYPE FROM OPN_USERLIST WHERE USER_UUID = uuid ;

SELECT DISTINCT C1.TOPICID CTOPIC , T.TOPIC, T.CODE, 'A' SRC
FROM OPN_USER_CARTS C1, OPN_TOPICS T WHERE C1.TOPICID = T.TOPICID AND C1.USERID = UID 
UNION ALL
SELECT TOPICID, TOPIC, CODE, 'B' SRC FROM OPN_TOPICS WHERE TOPICID NOT IN 
(SELECT DISTINCT TOPICID FROM OPN_USER_CARTS WHERE USERID = UID)
ORDER BY SRC, CODE
;



END //
DELIMITER ;

-- -- getCommentCount

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
-- getKOContent

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getKOContent //
CREATE PROCEDURE getKOContent(uname varchar(40) )
BEGIN

/* 
09/07/2020 AST: initial Creation
		this proc is used for getting the posts that resulted in KO for a user

 */

declare UID INT ;
DECLARE UUID VARCHAR(45) ;
DECLARE UTYPE VARCHAR(3) ;
DECLARE UDEVICE VARCHAR(200) ;
DECLARE UEMAIL, UFBID, UGID, UAID VARCHAR(100) ;

SELECT USERID, USER_UUID, FB_USER_FLAG, FB_USERID, IDENTIFIER_TOKEN, G_USERID, EMAIL_ADDR, A_USERID
INTO UID, UUID, UTYPE, UFBID, UDEVICE, UGID, UEMAIL, UAID FROM OPN_USERLIST  WHERE USERNAME = uname ;

SELECT ID, DTM, CONTENT, CTYPE FROM (
SELECT P.POST_ID ID, P.POST_DATETIME DTM, P.POST_CONTENT CONTENT, 'POST' CTYPE
FROM OPN_POSTS P 
, (SELECT DISTINCT CAUSE_POST_ID FROM OPN_USER_USER_ACTION WHERE ON_USERID = UID AND ACTION_COMMENT IN ('PKO') ) A2
WHERE A2.CAUSE_POST_ID = P.POST_ID 
UNION ALL
SELECT C.COMMENT_ID ID, C.COMMENT_DTM DTM, C.COMMENT_CONTENT CONTENT, 'COMMENT' CTYPE
FROM OPN_POST_COMMENTS C 
, (SELECT DISTINCT CAUSE_COMMENT_ID FROM OPN_USER_USER_ACTION WHERE ON_USERID = UID AND ACTION_COMMENT IN ('CKO') ) A2
WHERE A2.CAUSE_COMMENT_ID = C.COMMENT_ID 
)Q ORDER BY DTM DESC LIMIT 25
;
 



END //
DELIMITER ;

-- -- getNetworkDetails

DELIMITER //
DROP PROCEDURE IF EXISTS getNetworkDetails //
CREATE PROCEDURE getNetworkDetails(uc1 varchar(30), uc2 varchar(45), tid INT)
BEGIN

/*
05/12/2020 AST: Bringing SQL comments inside and removing @ from Vars
Also, removed the AND UC1.CART = UC2.CART restriction so that this proc also shows 
the opposite cart matches. uc2 is the logged in user. uc1 is the user whose cart
is matching and we only know his username.

07/09/2020 AST: Added MATCH_PERCENT, MDTM (Max DTM) to populate the new UI

08/11/2020 Kapil: Confirmed

 08/20/2020 AST: Added OPN_USERLIST.CHAT_FLAG to turn the chat icon on/off
		08/25/2020 AST: Changed the CHF logic to deal with U1 and U2 chat_flag values

*/

declare  orig_uid2, orig_uid1, NUMR, DENOM, PRCNT INT;
DECLARE MDTM DATETIME ;
-- DECLARE CHF VARCHAR(3) ;
DECLARE UNAME VARCHAR(40) ;
-- DECLARE PRCNT DOUBLE ;

SET orig_uid1 = (SELECT  bringUseridFromUsername(uc1));

SELECT USERID, USERNAME INTO orig_uid2, UNAME FROM OPN_USERLIST WHERE USER_UUID = uc2 ;

/* USER BH LOG */

 INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
 VALUES(UNAME, orig_uid2, uc2, NOW(), 'getNetworkDetails', concat(orig_uid2, '-', uc1) );
 
 /* END USER BH LOG */

SET NUMR = (SELECT COUNT(1) FROM OPN_USER_CARTS UU1, OPN_USER_CARTS UU2
WHERE UU1.TOPICID = UU2.TOPICID AND UU1.KEYID = UU2.KEYID
AND UU2.USERID = orig_uid2 AND UU1.USERID = orig_uid1
AND UU1.TOPICID = tid ) ;

SELECT COUNT(1), MAX(LAST_UPDATE_DTM) INTO DENOM, MDTM FROM OPN_USER_CARTS UU3 
WHERE UU3.USERID = orig_uid2 AND UU3.TOPICID = tid ;

SELECT T1.TOPIC, UC1.CART, K2.KEYWORDS, ROUND(NUMR*100/DENOM, 0) MATCH_PERCENT, MDTM 
, CASE WHEN UL2.CHAT_FLAG = 'N' THEN 'N' ELSE UL1.CHAT_FLAG END CHF
FROM OPN_USER_CARTS UC1, OPN_TOPICS T1, OPN_P_KW K1, OPN_USERLIST UL1,
OPN_USER_CARTS UC2, OPN_TOPICS T2, OPN_P_KW K2, OPN_USERLIST UL2 
WHERE UC1.USERID = UL1.USERID
AND UC1.TOPICID = T1.TOPICID
AND UC1.KEYID = K1.KEYID
AND UC1.USERID = orig_uid1
AND UC1.TOPICID = tid
AND UC2.USERID = UL2.USERID
AND UC2.TOPICID = T2.TOPICID
AND UC2.KEYID = K2.KEYID
AND UC2.USERID = orig_uid2
-- AND UC1.CART = UC2.CART
AND UC1.KEYID = UC2.KEYID
ORDER BY UC1.TOPICID, UC1.CART DESC;

END //
DELIMITER ;

-- -- getPostCounts

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
-- getPostDetails

DELIMITER //
DROP PROCEDURE IF EXISTS getPostDetails //
CREATE PROCEDURE getPostDetails(userid varchar(45), postid INT)
BEGIN

/*

07/17/2020 AST: This proc is being rebuilt for the new UI. It will provide the 
		necessary details of the post and also ensure that the post is legit as per
        the user id.
08/11/2020 Kapil: Confirmed

*/

declare  UID, TID INT;
DECLARE userDP VARCHAR(300) ;

SELECT U1.USERID, U1.DP_URL INTO UID, userDP FROM OPN_USERLIST U1 WHERE U1.USER_UUID = userid ;
SELECT TOPICID INTO TID FROM OPN_POSTS WHERE POST_ID = postid ;

SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_BY_USERID, OU.USERNAME, OU.DP_URL
, P.POST_CONTENT,P.MEDIA_CONTENT,P.MEDIA_FLAG,
1 TOTAL_NS, bringPostLCount(postid) LCOUNT, bringPostHCount(postid) HCOUNT
, bringUserPostAction(UID, postid) POST_ACTION_TYPE
, '' UU_ACTION, bringPostCCount(postid) POST_COMMENT_COUNT
FROM OPN_POSTS P, OPN_USERLIST OU
WHERE P.POST_BY_USERID = OU.USERID
AND P.POST_ID = postid
AND P.CLEAN_POST_FLAG = 'Y'
AND P.POST_BY_USERID IN 
(SELECT B.USERID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = UID) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = UID 
AND OUUA.TOPICID = TID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.KEYID = B.KEYID AND A.TOPICID = TID)
-- AND P.POST_BY_USERID = orig_uid
;

END //
DELIMITER ;

-- -- getPostsByUserNameANTI

USE `opntprod`;
DROP procedure IF EXISTS `getPostsByUserNameANTI`;

DELIMITER $$
USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `getPostsByUserNameANTI`(userid varchar(45), topicid INT  , fromindex INT, toindex INT
)
thisproc: BEGIN

/*  
 08/11/2020 Kapil: Confirmed
 	09/22/2020 AST: Adding GGG to the CCODE exclusion
    this is because the SCIENCE news is getting STP to GGG users only
 */

declare  orig_uid, TIDCNT, LASTTID, CARTCNT INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CDTM DATETIME ;
DECLARE CCODE VARCHAR(5) ;

SELECT UL.USERID, UL.USERNAME, UL.COUNTRY_CODE INTO orig_uid, UNAME, CCODE FROM OPN_USERLIST UL WHERE UL.USER_UUID = userid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'getPostsByUserNameANTI', CONCAT(topicid,'-',toindex));


/* end of use action tracking */

-- SET NAMES utf8;

/* 04242018 AST:

Added , P.POST_UPDATE_DTM so that the instream can be ordered by the latest updated posts

-- To Do: Add a trigger on the comments table to update the POST_UPDATE_DTM for posts 
whenever there is a comment on the post
This will ensure that the active posts are always on the top and the users don't 
have to keep searching for them

 05/15/2019 AST: changed the overall ordering of posts to POST_ID DESC (LAST ROW IN SQL). 
 Removed the POST_DATETIME AND TOTAL_NS from ordering
 07/10/2019 AST: Changed the ordering of posts to handle the following case:
 When a user changed the cart (adding new KW) then the instream woeldn't change 
 unless the KW was completely new. Now the proc uses the LAST_UPDATE_DTM of 
 the OPN_USER_CART to decide the ordering of the posts when the last_dtm is in the last 24 hours
 
 10/29/2019 AST: Changing the CDTM logic. This is because of the case where a user 
 removes all kw for an interest. At that time, the CDTM becomes null and the proc fails. 
 Hence, when the topicid that is passed to the proc has no cart elements (that means the user has no 
 kws selected in that topic) then we will take the last available kW's topic.
 If the user does not have any cart whatsoever, then we will simply exit the proc - to avoid a failure
 
 12/17/2019 AST: Removed @ from code

*/
/*26-03-2020: - Rohit: -Added the dp_url into the select statement */
/* 04/22/2020 AST: Repurposing this proc as getPostsByUserNameNW */
/* 06/03/2020 AST: Rebuilt and added COMMENT_DELETE_FLAG = 'N' to comment counts  */

/* 	06/30/2020 AST: Adding CCODE to the SQL so that USA doesn't get IND posts and vice versa  
	ALSO removing OR P.POST_BY_USERID = orig_uid - SO that only clean posts are visible - even to the postor	
    
    07/09/2020 AST: Adding the handling of the following: We want to restrict the instream where 
    the ccode of the postor matches the ccode of the user - but only for BOT posts
    
    If a non-BOT user makes a post from a different ccode - but has the same keyid in cart,
    then that non-BOT post should be visible - and counted - by the user    */
    
/* 	11/08/2020 AST: Now the non-clean posts are being changed to a standard warning replacement. 
	Hence, removing the filter P.CLEAN_POST_FLAG = 'Y' AND from all cases below */

SET CARTCNT = (SELECT COUNT(DISTINCT T1.TOPICID) 
FROM OPN_USER_CARTS T1 WHERE T1.USERID = orig_uid) ;

CASE WHEN CARTCNT = 0 THEN LEAVE thisproc ;

WHEN CARTCNT > 0 THEN

SET TIDCNT = (SELECT COUNT(*) FROM OPN_USER_CARTS C1 
WHERE C1.USERID = orig_uid AND C1.TOPICID = topicid) ;

CASE WHEN TIDCNT > 0 THEN 
SET CDTM = (SELECT MAX(OUC.LAST_UPDATE_DTM) FROM OPN_USER_CARTS OUC 
WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid) ;
SET LASTTID = topicid ;


WHEN TIDCNT <= 0 THEN
SET LASTTID = (SELECT MAX(TT3.TOPICID) FROM OPN_USER_CARTS TT3 
WHERE TT3.USERID = orig_uid) ;
SET CDTM = (SELECT MAX(OUC.LAST_UPDATE_DTM) FROM OPN_USER_CARTS OUC 
WHERE OUC.USERID = orig_uid AND OUC.TOPICID = LASTTID) ;

END CASE ;
END CASE ;

CASE WHEN CDTM < NOW() - INTERVAL 1 DAY THEN 

SELECT INSTREAM.POST_ID, INSTREAM.TOPICID, INSTREAM.POST_DATETIME, INSTREAM.POST_BY_USERID
, OU.USERNAME,OU.DP_URL,INSTREAM.MEDIA_CONTENT,INSTREAM.MEDIA_FLAG, INSTREAM.POST_CONTENT, INSTREAM.TOTAL_NS 
, IFNULL(POST_LHC.LCOUNT,0) LCOUNT, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, UP.POST_ACTION_TYPE 
, UUA.ACTION_TYPE UU_ACTION, OPC.POST_COMMENT_COUNT
FROM (
SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_UPDATE_DTM
, P.POST_BY_USERID, P.POST_CONTENT, UN.TOTAL_NS, P.MEDIA_CONTENT, P.MEDIA_FLAG
FROM OPN_POSTS P
, (SELECT B.USERID, B.BOT_FLAG, A.TOPICID, COUNT(*) TOTAL_NS FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = orig_uid 
AND OUUA.TOPICID = LASTTID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART <> B.CART 
AND A.KEYID = B.KEYID AND A.TOPICID = LASTTID
GROUP BY B.USERID, B.BOT_FLAG, A.TOPICID ORDER BY  COUNT(*) DESC ) UN
WHERE UN.USERID = P.POST_BY_USERID
AND UN.TOPICID = P.TOPICID
-- AND P.POST_DATETIME >= CURRENT_DATE - INTERVAL 200 DAY
/* 04/18/2019 AST: Adding the condition below: This is to ensure that the users don't get spammed with the STP posts
that do not belong to the KWs outside the user's carts 
    05/01/2019 AST:  Added kk as table identifier to avoid confusion */
AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN 
(SELECT KK.KEYID FROM OPN_USER_CARTS KK WHERE KK.USERID = orig_uid))
/* End of 04/18/2019 addition 
    End of 05/01/2019 modification */
AND ( -- P.CLEAN_POST_FLAG = 'Y' AND 
(CASE WHEN UN.BOT_FLAG = 'Y' 
THEN  P.POSTOR_COUNTRY_CODE IN ( CCODE, 'GGG') ELSE P.POSTOR_COUNTRY_CODE NOT IN ('PQR')  END ) )
) INSTREAM
INNER JOIN OPN_USERLIST OU
ON INSTREAM.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON INSTREAM.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN OPN_USER_POST_ACTION UP ON INSTREAM.POST_ID = UP.CAUSE_POST_ID 
AND UP.ACTION_BY_USERID = orig_uid 
LEFT OUTER JOIN OPN_USER_USER_ACTION UUA ON INSTREAM.POST_BY_USERID = UUA.ON_USERID 
AND UUA.BY_USERID = orig_uid
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' AND COMMENT_DELETE_FLAG = 'N' GROUP BY CAUSE_POST_ID) OPC 
ON INSTREAM.POST_ID = OPC.CAUSE_POST_ID
ORDER BY POST_ID DESC  LIMIT fromindex, toindex
;

WHEN  CDTM >= NOW() - INTERVAL 1 DAY THEN

SELECT INSTREAM.POST_ID, INSTREAM.TOPICID, INSTREAM.POST_DATETIME, INSTREAM.POST_BY_USERID
, OU.USERNAME,OU.DP_URL,INSTREAM.MEDIA_CONTENT,INSTREAM.MEDIA_FLAG, INSTREAM.POST_CONTENT, INSTREAM.CART_DTM TOTAL_NS
, IFNULL(POST_LHC.LCOUNT,0) LCOUNT, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, UP.POST_ACTION_TYPE 
, UUA.ACTION_TYPE UU_ACTION, OPC.POST_COMMENT_COUNT
FROM (
SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_UPDATE_DTM
, IFNULL(UC.LAST_UPDATE_DTM, P.POST_UPDATE_DTM) CART_DTM
, P.POST_BY_USERID, P.TAG1_KEYID, K.KEYWORDS, P.POST_CONTENT, UN.TOTAL_NS, P.MEDIA_CONTENT, P.MEDIA_FLAG
FROM OPN_POSTS P
LEFT OUTER JOIN OPN_P_KW K ON P.TAG1_KEYID = K.KEYID
LEFT OUTER JOIN  OPN_USER_CARTS UC ON P.TAG1_KEYID = UC.KEYID AND UC.USERID = orig_uid
, (SELECT B.USERID, B.BOT_FLAG, A.TOPICID, COUNT(*) TOTAL_NS FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid 
AND OUUA.TOPICID = LASTTID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART <> B.CART AND A.KEYID = B.KEYID AND A.TOPICID = LASTTID 
GROUP BY B.USERID, B.BOT_FLAG, A.TOPICID -- ORDER BY  COUNT(*) DESC 
) UN
WHERE UN.USERID = P.POST_BY_USERID
AND UN.TOPICID = P.TOPICID
-- AND P.POST_BY_USERID = UC.USERID
-- AND P.POST_DATETIME >= CURRENT_DATE - INTERVAL 200 DAY
/* 04/18/2019 AST: Adding the condition below: This is to ensure that the users don't get spammed with the STP posts
that do not belong to the KWs outside the user's carts 
    05/01/2019 AST:  Added kk as table identifier to avoid confusion */
AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN (SELECT KK.KEYID FROM OPN_USER_CARTS KK WHERE KK.USERID = orig_uid))
/* End of 04/18/2019 addition 
    End of 05/01/2019 modification */
AND ( -- P.CLEAN_POST_FLAG = 'Y' AND 
(CASE WHEN UN.BOT_FLAG = 'Y' 
THEN  P.POSTOR_COUNTRY_CODE IN ( CCODE, 'GGG') ELSE P.POSTOR_COUNTRY_CODE NOT IN ('PQR')  END ) )
) INSTREAM
INNER JOIN OPN_USERLIST OU
ON INSTREAM.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON INSTREAM.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN OPN_USER_POST_ACTION UP ON INSTREAM.POST_ID = UP.CAUSE_POST_ID AND UP.ACTION_BY_USERID = orig_uid 
LEFT OUTER JOIN OPN_USER_USER_ACTION UUA ON INSTREAM.POST_BY_USERID = UUA.ON_USERID AND UUA.BY_USERID = orig_uid
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' AND COMMENT_DELETE_FLAG = 'N' GROUP BY CAUSE_POST_ID) OPC 
ON INSTREAM.POST_ID = OPC.CAUSE_POST_ID
ORDER BY CART_DTM DESC, POST_ID DESC  LIMIT fromindex, toindex
;

END CASE ;
  
END$$

DELIMITER ;

-- -- getPostsByUserNameNW

USE `opntprod`;
DROP procedure IF EXISTS `getPostsByUserNameNW`;

DELIMITER $$
USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `getPostsByUserNameNW`(userid varchar(45), topicid INT  , fromindex INT, toindex INT
)
thisproc: BEGIN

/* 
 08/11/2020 Kapil: Confirmed
	09/22/2020 AST: Adding GGG to the CCODE exclusion
    this is because the SCIENCE news is getting STP to GGG users only
 */
 
declare  orig_uid, TIDCNT, LASTTID, CARTCNT INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CDTM DATETIME ;
DECLARE CCODE VARCHAR(5) ;

SELECT UL.USERID, UL.USERNAME, UL.COUNTRY_CODE INTO orig_uid, UNAME, CCODE FROM OPN_USERLIST UL WHERE UL.USER_UUID = userid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'getPostsByUserNameNW', CONCAT(topicid,'-',toindex));


/* end of use action tracking */

-- SET NAMES utf8;

/* 04242018 AST:

Added , P.POST_UPDATE_DTM so that the instream can be ordered by the latest updated posts

-- To Do: Add a trigger on the comments table to update the POST_UPDATE_DTM for posts 
whenever there is a comment on the post
This will ensure that the active posts are always on the top and the users don't 
have to keep searching for them

 05/15/2019 AST: changed the overall ordering of posts to POST_ID DESC (LAST ROW IN SQL). 
 Removed the POST_DATETIME AND TOTAL_NS from ordering
 07/10/2019 AST: Changed the ordering of posts to handle the following case:
 When a user changed the cart (adding new KW) then the instream woeldn't change 
 unless the KW was completely new. Now the proc uses the LAST_UPDATE_DTM of 
 the OPN_USER_CART to decide the ordering of the posts when the last_dtm is in the last 24 hours
 
 10/29/2019 AST: Changing the CDTM logic. This is because of the case where a user 
 removes all kw for an interest. At that time, the CDTM becomes null and the proc fails. 
 Hence, when the topicid that is passed to the proc has no cart elements (that means the user has no 
 kws selected in that topic) then we will take the last available kW's topic.
 If the user does not have any cart whatsoever, then we will simply exit the proc - to avoid a failure
 
 12/17/2019 AST: Removed @ from code

*/
/*26-03-2020: - Rohit: -Added the dp_url into the select statement */
/* 04/22/2020 AST: Repurposing this proc as getPostsByUserNameNW */
/* 06/03/2020 AST: Rebuilt and added COMMENT_DELETE_FLAG = 'N' to comment counts  */

/* 	06/30/2020 AST: Adding CCODE to the SQL so that USA doesn't get IND posts and vice versa  
	ALSO removing OR P.POST_BY_USERID = orig_uid - SO that only clean posts are visible - even to the postor	
    
    07/09/2020 AST: Adding the handling of the following: We want to restrict the instream where 
    the ccode of the postor matches the ccode of the user - but only for BOT posts
    
    If a non-BOT user makes a post from a different ccode - but has the same keyid in cart,
    then that non-BOT post should be visible - and counted - by the user */
    
/* 	11/08/2020 AST: Now the non-clean posts are being changed to a standard warning replacement. 
	Hence, removing the filter P.CLEAN_POST_FLAG = 'Y' AND from all cases below */

SET CARTCNT = (SELECT COUNT(DISTINCT T1.TOPICID) 
FROM OPN_USER_CARTS T1 WHERE T1.USERID = orig_uid) ;

CASE WHEN CARTCNT = 0 THEN LEAVE thisproc ;

WHEN CARTCNT > 0 THEN

SET TIDCNT = (SELECT COUNT(*) FROM OPN_USER_CARTS C1 
WHERE C1.USERID = orig_uid AND C1.TOPICID = topicid) ;

CASE WHEN TIDCNT > 0 THEN 
SET CDTM = (SELECT MAX(OUC.LAST_UPDATE_DTM) FROM OPN_USER_CARTS OUC 
WHERE OUC.USERID = orig_uid AND OUC.TOPICID = topicid) ;
SET LASTTID = topicid ;


WHEN TIDCNT <= 0 THEN
SET LASTTID = (SELECT MAX(TT3.TOPICID) FROM OPN_USER_CARTS TT3 
WHERE TT3.USERID = orig_uid) ;
SET CDTM = (SELECT MAX(OUC.LAST_UPDATE_DTM) FROM OPN_USER_CARTS OUC 
WHERE OUC.USERID = orig_uid AND OUC.TOPICID = LASTTID) ;

END CASE ;
END CASE ;

CASE WHEN CDTM < NOW() - INTERVAL 1 DAY THEN 

SELECT INSTREAM.POST_ID, INSTREAM.TOPICID, INSTREAM.POST_DATETIME, INSTREAM.POST_BY_USERID
, OU.USERNAME,OU.DP_URL,INSTREAM.MEDIA_CONTENT,INSTREAM.MEDIA_FLAG, INSTREAM.POST_CONTENT, INSTREAM.TOTAL_NS 
, IFNULL(POST_LHC.LCOUNT,0) LCOUNT, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, UP.POST_ACTION_TYPE 
, UUA.ACTION_TYPE UU_ACTION, OPC.POST_COMMENT_COUNT
FROM (
SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_UPDATE_DTM
, P.POST_BY_USERID, P.POST_CONTENT, UN.TOTAL_NS, P.MEDIA_CONTENT, P.MEDIA_FLAG
FROM OPN_POSTS P
, (SELECT B.USERID, B.BOT_FLAG, A.TOPICID, COUNT(*) TOTAL_NS FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = orig_uid 
AND OUUA.TOPICID = LASTTID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART 
AND A.KEYID = B.KEYID AND A.TOPICID = LASTTID
GROUP BY B.USERID, B.BOT_FLAG, A.TOPICID ORDER BY  COUNT(*) DESC ) UN
WHERE UN.USERID = P.POST_BY_USERID
AND UN.TOPICID = P.TOPICID
-- AND P.POST_DATETIME >= CURRENT_DATE - INTERVAL 200 DAY
/* 04/18/2019 AST: Adding the condition below: This is to ensure that the users don't get spammed with the STP posts
that do not belong to the KWs outside the user's carts 
    05/01/2019 AST:  Added kk as table identifier to avoid confusion */
AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN 
(SELECT KK.KEYID FROM OPN_USER_CARTS KK WHERE KK.USERID = orig_uid))
/* End of 04/18/2019 addition 
    End of 05/01/2019 modification */
AND ( -- P.CLEAN_POST_FLAG = 'Y' AND 
(CASE WHEN UN.BOT_FLAG = 'Y' 
THEN  P.POSTOR_COUNTRY_CODE IN ( CCODE, 'GGG') ELSE P.POSTOR_COUNTRY_CODE NOT IN ('PQR')  END ) )
) INSTREAM
INNER JOIN OPN_USERLIST OU
ON INSTREAM.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON INSTREAM.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN OPN_USER_POST_ACTION UP ON INSTREAM.POST_ID = UP.CAUSE_POST_ID 
AND UP.ACTION_BY_USERID = orig_uid 
LEFT OUTER JOIN OPN_USER_USER_ACTION UUA ON INSTREAM.POST_BY_USERID = UUA.ON_USERID 
AND UUA.BY_USERID = orig_uid
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' AND COMMENT_DELETE_FLAG = 'N' GROUP BY CAUSE_POST_ID) OPC 
ON INSTREAM.POST_ID = OPC.CAUSE_POST_ID
ORDER BY POST_ID DESC  LIMIT fromindex, toindex
;

WHEN  CDTM >= NOW() - INTERVAL 1 DAY THEN

SELECT INSTREAM.POST_ID, INSTREAM.TOPICID, INSTREAM.POST_DATETIME, INSTREAM.POST_BY_USERID
, OU.USERNAME,OU.DP_URL,INSTREAM.MEDIA_CONTENT,INSTREAM.MEDIA_FLAG, INSTREAM.POST_CONTENT, INSTREAM.CART_DTM TOTAL_NS
, IFNULL(POST_LHC.LCOUNT,0) LCOUNT, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, UP.POST_ACTION_TYPE 
, UUA.ACTION_TYPE UU_ACTION, OPC.POST_COMMENT_COUNT
FROM (
SELECT P.POST_ID, P.TOPICID, P.POST_DATETIME, P.POST_UPDATE_DTM
, IFNULL(UC.LAST_UPDATE_DTM, P.POST_UPDATE_DTM) CART_DTM
, P.POST_BY_USERID, P.TAG1_KEYID, K.KEYWORDS, P.POST_CONTENT, UN.TOTAL_NS, P.MEDIA_CONTENT, P.MEDIA_FLAG
FROM OPN_POSTS P
LEFT OUTER JOIN OPN_P_KW K ON P.TAG1_KEYID = K.KEYID
LEFT OUTER JOIN  OPN_USER_CARTS UC ON P.TAG1_KEYID = UC.KEYID AND UC.USERID = orig_uid
, (SELECT B.USERID, B.BOT_FLAG, A.TOPICID, COUNT(*) TOTAL_NS FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid 
AND OUUA.TOPICID = LASTTID AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID AND A.TOPICID = LASTTID 
GROUP BY B.USERID, B.BOT_FLAG, A.TOPICID -- ORDER BY  COUNT(*) DESC 
) UN
WHERE UN.USERID = P.POST_BY_USERID
AND UN.TOPICID = P.TOPICID
-- AND P.POST_BY_USERID = UC.USERID
-- AND P.POST_DATETIME >= CURRENT_DATE - INTERVAL 200 DAY
/* 04/18/2019 AST: Adding the condition below: This is to ensure that the users don't get spammed with the STP posts
that do not belong to the KWs outside the user's carts 
    05/01/2019 AST:  Added kk as table identifier to avoid confusion */
AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN (SELECT KK.KEYID FROM OPN_USER_CARTS KK WHERE KK.USERID = orig_uid))
/* End of 04/18/2019 addition 
    End of 05/01/2019 modification */
AND ( -- P.CLEAN_POST_FLAG = 'Y' AND 
(CASE WHEN UN.BOT_FLAG = 'Y' 
THEN  P.POSTOR_COUNTRY_CODE IN ( CCODE, 'GGG') ELSE P.POSTOR_COUNTRY_CODE NOT IN ('PQR')  END ) )
) INSTREAM
INNER JOIN OPN_USERLIST OU
ON INSTREAM.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON INSTREAM.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN OPN_USER_POST_ACTION UP ON INSTREAM.POST_ID = UP.CAUSE_POST_ID AND UP.ACTION_BY_USERID = orig_uid 
LEFT OUTER JOIN OPN_USER_USER_ACTION UUA ON INSTREAM.POST_BY_USERID = UUA.ON_USERID AND UUA.BY_USERID = orig_uid
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' AND COMMENT_DELETE_FLAG = 'N' GROUP BY CAUSE_POST_ID) OPC 
ON INSTREAM.POST_ID = OPC.CAUSE_POST_ID
ORDER BY CART_DTM DESC, POST_ID DESC  LIMIT fromindex, toindex
;

END CASE ;
  
END$$

DELIMITER ;

-- -- getPushNotifs

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getPushNotifs //
CREATE PROCEDURE getPushNotifs()
BEGIN

/* 
 08/11/2020 Kapil: Confirmed
 08/28/2020 AST: adding the PUSH_TYPE, PUSH_TITLE, SOURCE_ID
 09/07/2020 AST : Removed old sql
 */


SELECT L.APP_TOKEN, L.USERID, UL.USERNAME, L.USER_PLATFORM LAST_USED_PLATFORM, L.PUSH_TOPIC
, L.PUSH_TYPE, L.PUSH_TITLE, L.SOURCE_ID, COUNT(1) PUSHCOUNT
FROM OPN_PUSH_LAUNCH L, OPN_USERLIST UL,
(SELECT APP_TOKEN APT, USER_PLATFORM, MAX(USERID) MUID FROM OPN_PUSH_LAUNCH -- WHERE USERID IN (1022540)
GROUP BY APP_TOKEN, USER_PLATFORM) M
WHERE L.APP_TOKEN = M.APT AND L.USERID = M.MUID AND L.USER_PLATFORM = M.USER_PLATFORM
AND L.USERID = UL.USERID
GROUP BY L.APP_TOKEN, L.USERID, UL.USERNAME, L.USER_PLATFORM, L.PUSH_TOPIC
, L.PUSH_TYPE, L.PUSH_TITLE, L.SOURCE_ID
;

 TRUNCATE TABLE OPN_PUSH_LAUNCH ;


END //
DELIMITER ;

-- -- getUserActivity

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS getUserActivity //
CREATE PROCEDURE getUserActivity(uname varchar(40) )
BEGIN

/* 
09/07/2020 AST: initial Creation
		this proc is used for getting the detailed activities of a specific username
		this is for determining whether to ban this user

 */

declare UID, PCNT7, CCNT7, RPCNT7, YPCNT, YCCNT, YRPCNT, YRCCNT, KOCNT INT ;
DECLARE UUID VARCHAR(45) ;
DECLARE UTYPE VARCHAR(3) ;
DECLARE UDEVICE VARCHAR(200) ;
DECLARE UEMAIL, UFBID, UGID, UAID VARCHAR(100) ;

SELECT USERID, USER_UUID, FB_USER_FLAG, FB_USERID, IDENTIFIER_TOKEN, G_USERID, EMAIL_ADDR, A_USERID
INTO UID, UUID, UTYPE, UFBID, UDEVICE, UGID, UEMAIL, UAID FROM OPN_USERLIST  WHERE USERNAME = uname ;

SELECT COUNT(1) INTO PCNT7 FROM OPN_POSTS WHERE POST_BY_USERID = UID 
AND POST_PROCESSED_DTM > CURRENT_DATE() - INTERVAL 7 DAY  ;

SELECT COUNT(1) INTO YPCNT FROM OPN_POSTS WHERE POST_BY_USERID = UID 
AND POST_PROCESSED_DTM > CURRENT_DATE() - INTERVAL 1 YEAR  ;

SELECT COUNT(1) INTO CCNT7 FROM OPN_POST_COMMENTS WHERE POST_BY_USERID = UID 
AND COMMENT_DTM > CURRENT_DATE() - INTERVAL 7 DAY  ;

SELECT COUNT(1) INTO YCCNT FROM OPN_POST_COMMENTS WHERE POST_BY_USERID = UID 
AND COMMENT_DTM > CURRENT_DATE() - INTERVAL 1 YEAR  ;

SELECT COUNT(1) INTO KOCNT FROM OPN_USER_USER_ACTION WHERE ON_USERID = UID ;

SELECT COUNT(1) INTO RPCNT7 FROM OPN_USER_REPORTED_CONTENT WHERE AGAINST_USERID = UID 
AND REPORTING_DTM > CURRENT_DATE() - INTERVAL 7 DAY ;

SELECT uname username, PCNT7 pcount_7day, YPCNT pcount_year
, CCNT7 ccount_7day, YCCNT ccount_year, KOCNT ko_count, RPCNT7 reported_count7 ;



END //
DELIMITER ;

-- -- getUserCarts

DELIMITER //
DROP PROCEDURE IF EXISTS getUserCarts //
CREATE DEFINER=`root`@`%` PROCEDURE `getUserCarts`(TID INT, UUID varchar(45), sortOrder VARCHAR(10), fromIndex INT, toIndex INT)
BEGIN
/* 
08/11/2020 Kapil: Confirmed
 */
declare  UID INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID ;

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'getUserCarts', CONCAT(TID,'-',CCODE));


/* end of use action tracking */


/* 05/19/2020 AST: Building the new proc to include the sortOrder
    05/26/2020 AST: Added LIMIT fromIndex , toIndex for limiting the list
    
    06/18/2020 AST: Adding HCNT, LCNT
*/

CASE WHEN sortOrder = ('POPULAR') THEN 

SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
AND UC1.KEYID = S1.KEYID
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE K1.KEYID = S1.KEYID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, S1.SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, (SELECT SORT1.KEYID, COUNT(1) SORTER FROM OPN_USER_CARTS SORT1 WHERE SORT1.TOPICID = TID
GROUP BY SORT1.KEYID ORDER BY COUNT(1) DESC) S1
WHERE K1.KEYID = S1.KEYID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1, (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = TID GROUP BY KEYID) CNT
WHERE Q1.KEYID = CNT.KEYID
ORDER BY SRC, CART, SORTER DESC LIMIT fromIndex , toIndex ;
                
WHEN  sortOrder = ('ALPHA') THEN       


SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, K1.KEYWORDS SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1 
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1, (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = TID GROUP BY KEYID) CNT
WHERE Q1.KEYID = CNT.KEYID
ORDER BY SRC, CART, SORTER LIMIT fromIndex , toIndex ;

WHEN  sortOrder = ('LATEST') THEN  

SELECT Q1.USERID, Q1.TOPICID, Q1.CART, Q1.KEYID, Q1.KEYWORDS, Q1.SRC, Q1.SORTER, Q1.COUNTRY_CODE, CNT.HCNT, CNT.LCNT FROM
( 
/* START OF CART PORTION OF SORTER 1 */
SELECT UC1.USERID, UC1.TOPICID, UC1.CART, K1.KEYID, K1.KEYWORDS, 'A' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
, OPN_USER_CARTS UC1
WHERE UC1.KEYID = K1.KEYID AND UC1.TOPICID = TID AND UC1.USERID = UID 
/* END OF CART PORTION OF SORTER 1 */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'B' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE = CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE = KW.CCODE  */
UNION ALL
/* START OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE */
SELECT UID USERID, TID TOPICID, NULL CART, K1.KEYID, K1.KEYWORDS, 'C' SRC, K1.CREATION_DTM SORTER, K1.COUNTRY_CODE
FROM OPN_P_KW K1
WHERE 1=1 
AND K1.TOPICID = TID
AND K1.COUNTRY_CODE <> CCODE
AND K1.PRIVATE_KW_FLAG = 'N'
AND K1.KEYID NOT IN 
(SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = UID AND TOPICID = TID)
/* END OF NON-CART PORTION OF SORTER 1 - FOR USER.CCODE <> KW.CCODE  */
) Q1, (SELECT KEYID, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCNT
FROM OPN_USER_CARTS WHERE TOPICID = TID GROUP BY KEYID) CNT
WHERE Q1.KEYID = CNT.KEYID
ORDER BY SRC, CART, SORTER DESC LIMIT fromIndex , toIndex ;


END CASE ;

END //
DELIMITER ;

-- 
-- getUserInterests

DELIMITER //
DROP PROCEDURE IF EXISTS getUserInterests //
CREATE DEFINER=`root`@`%` PROCEDURE `getUserInterests`(uuid VARCHAR(45))
BEGIN

/*
05/16/2020 AST: Creating this proc to build the Interest List (already selected and unselected)
for a user.

05/26/2020 AST: Added the USR BHV section
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
declare UNAME VARCHAR(40) ;

SELECT USERNAME, USERID INTO UNAME, orig_uid FROM OPN_USERLIST WHERE USER_UUID = uuid;

/* adding the user action tracking portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, UUID, NOW(), 'getUserInterests', CONCAT(orig_uid,'-',UNAME));


/* end of use action tracking */

SELECT T.TOPICID, T.TOPIC, T.CODE, IF(IV2.SELECTED_KW_COUNT IS NULL, 'N', 'Y') 'SLCT'
FROM OPN_TOPICS T LEFT OUTER JOIN 
(SELECT IV.INTEREST_ID, IV.INTEREST_NAME, IV.INTEREST_CODE, IV.SELECTED_KW_COUNT
FROM OPN_USER_INTERESTS_V IV WHERE IV.USERID = orig_uid) IV2
ON T.TOPICID = IV2.INTEREST_ID ORDER BY T.CODE
;
  
END //
DELIMITER ;

-- -- getUserTopics

DELIMITER //
DROP PROCEDURE IF EXISTS getUserTopics //
CREATE PROCEDURE getUserTopics(userid VARCHAR(45))
BEGIN
/*
08/11/2020 Kapil: Confirmed
*/
declare  orig_uid INT;

SET orig_uid = (SELECT  bringUserid(userid));

SELECT DISTINCT A.TOPICID, B.TOPIC, B.CODE
FROM OPN_USER_CARTS A, OPN_TOPICS B

-- 121817 TRYING ALTERNATE ORDERING OF TOPICS
-- WHERE A.USERID = @orig_uid AND A.TOPICID = B.TOPICID ORDER BY A.TOPICID;

WHERE A.USERID = orig_uid AND A.TOPICID = B.TOPICID ORDER BY B.CODE;
  
END //
DELIMITER ;

-- -- insertCartDelQ

 DELIMITER //
DROP PROCEDURE IF EXISTS insertCartDelQ //
CREATE PROCEDURE insertCartDelQ(userid varchar(45), topicid INT)
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */
declare  orig_uid, pbuid INT;

SET @orig_uid := (SELECT  bringUserid(userid));
-- SET @Ppbuid := (SELECT bringUseridFromUsername(postuserid));

-- ADDED THE LINE BELOW AS A STEP FOR MAKING LAST_UPDATE_DTM-BASED CLUSTERING

DELETE FROM OPN_CART_ARCHIVE WHERE OPN_CART_ARCHIVE.USERID = @orig_uid AND OPN_CART_ARCHIVE.TOPICID = topicid;  

-- THE DELETE FROM OPN_CART_ARCHIVE HAD TO BE ADDED BEFORE THE DELETE FROM OPN_USER_CARTS. ELSE IT DOESN'T WORK.

DELETE FROM OPN_USER_CARTS WHERE OPN_USER_CARTS.USERID = @orig_uid AND OPN_USER_CARTS.TOPICID = topicid;  




END //
DELIMITER ;

-- -- insertCartInsertQ

 DELIMITER //
DROP PROCEDURE IF EXISTS insertCartInsertQ //
CREATE PROCEDURE insertCartInsertQ(uuid varchar(45), tid INT, kid INT, cartv varchar(3))
thisproc:BEGIN

/*      070517 AST
        ADDED LAST_UPDATE_DTM --> NOW() IN THE INSERT STMNT FOR LUDTM-BASED CLUSTERING
        08/19/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
DECLARE SUSP VARCHAR(5) ;

SELECT  USERID, USER_SUSPEND_FLAG INTO orig_uid, SUSP FROM OPN_USERLIST WHERE USER_UUID = uuid ;

IF SUSP = 'Y' THEN LEAVE thisproc ;

ELSE

INSERT INTO OPN_USER_CARTS(TOPICID, USERID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)
VALUES (tid, orig_uid, kid, cartv, NOW(), NOW());

END IF ;


END //
DELIMITER ;

-- -- insertWebURL

DELIMITER //
DROP PROCEDURE IF EXISTS insertWebURL //
CREATE PROCEDURE insertWebURL(weburl varchar(300), urlTitle varchar(1000), urlDescription varchar(1000), urlImage varchar(1000) )
THISPROC: BEGIN
/*
 08/11/2020 Kapil: Confirmed
 */

CASE WHEN urlImage IS NOT NULL THEN

INSERT INTO OPN_WEB_LINKS
(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM) 
VALUES(weburl, urlTitle, urlDescription, urlImage, NOW())   ;

WHEN urlImage IS  NULL THEN
INSERT INTO OPN_WEB_LINKS
(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM) 
VALUES(weburl, urlTitle, urlDescription, 'https://www.opinito.com/images/orange/OPINITOLogo2.png', NOW())   ;

END CASE ;
  
END //
DELIMITER ;

-- -- likemindedcount

DELIMITER //
DROP PROCEDURE IF EXISTS likemindedcount //
CREATE PROCEDURE likemindedcount(uuid varchar(45), topic_id varchar(20))
BEGIN

/* 26032020 Rohit: Newly created To get the Networkcount and the topic name  
after selecting the love or hate 
04/03/2020 AST: Changed the Network Count to do real time count 

08/11/2020 Kapil: Confirmed
 */
DECLARE ISGUEST INT;
DECLARE UID INT;
DECLARE CNT INT;
DECLARE TOPICNAME varchar(30);
DECLARE TCODE varchar(3);
SET UID= (SELECT bringUserid(uuid));
SET CNT= (SELECT COUNT(DISTINCT U2.USERID)
FROM OPN_USER_CARTS U1, OPN_USER_CARTS U2
WHERE U1.USERID = UID AND U1.TOPICID = topic_id
AND U1.KEYID = U2.KEYID AND U1.TOPICID = U2.TOPICID 
AND U1.CART = U2.CART 
AND U2.USERID NOT IN (SELECT UU.ON_USERID FROM OPN_USER_USER_ACTION UU
WHERE UU.BY_USERID = UID AND UU.TOPICID = topic_id AND UU.ACTION_TYPE = 'KO'));

SET TOPICNAME= (select T.TOPIC from OPN_TOPICS T WHERE T.TOPICID = topic_id);
SELECT CNT,TOPICNAME;

END //
DELIMITER ;

-- -- loginGuestUserApp

 DELIMITER //
DROP PROCEDURE IF EXISTS loginGuestUserApp //
CREATE PROCEDURE loginGuestUserApp(uname varchar(30), uuid varchar(45), device_serial VARCHAR(40))
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */
CASE WHEN uuid = (SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = uname AND U.USER_TYPE = 'GUEST') THEN

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('loginGuestUserApp', NOW(), 'USERNAME', uname) ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(UUID), UUID, NOW(), device_serial, 'Y');

SELECT -- U.USERID, 
U.USER_UUID USERID, U.COUNTRY_CODE, U.USER_TYPE  , doesCartExist(uname) CARTORNOT
 from OPN_USERLIST U
 WHERE U.USERNAME = uname -- and AES_DECRYPT(U.password,'290317') = password
 ;

 WHEN uuid <> IFNULL((SELECT U.USER_UUID FROM OPN_USERLIST U WHERE U.USERNAME = uname AND U.USER_TYPE = 'GUEST'),'NONE') THEN

SELECT 'USERNAME DOES NOT MATCH' FROM DUAL ;
 
 END CASE ;
 

END //
DELIMITER ;

-- -- loginWithAppleUserApp

USE `opntprod`;
DROP procedure IF EXISTS `loginWithAppleUserApp`;

DELIMITER $$
USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `loginWithAppleUserApp`
(Apple_userid VARCHAR(100), device_serial VARCHAR(45))
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('loginWithAppleUserApp', NOW(), 'A_USERID', Apple_userid) ;

SELECT OU.USER_UUID USERID, OU.USERNAME, OU.COUNTRY_CODE 
FROM OPN_USERLIST OU WHERE OU.A_USERID = Apple_userid LIMIT 5;

END$$

DELIMITER ;

-- 

-- loginWithFBUser

DELIMITER //
DROP PROCEDURE IF EXISTS loginWithFBUserApp //
CREATE PROCEDURE loginWithFBUserApp(fbuserid VARCHAR(25), device_serial VARCHAR(45))
BEGIN

/* 04012018 AST: Added insret into proc log 
08/11/2020 Kapil: Confirmed
*/

DECLARE UUID VARCHAR(45);
DECLARE UNAME VARCHAR(30);
DECLARE CCODE VARCHAR(5);


/* INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('loginWithFBUser', NOW(), 'FB_USERID', fbuserid) ;

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(bringUserid(UUID), UUID, NOW(), device_serial, 'Y');

*/

SELECT USER_UUID USERID, USERNAME, COUNTRY_CODE FROM OPN_USERLIST WHERE FB_USERID = fbuserid limit 5;
  
END //
DELIMITER ;

-- -- loginWithGoogleUserApp

DELIMITER //
DROP PROCEDURE IF EXISTS loginWithGoogleUserApp //
CREATE PROCEDURE loginWithGoogleUserApp(Google_userid VARCHAR(25), device_serial VARCHAR(45))
BEGIN

/* 02/17/2020 AST: INITIAL CREATION  
08/11/2020 Kapil: Confirmed
*/

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('loginWithGoogleUserApp', NOW(), 'G_USERID', Google_userid) ;

SELECT OU.USER_UUID USERID, OU.USERNAME, OU.COUNTRY_CODE 
FROM OPN_USERLIST OU WHERE OU.G_USERID = Google_userid LIMIT 5;
  
END //
DELIMITER ;

-- -- ludtmUpdate

 DELIMITER //
DROP PROCEDURE IF EXISTS ludtmUpdate //
CREATE PROCEDURE ludtmUpdate(userid varchar(45), topicid INT)
BEGIN

/* 070517 AST
 THIS PROC IS FOR UPDATING THE LUDTM OF THE CART ROWS THAT HAVE NOT BEEN CHANGED
 THIS IS USED IN MAKING THE LUDTM AS THE BASIS FOR CLUSTERING (RATHER THAN THE ARBITRARY IRANK COLUMN THAT IS USED CURRENTLY)
 08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;

SET orig_uid := (SELECT  bringUserid(userid));

UPDATE OPN_CART_ARCHIVE ARCH, OPN_USER_CARTS CURR
SET CURR.LAST_UPDATE_DTM = ARCH.CREATION_DTM
WHERE ARCH.KEYID = CURR.KEYID AND ARCH.CART = CURR.CART
AND ARCH.USERID = CURR.USERID
AND ARCH.USERID = orig_uid and ARCH.TOPICID = topicid ;


END //
DELIMITER ;

-- -- myCommentPosts

DELIMITER //
DROP PROCEDURE IF EXISTS myCommentPosts //
CREATE PROCEDURE myCommentPosts(userid varchar(45), topicid INT, fromindex INT, toindex INT)
BEGIN

/* 	07/07/2020 AST: Initial Creation - Proc for finding all the posts where I have commented as a user. When user clicks the Comment Counts in the Activity screen
                    
07/09/2020 AST: Added filter for removing the users who have been kicked out by this user
08/11/2020 Kapil: Confirmed

*/

declare  orig_uid INT;

SET orig_uid = (SELECT  bringUserid(userid));

SELECT P.POST_ID, OU.USERNAME POST_BY_USERNAME, OU.DP_URL, P.TOPICID, P.POST_DATETIME, P.POST_CONTENT
, P.MEDIA_CONTENT, P.MEDIA_FLAG, IFNULL(POST_LHC.LCOUNT,0) LCOUNT
, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, IFNULL(OPC.POST_COMMENT_COUNT, 0) POST_COMMENT_COUNT
FROM OPN_POSTS P
INNER JOIN (SELECT DISTINCT CC.CAUSE_POST_ID FROM OPN_POST_COMMENTS CC WHERE CC.COMMENT_BY_USERID = orig_uid 
AND CC.TOPICID = topicid) PC
ON P.POST_ID = PC.CAUSE_POST_ID
INNER JOIN OPN_USERLIST OU ON P.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON P.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' GROUP BY CAUSE_POST_ID) OPC 
ON P.POST_ID = OPC.CAUSE_POST_ID
WHERE P.POST_BY_USERID NOT IN (SELECT UA.ON_USERID FROM OPN_USER_USER_ACTION UA
WHERE UA.BY_USERID = orig_uid AND UA.TOPICID = topicid AND UA.ACTION_TYPE = 'KO' )
ORDER BY P.POST_DATETIME DESC LIMIT fromindex, toindex;

END //
DELIMITER ;

-- -- networkNamesByUserName

 DELIMITER //
DROP PROCEDURE IF EXISTS networkNamesByUserName //
CREATE PROCEDURE networkNamesByUserName(UUID varchar(45), topicid INT, fromIndex INT, toIndex INT)
BEGIN

/* 08/19/2020 Kapil: Confirmed 

	08/25/2020 AST: adding CHF for each user

*/

declare  orig_uid INT;
DECLARE UNAME VARCHAR(40);
DECLARE CHFG VARCHAR(5) ;
-- declare tid INT ;
-- declare uuid varchar(45) ;

-- SET @uuid = UID ;
-- SET @tid = TID ;
SELECT USERNAME, USERID, CHAT_FLAG INTO UNAME, orig_uid, CHFG FROM OPN_USERLIST WHERE  USER_UUID = UUID ;

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, UUID, NOW(), 'networkNamesByUserName', CONCAT(topicid, '-',toindex));


SELECT B.USERID, A.TOPICID, ROUND((COUNT(B.USERID)/D.CSIZE),2) NET_STRENGTH
, OU.USERNAME
, CASE WHEN CHFG = 'N' THEN 'N' ELSE OU.CHAT_FLAG END CHF
, OU.DP_URL, MAX(B.CREATION_DTM) IN_NW_SINCE
FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE 
C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid 
AND OUUA.TOPICID = topicid AND OUUA.ACTION_TYPE = 'KO')) B 
, OPN_USERLIST OU
, (SELECT C3.TOPICID, COUNT(C3.ROW_ID) CSIZE FROM OPN_USER_CARTS C3 WHERE C3.USERID = orig_uid GROUP BY C3.TOPICID) D
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID 
AND B.USERID = OU.USERID AND A.TOPICID = topicid AND A.TOPICID = D.TOPICID
GROUP BY B.USERID, A.TOPICID, D.CSIZE ORDER BY MAX(B.CREATION_DTM) DESC, COUNT(B.USERID) DESC
LIMIT fromIndex, toIndex;



-- SELECT USERID, USERNAME FROM OPN_USERLIST WHERE USERID = orig_uid ;


END //
DELIMITER ;

-- -- networkUpdate

-- networkUpdate FOR BUILDING THE POST COUNTS UPDATES

DELIMITER //
DROP PROCEDURE IF EXISTS networkUpdate //
CREATE PROCEDURE networkUpdate(userid varchar(45))
BEGIN

declare  orig_uid INT;

-- SET orig_uid = (SELECT OU.USERID FROM OPN_USERLIST OU WHERE OU.USER_UUID = userid);

SELECT OU.USERID INTO orig_uid FROM OPN_USERLIST OU WHERE OU.USER_UUID = userid ;

UPDATE OPN_NW_STATS A SET A.NW_COUNT_T1 = A.NW_COUNT_T2, A.NWP_COUNT_T1 = A.NWP_COUNT_T2, A.NW_T1_DTM = A.NW_T2_DTM 
WHERE A.USERID = orig_uid ;

/*
UPDATE OPN_NW_STATS B
SET B.NW_COUNT_T2 = getNetworkCount(orig_uid, TOPICID), B.NWP_COUNT_T2 = getNWPCount(orig_uid, TOPICID), B.NW_T2_DTM = NOW() WHERE B.USERID = orig_uid ;


UPDATE OPN_NW_STATS AA, (
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid ) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE 1=1) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO' ) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID) BB
SET AA.NWP_COUNT_T2 = BB.PCT
WHERE AA.USERID = orig_uid AND AA.TOPICID = BB.TOPICID ;

*/

/* 04/12/2019 AST: The following UPDATE (setting all topics NW_COUNT_T2 = 0 is added.
This is because when a user kills an entire interest cart, the profile page Network Size 
was not reflecting 0 for that topic. 
That was because the BNET query from the SQL does bring only the latest topics in the user's cart
but the UPADATE does not reset to zero the interest that has been killed.

*/

UPDATE OPN_NW_STATS ONW SET ONW.NW_COUNT_T2 = 0 WHERE ONW.USERID = orig_uid ;

/* 04/12/2019 End of the addition of update to fix the kill-cart problem mentioned above */ 

UPDATE OPN_NW_STATS S1, 
/* Start of query BB: BB provides the postCount for a given topicid
    There are 10 identical statements - one for each topicid
    BB itself is a join between NWLIM and OPN_POSTS. 
    NWLIM (short for LIMitedNetWork) is, in turn, an outer join between BNET and KO
    BNET is the Basic Network - It provides all the USERIDs that are in network with the orig_uid for each topicid
    KO  provides the list of USERIDs that are kicked out by orig_uid   
    
    04/19/2019 AST: Currently the NWLIM has arbitrarily imposed limit where it brings only the latest 1000 users in the network
    in order to calculate the total num of posts thatorig_uid has access to.
    
    It also doesn't impose the limit of having only those TAG1_KEYIDs that are in orig_uid cart.
    
    If we want to do the actual perfect count of posts in the network then do the following 2 steps:
    
    1. Remove the LIMIT 1000 portion at the end of the NWLIM - for each topicid
    2. Add the following line 
    AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = 1002220 )) 
    
    as shown below: For each Topic
    
    WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY 
    
    
    AND (P.TAG1_KEYID IS NULL OR P.TAG1_KEYID IN (SELECT KEYID FROM OPN_USER_CARTS WHERE USERID = 1002220 )) 


    GROUP BY NWLIM.TOPICID 
    
    */
(SELECT BNET.TOPICID, COUNT(DISTINCT BNET.USERID) NWCOUNT FROM 
(SELECT DISTINCT A.TOPICID, B.USERID  FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid) A ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE 1=1) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID) BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND OUUA.ACTION_TYPE = 'KO' ) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' GROUP BY BNET.TOPICID) NCNT 
SET S1.NW_COUNT_T2 = NCNT.NWCOUNT WHERE S1.TOPICID = NCNT.TOPICID AND S1.USERID = orig_uid;

UPDATE OPN_NW_STATS AA, (
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 1) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 1) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 1) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 2) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 2) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 2) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 3) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 3) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 3) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 4) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 4) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 4) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 5) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 5) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 5) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 6) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 6) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 6) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 7) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 7) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 7) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 8) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 8) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 8) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 9) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 9) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 9) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
UNION ALL
SELECT NWLIM.TOPICID, COUNT(P.POST_ID) PCT FROM 
(SELECT BNET.TOPICID, BNET.USERID, BNET.NWSTRENGTH, IFNULL(KO.ACTION_TYPE, 'INNW') ACTION_TYPE FROM 
-- start of query BNET
(SELECT  A.TOPICID, B.USERID, COUNT(B.ROW_ID) NWSTRENGTH FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid AND C1.TOPICID = 10) A ,
(SELECT C2.ROW_ID, C2.USERID, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM FROM OPN_USER_CARTS C2 WHERE C2.TOPICID = 10) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART AND A.KEYID = B.KEYID  
GROUP BY A.TOPICID, B.USERID ORDER BY COUNT(B.ROW_ID) DESC ) BNET
-- end of query BNET
LEFT OUTER JOIN 
(SELECT OUUA.TOPICID, OUUA.ON_USERID, OUUA.ACTION_TYPE  FROM OPN_USER_USER_ACTION OUUA WHERE OUUA.BY_USERID = orig_uid
AND  OUUA.ACTION_TYPE = 'KO'  AND OUUA.TOPICID = 10) KO
ON BNET.USERID = KO.ON_USERID AND BNET.TOPICID = KO.TOPICID
WHERE IFNULL(KO.ACTION_TYPE, 'INNW') <> 'KO' ORDER BY BNET.NWSTRENGTH DESC, BNET.USERID DESC LIMIT 1000 ) NWLIM
LEFT OUTER JOIN OPN_POSTS P
ON NWLIM.USERID = P.POST_BY_USERID AND NWLIM.TOPICID = P.TOPICID 
WHERE P.CLEAN_POST_FLAG = 'Y' -- AND P.POST_DATETIME > NOW() - INTERVAL 300 DAY
GROUP BY NWLIM.TOPICID 
) BB
SET AA.NWP_COUNT_T2 = BB.PCT
WHERE AA.USERID = orig_uid AND AA.TOPICID = BB.TOPICID ;



END //
DELIMITER ;

-- -- newCommentOnComment 

 DELIMITER //
DROP PROCEDURE IF EXISTS newCommentOnComment //
CREATE PROCEDURE newCommentOnComment(concUUID varchar(45),  parentCommentID INT
, concContent varchar(2000), embedded_content varchar(1000), embedded_flag varchar(3)
, media_content varchar (500), media_flag varchar(3))
BEGIN

/* 04/22/2020 AST:  Rebuilding as a full comment on Comment with media attachments
 04/28/2020 AST: User BHV Log to be done
 06/04/2020 AST: Added OPC identifier for the SELECT and the OPN_POST_COMMENTS table
 
 08/09/2020 AST: Confirmed  
 08/14/2020 Kapil: Confirmed  */

declare  orig_uid, causepostbyuid, parentcmntbyuid, tid, causePostID INT;
declare parentCommentMediaFlag  varchar(3) ;
DECLARE UNAME, parentCommentByUname VARCHAR(40) ;
DECLARE parentCommentContent varchar(2000) ;
declare parentCommentMediaContent varchar(500) ;
declare parentCommentDTM DATETIME ;

SELECT USERID, USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST WHERE USER_UUID = concUUID ;

SELECT OPC.CAUSE_POST_ID, OPC.POST_BY_USERID, OPC.TOPICID, OPC.COMMENT_CONTENT, OPC.COMMENT_BY_USERID, OPC.COMMENT_BY_UNAME
, OPC.MEDIA_CONTENT, OPC.MEDIA_FLAG, OPC.COMMENT_DTM
INTO causePostID, causepostbyuid, tid, parentCommentContent, parentcmntbyuid, parentCommentByUname
, parentCommentMediaContent, parentCommentMediaFlag, parentCommentDTM
FROM OPN_POST_COMMENTS OPC where OPC.COMMENT_ID = parentCommentID  ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID
, POST_BY_USERID
, TOPICID
, COMMENT_SEQ
, COMMENT_CONTENT
, COMMENT_BY_USERID
, COMMENT_BY_UNAME
, PARENT_COMMENT_ID
, PARENT_COMMENT_CONTENT
, PARENT_COMMENT_BYUID
, PARENT_COMMENT_UNAME
, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG
, PARENT_COMMENT_DTM
, COMMENT_DTM
, EMBEDDED_CONTENT
, EMBEDDED_FLAG
, COMMENT_TYPE
, MEDIA_CONTENT
, MEDIA_FLAG) 
VALUES
(causePostID
, causepostbyuid
, tid
, 1
, concContent
, orig_uid
, UNAME
, parentCommentID
, parentCommentContent
, parentcmntbyuid
, parentCommentByUname
, parentCommentMediaContent
, parentCommentMediaFlag
, parentCommentDTM
, now()
, embedded_content
, embedded_flag
, 'CONC'
, media_content
, media_flag);


END //
DELIMITER ;

-- -- newCommentOnPost 

 DELIMITER //
DROP PROCEDURE IF EXISTS newCommentOnPost //
CREATE PROCEDURE newCommentOnPost(commentUUID varchar(45),  causePostID INT
, commentContent varchar(2000), embedded_content varchar(1000), embedded_flag varchar(3)
, media_content varchar (500), media_flag varchar(3))
BEGIN

/* 04/22/2020 AST:  Rebuilding as a full comment on post with media attachments
 04/28/2020 AST: User BHV Log to be done
 04/30/2020 AST: Added COMMENT_BY_UNAME
 06/04/2020 AST: Added identifiers for all the tables in the proc below
 
 08/09/2020 AST: Confirmed  
 08/14/2020 Kapil: Confirmed  
 */

declare  orig_uid, pbuid, tid INT;
declare COMMENT_TYPE varchar(10) ;
DECLARE UNAME VARCHAR(40) ;

SELECT OU.USERID, OU.USERNAME INTO orig_uid, UNAME FROM OPN_USERLIST OU WHERE OU.USER_UUID = commentUUID ;

SELECT OP.TOPICID, OP.POST_BY_USERID INTO tid, pbuid FROM OPN_POSTS OP
where OP.POST_ID = causePostID ;

INSERT INTO OPN_POST_COMMENTS_RAW 
(CAUSE_POST_ID, POST_BY_USERID, TOPICID, COMMENT_SEQ, COMMENT_CONTENT, COMMENT_BY_USERID, COMMENT_BY_UNAME
, PARENT_COMMENT_CONTENT, PARENT_COMMENT_BYUID, PARENT_COMMENT_UNAME, PARENT_MEDIA_CONTENT
, PARENT_MEDIA_FLAG, PARENT_COMMENT_DTM
,COMMENT_DTM,EMBEDDED_CONTENT,EMBEDDED_FLAG, COMMENT_TYPE, MEDIA_CONTENT, MEDIA_FLAG) 
VALUES
(causePostID, pbuid, tid, 1, commentContent, orig_uid, UNAME
, commentContent, orig_uid, UNAME, media_content
, media_flag, NOW()
, now(), embedded_content, embedded_flag, 'CONP', media_content, media_flag);


END //
DELIMITER ;

-- -- newPostwithmedia

DELIMITER //
DROP PROCEDURE IF EXISTS newPostwithmedia //
CREATE PROCEDURE newPostwithmedia(topicid INT, userid varchar(45), message varchar(2000)
, embedded_content varchar(1000), embedded_flag varchar(3) -- , postor_country_code varchar(5)
,media_content varchar (500),media_flag varchar(3))
thisProc: BEGIN

/*   
05/10/2020 AST: Adding Comments for readability 
Also removing @ from local vars
Also Adding DEMO_POST_FLAG = 'N'

05/31/2020 AST:  Removing the postor_country_code from input params
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CCODE VARCHAR(5) ;

SELECT OU.USERID, OU.USERNAME, OU.COUNTRY_CODE INTO orig_uid, UNAME, CCODE FROM OPN_USERLIST OU WHERE OU.USER_UUID = userid ;

SET NAMES UTF8mb4;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, userid, NOW(), 'newPostwithmedia', CONCAT(topicid,'-',CCODE));


/* end of use action tracking */

INSERT INTO OPN_POSTS_RAW(TOPICID, POST_DATETIME, POST_BY_USERID, POST_CONTENT, DEMO_POST_FLAG
,EMBEDDED_CONTENT,EMBEDDED_FLAG, POSTOR_COUNTRY_CODE,MEDIA_CONTENT,MEDIA_FLAG)
VALUES (topicid, NOW(), orig_uid, message, 'N'
, embedded_content, embedded_flag, CCODE, media_content, media_flag);

END; //
 DELIMITER ;
 
 -- -- profilePosts

DELIMITER //
DROP PROCEDURE IF EXISTS profilePosts //
CREATE PROCEDURE profilePosts(userid varchar(45), topicid INT, fromindex INT, toindex INT)
BEGIN

/* 	06/02/2020 AST: Rebuilding with removal of @  
	06/12/2020 AST: Added back the OU.DP_URL and P.MEDIA_CONTENT, P.MEDIA_FLAG
	
	08/11/2020 Kapil: Confirmed
*/

declare  orig_uid INT;

SET orig_uid = (SELECT  bringUserid(userid));

SELECT P.POST_ID, OU.USERNAME POST_BY_USERNAME, OU.DP_URL, P.TOPICID, P.POST_DATETIME, P.POST_CONTENT
, P.MEDIA_CONTENT, P.MEDIA_FLAG, IFNULL(POST_LHC.LCOUNT,0) LCOUNT
, IFNULL(POST_LHC.HCOUNT,0) HCOUNT, IFNULL(OPC.POST_COMMENT_COUNT, 0) POST_COMMENT_COUNT
FROM OPN_POSTS P
INNER JOIN OPN_USERLIST OU ON P.POST_BY_USERID = OU.USERID
LEFT OUTER JOIN 
(SELECT CAUSE_POST_ID, SUM(CASE WHEN POST_ACTION_TYPE = 'L' THEN 1 ELSE 0 END) LCOUNT 
, SUM(CASE WHEN POST_ACTION_TYPE = 'H' THEN 1 ELSE 0 END) HCOUNT 
FROM OPN_USER_POST_ACTION GROUP BY CAUSE_POST_ID) POST_LHC
ON P.POST_ID = POST_LHC.CAUSE_POST_ID
LEFT OUTER JOIN (SELECT CAUSE_POST_ID, COUNT(*) POST_COMMENT_COUNT FROM OPN_POST_COMMENTS 
WHERE CLEAN_COMMENT_FLAG = 'Y' GROUP BY CAUSE_POST_ID) OPC 
ON P.POST_ID = OPC.CAUSE_POST_ID
WHERE P.TOPICID = topicid AND P.POST_BY_USERID =  orig_uid
ORDER BY P.POST_DATETIME DESC LIMIT fromindex, toindex;

END //
DELIMITER ;

-- 
-- profilephp

DELIMITER //
DROP PROCEDURE IF EXISTS profilephp //
CREATE PROCEDURE profilephp(UUID varchar(45) )
BEGIN

/*  
 08/11/2020 Kapil: Confirmed
 08/20/2020 AST: Added OPN_USERLIST.CHAT_FLAG to turn the chat icon on/off

 */

declare  UID INT;
DECLARE CHF VARCHAR(3) ;
DECLARE UNAME VARCHAR(40) ;

SELECT UL.USERID, UL.USERNAME, UL.CHAT_FLAG INTO UID, UNAME, CHF FROM OPN_USERLIST UL WHERE UL.USER_UUID = UUID ;

 CALL networkUpdate(UUID) ;
 
 INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
 VALUES(UNAME, UID, UUID, NOW(), 'profilephp', UID);

/* 

06/04/2020 AST: This is the real updated one - need to remove all the old versions

07/07/2020 AST: Added COMMENT_COUNT to the SQL

*/


SELECT PP.TOPICID, PP.TOPIC, PP.PC_DELTA, PP.NETSIZE
, IFNULL(P.PCOUNT,0) POST_COUNT , IFNULL(CCNT.CCOUNT,0) COMMENT_COUNT
, CHF
FROM 
(SELECT NWS.TOPICID, T.TOPIC, (CASE WHEN (NWS.NWP_COUNT_T2 - NWS.NWP_COUNT_T1) <= 0 THEN 0 
WHEN (NWS.NWP_COUNT_T2 - NWS.NWP_COUNT_T1) BETWEEN 1 AND 999 THEN (NWS.NWP_COUNT_T2 - NWS.NWP_COUNT_T1) 
WHEN (NWS.NWP_COUNT_T2 - NWS.NWP_COUNT_T1) > 999 THEN 999
END ) PC_DELTA, NW_COUNT_T2 NETSIZE FROM 
OPN_NW_STATS NWS, OPN_TOPICS T
WHERE NWS.TOPICID = T.TOPICID AND NWS.NW_COUNT_T2 <> 0 AND NWS.USERID = UID) PP
LEFT OUTER JOIN ( SELECT OP.TOPICID, COUNT(1) PCOUNT FROM OPN_POSTS OP 
WHERE OP.POST_BY_USERID = UID GROUP BY OP.TOPICID) P
ON PP.TOPICID = P.TOPICID 
LEFT OUTER JOIN (SELECT OPC.TOPICID, COUNT(1) CCOUNT FROM OPN_POST_COMMENTS OPC 
WHERE OPC.COMMENT_BY_USERID = UID GROUP BY OPC.TOPICID) CCNT
ON PP.TOPICID = CCNT.TOPICID 
;

END //
DELIMITER ;

-- -- 

 DELIMITER //
DROP PROCEDURE IF EXISTS saveDeviceToken //
CREATE PROCEDURE saveDeviceToken(UID varchar(45), dtoken varchar(200))
BEGIN

/*
 08/11/2020 Kapil: Confirmed
 */


UPDATE OPN_USERLIST SET IDENTIFIER_TOKEN = dtoken, ID_TOKEN_DTM = NOW()
WHERE USER_UUID = UID;

  
END //
DELIMITER ;

-- -- 

 DELIMITER //
DROP PROCEDURE IF EXISTS saveLastPlatform //
CREATE PROCEDURE saveLastPlatform(UID varchar(45), LASTPLTFRM varchar(100))
BEGIN
/*
 08/11/2020 Kapil: Confirmed
 */
UPDATE OPN_USERLIST SET LAST_USED_PLATFORM = LASTPLTFRM, LAST_PLATFORM_DTM = NOW()
WHERE USER_UUID = UID;

  
END //
DELIMITER ;

-- -- saveUserInterests

 DELIMITER //
DROP PROCEDURE IF EXISTS saveUserInterests //
CREATE PROCEDURE saveUserInterests(uuid varchar(45), tid INT)
BEGIN

/* 	

06/09/2020 AST: Initial Creation for recording the User Interests when the user signs up first
08/11/2020 Kapil: Confirmed
*/

declare  orig_uid, pbuid INT;
declare uname, intName varchar(40) ;
declare intCode varchar(3) ;

SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USERNAME INTO orig_uid, uname FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT T.TOPIC, T.CODE INTO intName, intCode FROM OPN_TOPICS T WHERE T.TOPICID = tid ;

DELETE FROM OPN_USER_INTERESTS WHERE USERID = orig_uid ;

INSERT INTO OPN_USER_INTERESTS(USERID, USER_UUID, INTEREST_ID, INTEREST_NAME, INTEREST_CODE, CREATION_DTM, USERNAME)
VALUES (orig_uid, uuid, tid, intName, intCode, NOW(), uname);


END //
DELIMITER ;

-- -- searchkeyword

DELIMITER //
DROP PROCEDURE IF EXISTS searchkeyword //

CREATE DEFINER=`root`@`%` PROCEDURE `searchkeyword`(tid INT, uuid varchar(45), country_code VARCHAR(5), searchterm varchar(60))
BEGIN
/*26-03-2020 Rohit:- 
Remove the substring search. Search as a entire string at once

06/17/2018 AST: Initial Proc creation for Search
11/02/2018 AST: changed the joins to OPUC as outer joins

call searchkeyword(8, bringUUID(1017005), 'IND', 'GOOGLE') ;

MAY-10-2020 AST: Removing @ from the @orig_uid and @UNAME

MAY-10-2020 AST: Including a filter where private KWs will not be displayed in the list of search results

06/02/2020 AST: Rebuilding with removal of @  

08/11/2020 Kapil: Confirmed
 */

declare  orig_uid INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE STERM VARCHAR(70) ;

SET orig_uid := (SELECT  bringUserid(uuid));
SET UNAME := (SELECT USERNAME FROM OPN_USERLIST WHERE USER_UUID = uuid) ;


SET STERM := CONCAT('%', searchterm , '%');

/* adding the user action trace portion. */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'searchKW', concat(tid,'-',searchterm));

/* end of use action tracking */

CASE WHEN country_code = 'GGG' THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
     /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('USA')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  NOT IN ('USA', 'GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
WHEN country_code = 'USA' THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('USA')
    AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
         /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  NOT IN ('USA', 'GGG')
          AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
               /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
WHEN country_code NOT IN ('USA' , 'GGG') THEN

SELECT KEYID, KEYWORDS, QSRC, HCOUNT, LCOUNT, TCOUNT FROM (
SELECT K.KEYID, K.KEYWORDS, 'A' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN (country_code)
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'B' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE  IN ('GGG')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
                UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'C' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE IN ('USA')
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM )  
        GROUP BY K.KEYID, K.KEYWORDS
                        UNION ALL
SELECT K.KEYID, K.KEYWORDS, 'D' QSRC, SUM(CASE WHEN CART = 'H' THEN 1 ELSE 0 END) HCOUNT
, SUM(CASE WHEN CART = 'L' THEN 1 ELSE 0 END) LCOUNT, SUM(1) TCOUNT
FROM OPN_P_KW K LEFT OUTER JOIN OPN_USER_CARTS UC
ON K.KEYID = UC.KEYID
        WHERE K.TOPICID = tid AND K.COUNTRY_CODE NOT IN ('USA', 'GGG', country_code)
                     AND K.KEYID NOT IN (SELECT OUC.KEYID FROM OPN_USER_CARTS OUC WHERE OUC.USERID = orig_uid AND OUC.TOPICID = tid )
                          /* start of filtering out the Private KWs - in each non-cart UNION below */
      AND K.KEYID NOT IN (SELECT KW.KEYID FROM OPN_P_KW KW WHERE KW.PRIVATE_KW_FLAG = 'Y' )
      /* start of filtering out the Private KWs  */  
      AND ( K.KEYWORDS LIKE STERM)  
        GROUP BY K.KEYID, K.KEYWORDS
        ) QQ
        ORDER BY QSRC, TCOUNT DESC;
        
        END CASE ;




END//
DELIMITER ;

-- -- setUserChatFlag

 DELIMITER //
DROP PROCEDURE IF EXISTS setUserChatFlag //
CREATE PROCEDURE setUserChatFlag(UUID varchar(45), chatflag varchar(5))
BEGIN

/* 08/24/2020 Kapil: Enable Disable user Chat  */

declare  orig_uid INT;

SET orig_uid := (SELECT  bringUserid(UUID));

UPDATE OPN_USERLIST U SET U.CHAT_FLAG = chatflag  WHERE U.USERID = orig_uid ;

END  //
DELIMITER ;

-- -- suspendUser

-- 

 DELIMITER //
DROP PROCEDURE IF EXISTS suspendUser //
CREATE PROCEDURE suspendUser(uname varchar(40) )
BEGIN

/* 
09/07/2020 AST: initial Creation
		this proc is used for banning the user and all his profiles that we can find

 */

declare UID INT ;
DECLARE UUID VARCHAR(45) ;
DECLARE UTYPE VARCHAR(3) ;
DECLARE UDEVICE VARCHAR(200) ;
DECLARE UEMAIL, UFBID, UGID, UAID VARCHAR(100) ;
 SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USER_UUID, FB_USER_FLAG, FB_USERID, IDENTIFIER_TOKEN, G_USERID, EMAIL_ADDR, A_USERID
INTO UID, UUID, UTYPE, UFBID, UDEVICE, UGID, UEMAIL, UAID FROM OPN_USERLIST  WHERE USERNAME = uname ;

CASE WHEN UTYPE = 'Y' THEN
UPDATE OPN_USERLIST SET USER_SUSPEND_FLAG = 'Y' WHERE FB_USERID = UFBID ;

 WHEN UTYPE = 'A' THEN
UPDATE OPN_USERLIST SET USER_SUSPEND_FLAG = 'Y' WHERE A_USERID = UAID ;

 WHEN UTYPE = 'G' THEN
UPDATE OPN_USERLIST SET USER_SUSPEND_FLAG = 'Y' WHERE G_USERID = UGID ;

 WHEN UTYPE = 'N' THEN
UPDATE OPN_USERLIST SET USER_SUSPEND_FLAG = 'Y' WHERE USERID = UID ;

END CASE ;

END //
DELIMITER ;

-- -- userActionCommon

 DELIMITER //
DROP PROCEDURE IF EXISTS userActionCommon //
CREATE PROCEDURE userActionCommon(uuid varchar(45), actionSource VARCHAR(10), actionType varchar(5), sourceID INT)
BEGIN

/*
	06/04/2020 AST: Building this proc as a combined proc for User Post or Comment Actions
	When a user Loves or Hates a Post or a Comment, this proc will record the action.
    As usual, it will first delete any existing actions - in order to avoid possible doubles.alter
    
    actionSource 	= POST/COMMENT
    actionType 		= L/H 
    sourceID		= POST_ID/COMMENT_ID
	
	08/11/2020 Kapil: Confirmed
*/

declare  ORIG_UID, causePostID, TID, causeCommentID, postByUID, commentByUID INT;
DECLARE actionTypeNew,UNAME VARCHAR(30) ;

CASE WHEN actionSource = 'COMMENT' THEN

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT OPC1.TOPICID, OPC1.COMMENT_BY_USERID, OPC1.CAUSE_POST_ID INTO TID, commentByUID, causePostID
FROM OPN_POST_COMMENTS OPC1 WHERE OPC1.COMMENT_ID = sourceID ;

/* Adding user action logging portion - in case we want to turn this on for this proc */
/*
INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, ORIG_UID, uuid, NOW(), 'userCommentLH'
, CONCAT(ORIG_UID, ' - COMMENT -',actionType, ' FOR COMMENT_ID = ', sourceID));
*/
/* end of use action tracking */

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.ACTION_BY_USERID = ORIG_UID 
AND OPN_USER_POST_ACTION.CAUSE_COMMENT_ID = sourceID 
AND OPN_USER_POST_ACTION.COMMENT_BY_USERID =  commentByUID ;

CASE WHEN actionType = 'L1' or actionType = 'H1' THEN
IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;
INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, COMMENT_BY_USERID, ACTION_TYPE, POST_ACTION_DTM
, CAUSE_COMMENT_ID, ACTION_SOURCE, TOPICID) 
VALUES (ORIG_UID, commentByUID, actionTypeNew, NOW(), sourceID, 'COMMENT', TID) ;
ELSE BEGIN END;
END CASE ;

WHEN actionSource = 'POST' THEN

SELECT U1.USERNAME, U1.USERID INTO UNAME, ORIG_UID FROM OPN_USERLIST U1 WHERE U1.USER_UUID = uuid ;

SELECT TOPICID, POST_BY_USERID INTO TID, postByUID FROM OPN_POSTS WHERE POST_ID = sourceID ;

/* Adding user action logging portion */



/* end of use action tracking */

DELETE FROM OPN_USER_POST_ACTION WHERE OPN_USER_POST_ACTION.ACTION_BY_USERID = ORIG_UID 
AND OPN_USER_POST_ACTION.CAUSE_POST_ID = sourceID 
AND OPN_USER_POST_ACTION.POST_BY_USERID =  postByUID ;

CASE WHEN actionType = 'L1' or actionType = 'H1' THEN
IF actionType = 'L1' THEN
   SET actionTypeNew = 'L';
ELSE
   SET actionTypeNew = 'H';
END IF;
INSERT INTO OPN_USER_POST_ACTION (ACTION_BY_USERID, POST_BY_USERID, POST_ACTION_TYPE, POST_ACTION_DTM
, CAUSE_POST_ID, ACTION_SOURCE, TOPICID) 
VALUES (ORIG_UID, postByUID, actionTypeNew, NOW(), sourceID, 'POST', TID) ;
ELSE BEGIN END;
END CASE ;

END CASE ;

END //
DELIMITER ;

-- 
-- userContentReport

DELIMITER //
DROP PROCEDURE IF EXISTS userContentReport //
CREATE PROCEDURE userContentReport(uuid varchar(45), contentID INT, contentType varchar(10)
, reportTypeCode varchar(5), userComment varchar(100))
thisProc: BEGIN

/* 	

	06/30/2020 AST: Initial Creation for recording the User Reporting 
	a specific content for UGC violation

	07/09/2020 AST: Adding KOUserCommon to complete the Report Content action
	
	08/11/2020 Kapil: Confirmed

*/

declare  byUID, againstUID, TID INT;
declare byUname, againstUname, againstUUID, byFGID, againstFGID varchar(45) ;
DECLARE EMBURL, MEDCONTENT VARCHAR(1000) ;

SET SQL_SAFE_UPDATES = 0;

SELECT USERID, USERNAME, IFNULL(G_USERID, FB_USERID)  
INTO byUID, byUname, byFGID FROM OPN_USERLIST WHERE USER_UUID = uuid ;

CASE WHEN contentType = 'POST' THEN

SELECT P.POST_BY_USERID, P.TOPICID, P.EMBEDDED_CONTENT, P.MEDIA_CONTENT
, U.USER_UUID, U.USERNAME, IFNULL(U.G_USERID, U.FB_USERID)
INTO againstUID, TID, EMBURL, MEDCONTENT, againstUUID, againstUname, againstFGID
FROM OPN_POSTS P, OPN_USERLIST U
WHERE P.POST_BY_USERID = U.USERID AND P.POST_ID = contentID;

WHEN contentType = 'COMMENT' THEN

SELECT C.COMMENT_BY_USERID, C.TOPICID, C.EMBEDDED_CONTENT, C.MEDIA_CONTENT
, U.USER_UUID, U.USERNAME, IFNULL(U.G_USERID, U.FB_USERID)
INTO againstUID, TID, EMBURL, MEDCONTENT, againstUUID, againstUname, againstFGID
FROM OPN_POST_COMMENTS C, OPN_USERLIST U
WHERE C.COMMENT_BY_USERID = U.USERID AND C.COMMENT_ID = contentID;

END CASE ;

INSERT INTO OPN_USER_REPORTED_CONTENT(REPORTING_USERID, REPORTING_UUID, REPORTING_UNAME
, REPORTING_DTM, REPORT_TYPE, REPORTING_UFGID, CONTENT_TYPE, USER_COMMENT, TOPICID
, CONTENT_ID, EMBEDDED_URL, MEDIA_CONTENT, AGAINST_USERID, AGAINST_UUID, AGAINST_UNAME)
VALUES(byUID, UUID, byUNAME
, NOW(), reportTypeCode, byFGID, contentType, userComment, TID
, contentID, EMBURL, MEDCONTENT, againstUID, againstUUID, againstUname) ;

CALL KOUserCommon(uuid, contentType, contentID) ;

 
END; //
 DELIMITER ;
 
 -- -- userKWReport

 DELIMITER //
DROP PROCEDURE IF EXISTS userKWReport //
CREATE PROCEDURE userKWReport(uuid VARCHAR(45), TID INT, KID INT, userComment VARCHAR(40))
BEGIN

/* 07/27/2020 AST: Initial Creation - to allow users to report inappropriate keywords 
08/11/2020 Kapil: Confirmed
*/

DECLARE KW VARCHAR(150) ;
DECLARE UNAME VARCHAR(40) ;
DECLARE CCODE VARCHAR(5) ;
DECLARE UID INT;

SELECT USERID, USERNAME INTO UID, UNAME FROM OPN_USERLIST WHERE USER_UUID = uuid ;
SELECT KEYWORDS, COUNTRY_CODE INTO KW, CCODE FROM OPN_P_KW WHERE KEYID = KID ;

/* USER BHV SECTION */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, uuid, NOW(), 'userKWReport', CONCAT(KW,'-',userComment));

/* END OF USER BHV SECTION */

INSERT INTO OPN_USER_KW_REPORT(TOPICID, KEYID, KEYWORDS, REPORTED_UID, REPORTED_UUID
, REPORTED_UNAME, REPORT_DTM, REPORT_REASON, KW_CCODE)
VALUES(TID, KID, KW, UID, uuid
, UNAME, NOW(), userComment, CCODE) ;

END //
DELIMITER ;

-- 
-- userLoginApp

 DELIMITER //
DROP PROCEDURE IF EXISTS userLoginApp //
CREATE PROCEDURE userLoginApp(username varchar(30), pwd varchar(20), device_serial VARCHAR(40))
BEGIN

/* 04012018 AST: Added insret into proc log 
08/11/2020 Kapil: Confirmed
*/

DECLARE UID INT;
DECLARE UUID VARCHAR(45);

SET UID = (SELECT OU.USERID FROM OPN_USERLIST OU WHERE UPPER(OU.USERNAME) = UPPER(username));
SET UUID = (SELECT OU.USER_UUID FROM OPN_USERLIST OU WHERE UPPER(OU.USERNAME) = UPPER(username));

INSERT INTO OPN_ULOGIN_HIST(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL)
VALUES(username, UID, UUID, NOW(), 'userLogin');

INSERT INTO OPN_USER_DEVICE_LOG(USERID, USER_UUID, LOGIN_DTM, DEVICE_ID, OK_FLAG)
VALUES(UID, UUID, NOW(), device_serial, 'Y');

SELECT -- U.USERID, 
U.USER_UUID USERID, U.COUNTRY_CODE  , doesCartExist(username) CARTORNOT
 from OPN_USERLIST U
 WHERE U.USERNAME = username  and AES_DECRYPT(U.password,'290317') = pwd;
 
 

END //
DELIMITER ;

-- -- userActionCommon

 DELIMITER //
DROP PROCEDURE IF EXISTS userPostSearch //
CREATE PROCEDURE userPostSearch(UUID varchar(45), tid INT, searchterm varchar(60),fromindex INT, toindex INT)
BEGIN

/*
07/17/2020 AST: Building this proc as a Search for Posts
07/20/2020 AST: Added the T.TOPICID = tid FILTER
07/23/2020 AST: Added ORDER BY POST_ID DESC 
08/11/2020 Kapil: Confirmed
10/03/2020 AST: Changed the filter for CCODE to avoid showing BOT posts across the countries
				Exception GGG for handling the SCI posts - which are BOT and need to be 
                shown across the CCODE
*/

declare  UID INT;
declare CCODE varchar(5) ;
DECLARE UNAME VARCHAR(30) ;

SELECT USERID, USERNAME, COUNTRY_CODE INTO UID, UNAME, CCODE FROM OPN_USERLIST WHERE USER_UUID = UUID  ;

/* USER BEHAVIOR LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'userPostSearch', CONCAT(tid, '-', searchterm));

/* END OF USER BEHAVIOR LOG */

SELECT POST_ID, POST_BY_UID, POST_BY_UNAME, POST_DTM, POST_CONTENT 
FROM (
SELECT T.POST_ID, T.POST_BY_UID, T.POST_BY_UNAME, T.POST_DTM, T.POST_CONTENT
FROM OPN_POST_SEARCH_T T
, (SELECT DISTINCT B.USERID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = UID) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID AND
 C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = UID 
AND OUUA.TOPICID = tid AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART 
AND A.KEYID = B.KEYID AND A.TOPICID = tid) UN
 WHERE T.POST_BY_UID = UN.USERID AND T.POSTOR_CCODE IN (CCODE, 'GGG')  AND T.TOPICID = tid
 AND MATCH(SEARCH_STRING) AGAINST (searchterm IN boolean MODE) 
 UNION ALL
 SELECT T.POST_ID, T.POST_BY_UID, T.POST_BY_UNAME, T.POST_DTM, T.POST_CONTENT
FROM OPN_POST_SEARCH_T T
, (SELECT DISTINCT B.USERID FROM
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 
WHERE C1.USERID = UID) A ,
(SELECT C2.USERID, CU.BOT_FLAG, C2.TOPICID, C2.CART, C2.KEYID, C2.CREATION_DTM 
FROM OPN_USER_CARTS C2, OPN_USERLIST CU WHERE C2.USERID = CU.USERID 
AND CU.BOT_FLAG <> 'Y' 
AND C2.USERID NOT IN (SELECT OUUA.ON_USERID FROM OPN_USER_USER_ACTION OUUA 
 WHERE OUUA.BY_USERID = UID 
AND OUUA.TOPICID = tid AND OUUA.ACTION_TYPE = 'KO')) B 
WHERE A.TOPICID = B.TOPICID AND A.CART = B.CART 
AND A.KEYID = B.KEYID AND A.TOPICID = tid) UN
 WHERE T.POST_BY_UID = UN.USERID AND T.POSTOR_CCODE NOT IN (CCODE, 'GGG')  AND T.TOPICID = tid
 AND MATCH(SEARCH_STRING) AGAINST (searchterm IN boolean MODE) 
 )Q
ORDER BY POST_ID DESC LIMIT fromindex, toindex;

END //
DELIMITER ;

-- 
-- 

DELIMITER //
DROP PROCEDURE IF EXISTS usernamelist // 
CREATE PROCEDURE usernamelist(username VARCHAR(25), logintype varchar(20))
BEGIN

/* 07/02/2020 Rohit: Added insret into proc log 
call usernamelist("rohit","com.facebook");

07/11/2020 AST: Changed CONCAT_VALUES  to CONCAT(username, '-', logintype)
08/11/2020 Kapil: Confirmed
*/
DECLARE ID VARCHAR(50);

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('usernamelist', NOW(), 'USERNAME', CONCAT(username, '-', logintype)) ;

CASE WHEN logintype = "com.google" THEN

SELECT OU.G_USERID INTO ID FROM OPN_USERLIST OU WHERE OU.USERNAME = username ;

SELECT OU.USER_UUID USERID, OU.USERNAME, OU.COUNTRY_CODE 
FROM OPN_USERLIST OU WHERE OU.G_USERID = ID LIMIT 5;

WHEN logintype= 'com.facebook' THEN
SELECT OU.FB_USERID INTO ID FROM OPN_USERLIST OU WHERE OU.USERNAME = username ;
SELECT OU.USER_UUID USERID, OU.USERNAME, OU.COUNTRY_CODE FROM OPN_USERLIST OU 
WHERE OU.FB_USERID = ID LIMIT 5;

END CASE;

END //
DELIMITER ;

-- 
-- whoLHMyPost

 DELIMITER //
DROP PROCEDURE IF EXISTS whoLHMyPost //
CREATE PROCEDURE whoLHMyPost(UUID varchar(45), postID INT, LorH varchar(2), fromIndex INT, toIndex INT)
BEGIN

/*
07/20/2020 AST: Initial Creation - Proc to find the list of Users who 
Loved or Hated my post
                    
CALL whoLHMyPost(BRINGUUID(1006545), 659819, 'L', 0,20) ;
08/11/2020 Kapil: Confirmed
	08/25/2020 AST: adding CHF to all users
*/

declare UID INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CHFG VARCHAR(4) ;

SELECT USERID, USERNAME, CHAT_FLAG INTO UID, UNAME, CHFG FROM OPN_USERLIST WHERE USER_UUID = UUID  ;

/* USER BEHAVIOR LOG */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, UID, UUID, NOW(), 'whoLHMyPost', CONCAT(postID, '-', LorH));

/* END OF USER BEHAVIOR LOG */

SELECT UL.USERNAME, CASE WHEN CHFG = 'N' THEN 'N' ELSE UL.CHAT_FLAG END CHF
, UP.POST_ACTION_DTM,UL.DP_URL 
FROM OPN_USER_POST_ACTION UP, OPN_USERLIST UL
WHERE UP.ACTION_BY_USERID = UL.USERID
AND UP.CAUSE_POST_ID = postID AND UP.POST_ACTION_TYPE = LorH
ORDER BY UP.POST_ACTION_DTM DESC 
LIMIT fromindex, toindex;



END //
DELIMITER ;

-- 

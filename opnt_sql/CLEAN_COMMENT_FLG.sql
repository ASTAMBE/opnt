-- CLEAN_COMMENT_FLG
 
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
 
   08/03/2023 AST: Replacing the IF inside SELECT with CASE inside SELECT. This is because the IF inside SELECT was
  a wrong syntax and was not working.
 
 */
 
 
 
   
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
 CASE WHEN URL1 IN (select U_DOMAIN from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POST_COMMENTS SET CLEAN_COMMENT_FLAG = 'Y'
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
 END CASE;
 
 WHEN UCNT = 2 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1)) ;
 SET URL2 = TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
 
 CASE WHEN (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) ) THEN
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
   END CASE;
  
    WHEN UCNT = 3 THEN SET URL1 =  TRIM(substring_index(EMB, ',', 1))  ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1)) ;
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1)) ;

 CASE WHEN (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
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
   END CASE;
  
       WHEN UCNT = 4 THEN SET URL1 =   TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1)) ;

 CASE WHEN (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
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
   END CASE;
  
          WHEN UCNT = 5 THEN SET URL1 =   TRIM(substring_index(EMB, ',', 1) ) ;
 SET URL2 =  TRIM(substring_index(substring_index(EMB, ',', 2), ',', -1) );
  SET URL3 = TRIM(substring_index(substring_index(EMB, ',', 3), ',', -1) );
    SET URL4 = TRIM(substring_index(substring_index(EMB, ',', 4), ',', -1) );
        SET URL5 = TRIM(substring_index(substring_index(EMB, ',', 5), ',', -1) );
        
 CASE WHEN (URL1 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT U_DOMAIN FROM OPN_CLEAN_DOMAINS)
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
   END CASE ;
  
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

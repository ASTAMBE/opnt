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
  
  03/31/2022 AST: Replaced U_DOMAIN with SITE_NAME because the app now sends the umbedded domain in this form
 
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
 if URL1 IN (select SITE_NAME from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
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
 
 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) ) THEN 
 
 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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
 if URL1 IN (select SITE_NAME from OPN_CLEAN_DOMAINS) THEN UPDATE OPN_POSTS SET CLEAN_POST_FLAG = 'Y' 
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
 
 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) ) THEN 
 
 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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

 IF (URL1 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL2 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL3 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS) AND URL4 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)
 AND URL5 IN (SELECT SITE_NAME FROM OPN_CLEAN_DOMAINS)) THEN 
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
 
 -- 
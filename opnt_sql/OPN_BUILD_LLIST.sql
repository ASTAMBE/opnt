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
DELIMITER ;
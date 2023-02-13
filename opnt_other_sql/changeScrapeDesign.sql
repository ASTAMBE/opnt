-- changeScrapeDesign

DELIMITER //
DROP PROCEDURE IF EXISTS changeScrapeDesign //
CREATE PROCEDURE changeScrapeDesign(tid INT, kid INT, kw VARCHAR(100), stag2 VARCHAR(60), scpDesignFlag varchar(3), L1 VARCHAR(60), L2 VARCHAR(60)
, L3 VARCHAR(60), L4 VARCHAR(60), L5 VARCHAR(60), L6 VARCHAR(60), NL1 VARCHAR(60), NL2 VARCHAR(60), NL3 VARCHAR(60)  )
thisProc: BEGIN

/*   
05/15/2021 AST: This proc is created for the following purpose:

1. When an existing significant KW is not scrape_designed (due to the history of how the scrape design was developed
some KWs already existed and they were not scrape-designed yet.

2. When a new KW seems to be badly scrape designed and needs re-design with manual intervention

3. When we want to turn off the scrape : scpDesignFlag in the input param is sent as 'N'. This will make the 
SCRAPE_DESIGN_DONE = 'N' in OPN_KW_TAGS. This will turn off any further scrapes using this KW.

Also adding the OPN_P_KW.CLEAN_KW_FLAG = 'J' (J FOR JUNK). This will prevent this KW from showing up in the cart 
- once the getUserCart is modified properly.

*/

DECLARE KIDCHANGE INT ;

SELECT KT.KEYID INTO KIDCHANGE FROM OPN_KW_TAGS KT WHERE KT.KEYID = kid AND KT.KEYWORDS = KW ;

CASE WHEN scpDesignFlag = 'N' THEN

UPDATE OPN_KW_TAGS SET SCRAPE_DESIGN_DONE = 'R', LIKE1 = NULL, LIKE2 = NULL, LIKE3 = NULL, LIKE4 = NULL
, LIKE5 = NULL, LIKE6 = NULL, NOT_LIKE1 = NULL, NOT_LIKE2 = NULL, NOT_LIKE3 = NULL 
WHERE TOPICID = tid AND KEYID = KIDCHANGE ;

UPDATE OPN_P_KW SET CLEAN_KW_FLAG = 'J' WHERE TOPICID = tid AND KEYID = KIDCHANGE ;

/* Adding user action logging portion */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('changeScrapeDesign', NOW(), 'scpDesignFlag=N', CONCAT(tid, '-', kid)) ;

/* end of use action tracking */

WHEN scpDesignFlag = 'Y' THEN 

UPDATE OPN_KW_TAGS SET SCRAPE_DESIGN_DONE = 'Y', SCRAPE_TAG2 = stag2, LIKE1 = L1, LIKE2 = L2, LIKE3 = L3, LIKE4 = L4
, LIKE5 = L5, LIKE6 = L6, NOT_LIKE1 = NL1, NOT_LIKE2 = NL2, NOT_LIKE3 = NL3, SCRAPE_DESIGN_DTM = NOW()
WHERE TOPICID = tid AND KEYID = KIDCHANGE ;

UPDATE OPN_P_KW SET SCRAPE_TAG2 = stag2 WHERE TOPICID = tid AND KEYID = KIDCHANGE ;

/* Adding user action logging portion */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('changeScrapeDesign', NOW(), 'scpDesignFlag=Y', CONCAT(kid, '-', stag2)) ;

/* end of use action tracking */

END CASE ;

END; //
 DELIMITER ;
 
 -- 
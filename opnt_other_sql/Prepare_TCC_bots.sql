/* Prepare TCC bots
This script is for achieving the following goals:
1. It needs to convert some of the GGG bots into TCC bots - depending on the % of TCC out of GGG and the number of GGG bots available
2. It needs to generate (or use the generated names form openAI) or update the bot names to real-sounding names
3. It needs to ensure that these BOTS have the XYZ KIDs in their cart
4. Ensure that OPN_MAIN_BOTS is in sync with OPN_USERLIST

There are around 9200 non-NGA, non-GGG actual users - for the sake of ease, we will assign 30 bots for each of the top 10 countries 
SLE, KEN, UGA, ZAF,ZMB, PHL, TZA, PAK, BGD
SLE	966
GHA	848
KEN	836
UGA	669
ZAF	611
ZMB	404
PHL	336
TZA	332
PAK	244
BGD	234

there are 357 distinct non-NGA GGG bots in the OPN_MAIN_BOTS while 93 distinct NGA bots 
There are 952 GGG non-NGA bots - we need to assign  roughly 60 each for the top 10 TCCs (non-NGA) - and give them names and give them camps
we will give real names to all the bots - but only some of them will be MAIN BOTs - the rest would be used for STP - the main bots 
will be used for STD

*/
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM OPN_USERLIST WHERE COUNTRY_CODE = 'GGG' AND BOT_FLAG = 'Y' AND TRUE_COUNTRY_CODE IS NULL ;
SELECT TRUE_COUNTRY_CODE, COUNT(1) FROM OPN_USERLIST WHERE COUNTRY_CODE = 'GGG' AND BOT_FLAG = 'Y' GROUP BY TRUE_COUNTRY_CODE ;
SELECT TRUE_COUNTRY_CODE, COUNT(1) FROM OPN_USERLIST WHERE COUNTRY_CODE = 'GGG' AND BOT_FLAG <> 'Y' GROUP BY TRUE_COUNTRY_CODE ORDER BY 2 DESC ;
SELECT TCCODE, COUNT(DISTINCT USERID) FROM OPN_MAIN_BOTS WHERE CCODE = 'GGG' AND  IFNULL(TCCODE, 'ABC') <> 'NGA' GROUP BY TCCODE ;

CALL assignBotNamesToUsers() ;

SELECT * FROM OPN_BOT_NAMES WHERE USERID IS NULL ;
SELECT * FROM OPN_USERLIST WHERE USERID = 1020607 ;
SELECT * FROM OPN_USERLIST WHERE TRUE_COUNTRY_CODE = 'SLE' ;

WITH DUP AS (
SELECT NAME, COUNT(1) FROM OPN_BOT_NAMES GROUP BY NAME HAVING COUNT(1) > 1)
UPDATE OPN_BOT_NAMES SET NAME = CONCAT(NAME, ROW_ID) WHERE NAME IN (SELECT NAME FROM DUP) ;

SELECT USERID, COUNT(1) FROM OPN_BOT_NAMES GROUP BY USERID HAVING COUNT(1) > 1 ;
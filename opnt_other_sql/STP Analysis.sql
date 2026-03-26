-- 02/03/2024 
/* Need to fix the following issues/behaviors: 
1. Make sure that the KWs shown in the cart screen - the ones that are NOT yet selected - must be: the latest ones, and also from the same country code
2. The instream and discussions should be latest and only from the ccode of the user
3. showInitialDiscussions also needs to adhere to the rule 1 above:
4. The Trending seems to be mostly empty - fix it asap
*/

-- 1. get the cart screen output but with the creation date of the KW

SELECT * FROM OPN_P_KW WHERE KEYID IN (114076, 112323, 111185, 111229, 114128, 112304, 111132) ORDER BY CREATION_DTM DESC;

/* Looks like the getUserCarts is working as designed. Found that the new userid 1033748 (astcmcDev012024) got the latest TID1 USA
KWs as of 12/19 (2) and 11/29 (2) amd 11/25 etc. Hence now the q is: Have there been USA POL KWs created in the last few days ?
and if yes, why hasn't the new user received them in the cart screen - this may be bcause the new user is auto assigned Politics News (105087) 
and the algo for distributing the new KWs does not use this specific KW - but uses only the new KWs - this creates a bad circle
let's check 
*/

SELECT SCRAPE_DATE, COUNT(1) FROM WSR_CONVERTED where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 10 DAY 
and SCRAPE_TOPIC = 'POLITICS' AND COUNTRY_CODE = 'USA' GROUP BY SCRAPE_DATE order by 1 ;

-- LOOKS LIKE USA POL SCRAPES ARE NOT HAPPENING AT ALL - WTF 

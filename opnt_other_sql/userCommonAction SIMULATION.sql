-- DEBUGGING WHY THE L/H ACTION ON THE INSTREAM POSTS IS NOT WORKING

/* STEP 1: First check in the OPN_USER_BHV_LOG and OPN_RAW_LOGS if the user action of repeatedly trying to indicate L/H is actually being captured by the app and
 the appropriate data is being logged
 Logged in as astcmcprod0607 (1022727), trying to click H on the second post in the Politics instream. The first post 1508999 was tried with L
 and it worked - it registered the L, also created the KW and kept it in the user's cart
 */

CALL getInstreamNW(bringUUID(1022727), 1, 0, 30) ; -- POST_ID 1508999 AND 1508897
SELECT * FROM OPN_USER_BHV_LOG ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_P_KW WHERE ALT_KEYID = 1508999 ; -- KEYID 258688
SELECT * FROM OPN_RAW_LOGS ORDER BY ROW_ID DESC ;
SELECT * FROM OPN_USER_CARTS WHERE USERID = 1022727 AND TOPICID = 1 AND CREATION_DTM > CURRENT_DATE() - INTERVAL 1 DAY ;
SELECT * FROM OPN_P_KW WHERE KEYID IN (255856,256141,256110,105087) ;
SELECT * FROM OPN_P_KW where TOPICID = 1 AND COUNTRY_CODE = 'USA' ORDER BY KEYID DESC;

/* IT IS ESTABLISHED THAT FOR THE FIRST L ON THE FIRST POST IN THE INSTREA, THE PROCESS OF CONVERTING THE POST TO KW WORKED FULLY.
NOW WE WILL SIMULATE EACH STEP OF THE PROCESS FOR THE NEXT POST_ID TO SEE WHERE IT FAILS - BUT FIRST LETS USE THE PROC CALL TO SEE WHAT HAPPENS 
FOR THAT, FIRST CHECK THAT THE POST HAS NOT ALREADY BEEN CONVERTED TO KW*/

SELECT * FROM OPN_POSTS WHERE POST_ID IN (1508897, 1508783) ;
SELECT * FROM OPN_P_KW WHERE ALT_KEYID IN (1508897) OR KEYWORDS LIKE '%Cowardly, Pak sponsored terrorism%' ;

/* WOW ! FOUND THAT THE POST THAT I WAS TRYING TO 'H', HAS ALREADY BEEN CONVERTED TO A KW - BECAUSE IT HAS ALREADY APPEARED AS A DISCUSSION A WHILE AGO.
 * NOW, WE NEED TO CHECK IF THE USER ACTION (L/H) HAS BEEN RECORDED OR NOT
 */
CALL convertPostToKW(:postid, :tid, :actionbyid, :actiondtm, :actionType, :kidparam) ;
SELECT * FROM OPN_USER_POST_ACTION oupa WHERE CAUSE_POST_ID IN (1508897, 1508896, 1508783) ;
SELECT * FROM OPN_USER_POST_ACTION ORDER BY ROW_ID DESC ;

/* THIS MAY BE BECAUSE THE userActionCommon IS NOT HANDLING THE CASE WHERE WE DO THE convertPostToKW
 * At a higher level, should we convert the instream posts into KW ? if we don't then how can we use them to determine the network ?
 * we have to have them as KWs and the user input L/H recorded in order to create the network 
 * */
SELECT * FROM OPN_P_KW WHERE KEYWORDS LIKE 'Liberal pundit tells CNN%' ;
CALL userActionCommon(bringUUID(1022727), 'POST', 'H1', 1508783) ; 

SELECT * FROM OPN_P_KW WHERE KW_URL LIKE 'https://www.foxnews.com/politics/battleground-wisconsin-voters-weigh%' ;

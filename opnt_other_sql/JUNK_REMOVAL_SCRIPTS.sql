/* DATA FIXES FOR JUNK KWS

STEP 1: FIND THE JUNK: Junk KW is:
1. A KW that has found 0 auto-tagged posts - they are called JUNK0 TYPE
2. Has only one word and has found too many matches because of random matches - JUNK2 TYPE

Steps: 1. Find the Junk KWs
2. JUNK0 TYPE - THEN JUST KILL THE KW BY CALLING THE KILL_KEYWORD(ENTRYKEY VARCHAR(10), KID INT, TID INT)
3. JUNK2 TYPE: THEN 

TO BE COMPLETED*/

SELECT * FROM OPN_P_KW ORDER BY KEYID DESC ;

SELECT K.TOPICID, K.KEYID, K.KEYWORDS, K.CREATED_BY_UNAME, COUNT(P.POST_ID) FROM OPN_P_KW K, OPN_POSTS P
WHERE K.KEYID = P.TAG1_KEYID AND P.TAG1_KEYID IS NOT NULL AND P.POSTOR_COUNTRY_CODE = 'IND' AND K.TOPICID = 1
AND K.CREATION_DTM > CURRENT_DATE() - INTERVAL 2000 DAY GROUP BY K.TOPICID, K.KEYID, K.KEYWORDS, K.CREATED_BY_UNAME 
ORDER BY COUNT(P.POST_ID) DESC LIMIT 10;

SELECT * FROM OPN_KILLED_KW ;
/* deal with the issue of no posts created from the scrapes */

/* Step 1: Confirm that no posts have been created from the scrapes */

SELECT P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'Y' THEN 1 ELSE 0 END)  POSTCNT
, SUM(CASE WHEN U.BOT_FLAG = 'Y' AND P.DEMO_POST_FLAG = 'N' THEN 1 ELSE 0 END)  DISCCNT
, SUM(CASE WHEN U.BOT_FLAG <> 'Y' THEN 1 ELSE 0 END) REALPOSTS
FROM OPN_POSTS P, OPN_USERLIST U WHERE P.POST_BY_USERID = U.USERID 
AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 3 DAY GROUP BY P.STP_PROC_NAME, P.TOPICID, P.POSTOR_COUNTRY_CODE;

/* If the baove query doesn't return much for any topicid/ccode combo then that combo is having STP issues */

/* Step 2: Check if there are scrapes sitting in the WSR or WSRL - if they are, then deupe them
If they are sitting there for a long time then clean out everything that is older than 3 days */

SELECT SCRAPE_SOURCE, COUNT(1)  FROM WEB_SCRAPE_RAW where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 10 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_SOURCE ORDER BY 1, 2 DESC ;

SELECT SCRAPE_SOURCE, COUNT(1)  FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE >= CURRENT_DATE() - INTERVAL 10 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N'
GROUP BY SCRAPE_SOURCE ORDER BY 1, 2 DESC ;

SELECT COUNT(1) FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE < CURRENT_DATE() - INTERVAL 2 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' ;

DELETE FROM WEB_SCRAPE_RAW_L where SCRAPE_DATE < CURRENT_DATE() - INTERVAL 2 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' ;

CALL WSRL_DEDUPE_ALL() ; -- CAME DOWN TO 3K FROM 10 K

/* Now we want to check what is the distribution of the scrapes that are deduped and sitting in the WSRL */

SELECT SCRAPE_TOPIC, COUNTRY_CODE, COUNT(1)  FROM WEB_SCRAPE_RAW_L GROUP BY SCRAPE_TOPIC, COUNTRY_CODE ORDER BY 1, 2 ;

/* Looks like we have 13 combinations - only the IND CELEB is missing - leave that aside for the time being  */

/* Now we start converting the scrapes to discussions and to posts - the scrapes from WSRL that are not converted to
 * discussions are auto divrted to instream posts - but by sending them to WSR. Hence we need to see what is happening in the WSR also  */

SELECT COUNT(1) FROM WEB_SCRAPE_RAW where SCRAPE_DATE > CURRENT_DATE() - INTERVAL 10 DAY AND IFNULL(MOVED_TO_POST_FLAG, 'N') = 'N' ;

/* there is nothing in WSR that is even 10 days old - so we delete all of it */

DELETE FROM WEB_SCRAPE_RAW ;

/* Prior to running the STD process, we need to see where we are in the OPN_POSTS */

SELECT * FROM OPN_POSTS ORDER BY POST_ID DESC LIMIT 100 ; -- 1411535 - SEEMS TO BE A NULL POST

SELECT * FROM WEB_SCRAPE_RAW_L WHERE LENGTH(NEWS_URL) < 5 OR NEWS_URL IS NULL ; -- SINCE THERE IS NO DATA FOR THIS, WE SHOULD NOT GET ANY NULL POST FROM THIS STD




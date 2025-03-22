-- CHECK THE NW AND ANTI FOR TCC BOT USERS FOR SPECIFIC TIDS

-- LIST OF TCC BOTS WITH OCAMPS

SELECT TCCODE, USERID, USERNAME, OPINION_CAMP, TOPICID FROM OPN_MAIN_BOTS WHERE TCCODE IN ('IND', 'NGA', 'USA') AND OPINION_CAMP IS NOT NULL ORDER BY 5, 1;

call getDiscussionsNW(bringuuid(1020656), 1, 0, 30) ;
call getDiscussionsANTI(bringuuid(1020656), 1, 0, 300) ;
call getTCCDiscussionsNW(bringuuid(1020656), 1, 0, 30) ;
call getTCCDiscussionsANTI(bringuuid(1020656), 1, 0, 300) ;

call getDiscussionsNW(bringuuid(1021357), 2, 0, 30) ;
call getDiscussionsANTI(bringuuid(1021357), 2, 0, 30) ;
call getTCCDiscussionsNW(bringuuid(1021357), 2, 0, 30) ;
call getTCCDiscussionsANTI(bringuuid(1021357), 2, 0, 30) ;

call getDiscussionsNW(bringuuid(1021258), 4, 0, 30) ;
call getDiscussionsANTI(bringuuid(1021258), 4, 0, 30) ;
call getTCCDiscussionsNW(bringuuid(1021258), 4, 0, 30) ;
call getTCCDiscussionsANTI(bringuuid(1021258), 4, 0, 30) ;

call getDiscussionsNW(bringuuid(1021280), 5, 0, 30) ;
call getDiscussionsANTI(bringuuid(1021280), 5, 0, 30) ;
call getTCCDiscussionsNW(bringuuid(1021280), 5, 0, 30) ;
call getTCCDiscussionsANTI(bringuuid(1021280), 5, 0, 30) ;

call getDiscussionsNW(bringuuid(1021095), 10, 0, 30) ;
call getDiscussionsANTI(bringuuid(1021095), 10, 0, 30) ;
call getTCCDiscussionsNW(bringuuid(1021095), 10, 0, 30) ;
call getTCCDiscussionsANTI(bringuuid(1021095), 10, 0, 30) ;

-- IT HAS BEEN CONFIRMED THAT FOR NGA BOTS ALL 5 TIDS THE NW AND ANTI IS BRINING DATA
-- NOW WE TEST THE SAME THING WITH NON-BOT NGA USER

SELECT * FROM OPN_USERLIST WHERE TRUE_COUNTRY_CODE = 'NGA' ORDER BY USERID DESC ; -- 1053888, 1053727, 1053627
SELECT * FROM OPN_USER_CARTS WHERE USERID IN (1053888, 1053727, 1053627) ; -- ALL OF THEM HAVE XYZ FOR 1,2,3,4,5,10
-- THEORETICALLY, THEY SHOULD ALL HAVE SAME OR SIMILAR NW AND ANTI OUTPUT AS THE BOTS, LET'S SEE.

call getDiscussionsNW(bringuuid(1053888), 1, 0, 30) ;
call getDiscussionsANTI(bringuuid(1053888), 1, 0, 300) ; -- ZERO DATA FOR ANTI ????

-- LET'S CHECK IF THEY HAVE ANTI NETWORK: found that 1053888 had only 2 users in the ANTI nw.
-- checking how many in the bot user: bot user 1020656 has 473 in the ANTI nw - when the exclusivity is removed, it increases to 549
-- checking how many of them ar TCC NGA - MANY (MAYBE 10+) ARE NGA. even with the exclusivity, there are several - why ?
-- this could be due to the fact that the TCC bots with camps have many non XYZ items in the cart - this allows them to have 
-- a chance of having someone to oppose their opinion - whereas , reg users currently have noone to oppose the views
-- as an experiment, let's assign one or two non xyz NGA items to the reg users and see if that results into ANTI network
-- btw, the NW nw is never a problem because all of them have L for XYZ KIDs

SELECT * FROM OPN_USER_CARTS WHERE USERID = 1020656 AND TOPICID = 1 ; -- 207019,210282,211999,212981

INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)VALUES(1053888, 1, 207019, 'L', NOW(), NOW()) ; -- 229263
INSERT INTO OPN_USER_CARTS(USERID, TOPICID, KEYID, CART, CREATION_DTM, LAST_UPDATE_DTM)VALUES(1053888, 1, 229263, 'L', NOW(), NOW()) ; 

-- OK - WHEN I INSERTED ONE OF THE LATEST TCC ITEMS IN THE REG USER'S CART, THEN THE ANTI STARTED SHOWING DATA

-- THIS PROVES THAT ONCE THE REG USERS ACTUALLY START DOING L/H TO THE ACTUAL NEWS ITEMS THEY WILL ALSO GET ANTI DATA




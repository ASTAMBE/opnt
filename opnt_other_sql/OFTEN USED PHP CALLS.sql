-- OFTEN USED PHP CALLS
use opntprod;
SET SQL_SAFE_UPDATES = 0;
SET GLOBAL log_bin_trust_function_creators = 1;

CALL newPostwithmedia(1, bringUUID(1023649), 'https://www.hindustantimes.com/india-news/breaking-news-updates-october-05-2021-101633390217882-amp.html'
, 'https://www.hindustantimes.com/india-news/breaking-news-updates-october-05-2021-101633390217882-amp.html', 'Y','','N') ;

CALL getInstreamBoloANTI(bringuuid(1023377), 1, 0, 30) ;
CALL getInstreamBoloNW(bringuuid(1023377), 1, 0, 30) ;

CALL getUserCarts(1, BRINGUUID(bringUseridFromUsername('rmx185')), 'POPULAR', 0, 400) ;
CALL getUserCarts(1, BRINGUUID(1018387), 'LATEST', 0, 400) ;

CALL addcleandomain('www.deccanherald.com', 'www.deccanherald.com', 'deccanherald.com' ) ;

call createSearchKW(8, bringuuid(1003845), 'discuss absolutely any topic here', 'L') ;
CALL createGuestUserApp('astdev', 'USA', 'EAFE9C2A-698E-49E5-95AB-FA9669C0A0F5') ;
call createSearchKW(10, bringuuid(1017856), 'neha kakkar', 'L') ;


CALL copyUserCarts(bringUUID(1006539), '93d393a8-a39a-11ea-82d4-06500c451eb8', 1, 661871) ;
CALL copyUserCarts(bringUUID(1006539), BRINGUUID(1002397), 1, 661871) ;

SELECT BRINGUUID(1006539) ;

CALL searchMultiTopic(1, BRINGUUID(1016539),  'MODI') ;
SELECT * FROM OPN_USERLIST WHERE FB_USER_FLAG = 'G' ORDER BY USERID DESC ;

CALL loginWithGoogleUserApp('103771670142755987296', 'OUYV76R967FVLUYF') ;

SELECT * FROM OPN_USER_CARTS WHERE USERID IN (SELECT USERID FROM OPN_USERLIST WHERE USERNAME LIKE 'ASTCMC%' ) ;
SELECT * FROM OPN_USER_CARTS WHERE USERID IN (1022469) ;

SELECT IDENTIFIER_TOKEN FROM OPN_USERLIST WHERE USERNAME LIKE  ('ASTCMC%') ;

CALL profilephp(bringUUID(1019653)) ;
CALL myActivity(bringUUID(1019653)) ;
CALL myBookmarks(bringUUID(1022653), 1, 0, 5);

SELECT * FROM OPN_USERLIST WHERE USERNAME LIKE 'ASTCMC%' ; -- 104544264703116866030  1022726  astcmnP1  903add2d-b377-46fd-b1e2-86d497673e09
SELECT * FROM OPN_USERLIST WHERE G_USERID = '104544264703116866030' ;
CALL getUserCarts(1, BRINGUUID(bringUseridFromUsername('astcmcg2')), 'POPULAR', 0, 40) ;

CALL suggestKW('ab873770-726d-11eb-9e1a-06543c48ba09') ;
CALL suggestKW(bringUUID(1004730)) ;
SELECT * FROM OPN_USERLIST WHERE USER_UUID IN ('ab873770-726d-11eb-9e1a-06543c48ba09') ; -- 1023938 SUMIT1

SELECT * FROM OPN_USER_CARTS WHERE USERID IN (1023938) ;

CALL newCommentOnPost(bringuuid(1017510),  801552, 'POST USER COMMENTING ON HIS OWN POST POSTID 801552 PBUID 1017510', '', 'N', '', 'N') ;

CALL commentsByPostNW(801552, bringuuid(1017510), 'NEWONTOP', 0,10) ;
CALL singleKWCart(BRINGUUID(1016863), 5001, 1, 'L') ;

CALL openKWbyIP() ;

CALL openKeywords(1, bringUUID(1023678)) ;
CALL openKeywords(1, bringUUID(1023385)) ;

CALL openKWbyIP(1, bringUUID(1023649), 'IN-DL') ;
CALL openKWbyIP(1, bringUUID(1023649), 'IN-MH') ;
CALL openKWbyIP(1, '8079af80-04b8-11ec-8112-061dbb11189b', 'IN-DL') ;

CALL getDiscussionsNW(bringUUID(1023377), 1, 0, 300) ; 
CALL getDiscussionsANTI(bringUUID(1023618), 1, 0, 300) ; 

CALL myActivity(bringUUID(1023649)) ;

call userOpinions(1, bringUUID(1023678)) ; -- 4bf84852-2027-11ec-8b81-061dbb11189b
call userOpinions(1, '4bf84852-2027-11ec-8b81-061dbb11189b') ; -- 4bf84852-2027-11ec-8b81-061dbb11189b

select * from OPN_USERLIST where USER_UUID = '8079af80-04b8-11ec-8112-061dbb11189b' ;
call getPostCounts(bringUUID(1023678), 1) ;
call getDiscussionCounts(bringUUID(1023618), 1) ;


SELECT bringDiscussionCountNW(bringUUID(1023377), 1) ;
SELECT bringDiscussionCountANTI(bringUUID(1023377), 1) ;

CALL getNetworkDetailsBolo('Redmi 7398', bringUUID(1023757), 1) ;
CALL getNetworkDetailsBolo('astbolo101121', bringUUID(1023818), 1) ;
CALL getNetworkDetails('astbolo101121', bringUUID(1023818), 1) ;

SELECT * FROM OPN_USER_CARTS WHERE USERID = 1023385 AND TOPICID = 1 ;

CALL networkNamesByUserName('db70937e-2b16-11ec-9935-061dbb11189b', 1, 0, 100) ;
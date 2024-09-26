-- getInstreamTrendingANTI

-- USE `opntprod`;
DROP procedure IF EXISTS `getInstreamTrendingANTI`;

DELIMITER $$
-- USE `opntprod`$$
CREATE  PROCEDURE `getInstreamTrendingANTI`(uuid varchar(45), tid INT , fromindex INT, toindex INT
)
thisproc: BEGIN

/* 
   03/19/2023: AST: This proc is written in order to divert the 'Trending' Instream to what matters to the user.
   Previously Trending (topicid = 9) was like any other topic, with its own independent keywords, cart and instream.
   But that is not the real 'Trending'. SO it is being re-purposed as Trending among the things that the user 
   cares about. So it will use a combined instream for all topics in which the user has cart/s and the main thing is to 
   have special sorting techniques to give a user-specific Trending experience.
   
   CUrrently, the ranking is such that all the posts that the user has expressed L/H for will have the L/H action date 
   to sub for the POST_DTM. Hence they will appear at the top of the Trending 
   In future, we will also incorp. the latest comment_dtm to enhance the ordering of the posts.
        
 */
 
declare  orig_uid, TIDCNT, LASTTID, CARTCNT INT;
DECLARE UNAME VARCHAR(30) ;
DECLARE CDTM DATETIME ;
DECLARE CCODE, SUSPFLAG VARCHAR(5) ;

SELECT UL.USERID, UL.USERNAME, UL.COUNTRY_CODE, UL.USER_SUSPEND_FLAG
INTO orig_uid, UNAME, CCODE, SUSPFLAG FROM OPN_USERLIST UL WHERE UL.USER_UUID = uuid ;

/* Adding user action logging portion */

INSERT INTO OPN_USER_BHV_LOG(USERNAME, USERID, USER_UUID, LOGIN_DTM, API_CALL, CONCAT_PARAMS)
VALUES(UNAME, orig_uid, uuid, NOW(), 'getInstreamTrendingANTI', CONCAT(tid,'-',toindex));


/* end of use action tracking */


/* 04/06/2021 INSERTING THE SUSPENDED USER EXCLUSION BELOW */
CASE WHEN SUSPFLAG = 'Y' THEN LEAVE thisproc ;
WHEN SUSPFLAG <> 'Y' THEN
/* 04/06/2021 END OF THE SUSPENDED USER EXCLUSION */

SELECT 
    INSTREAM.POST_ID,
    INSTREAM.TOPICID,
    CASE WHEN UP.POST_ACTION_TYPE IS NOT NULL THEN UP.POST_ACTION_DTM ELSE INSTREAM.POST_DATETIME END POST_DATETIME,
    INSTREAM.POST_BY_USERID,
    OU.USERNAME,
    OU.DP_URL,
    INSTREAM.MEDIA_CONTENT,
    INSTREAM.MEDIA_FLAG,
    INSTREAM.POST_CONTENT,
    INSTREAM.TOTAL_NS,
    IFNULL(POST_LHC.LCOUNT, 0) LCOUNT,
    IFNULL(POST_LHC.HCOUNT, 0) HCOUNT,
    UP.POST_ACTION_TYPE,
    UUA.ACTION_TYPE UU_ACTION,
    OPC.POST_COMMENT_COUNT,
    CASE
        WHEN BK2.POST_ID IS NOT NULL THEN 'B'
        ELSE NULL
    END BOOKMARK_FLAG
FROM
    (SELECT 
        P.POST_ID,
            P.TOPICID,
            P.POST_DATETIME,
            P.POST_UPDATE_DTM,
            P.POST_BY_USERID,
            P.POST_CONTENT,
            1 TOTAL_NS,
            P.MEDIA_CONTENT,
            P.MEDIA_FLAG
    FROM
        OPN_POSTS P, (SELECT DISTINCT
        B.USERID  -- , B.BOT_FLAG, A.TOPICID, A.CART_LDTM
    FROM
        (SELECT  
        C1.USERID, C1.TOPICID, C1.CART, C1.KEYID, C1.LAST_UPDATE_DTM CART_LDTM
    FROM
        OPN_USER_CARTS C1
    WHERE
        C1.USERID = orig_uid AND C1.TOPICID <> 9) A, (SELECT 
        C2.USERID,
            CU.BOT_FLAG,
            C2.TOPICID,
            C2.CART,
            C2.KEYID,
            C2.CREATION_DTM
    FROM
        OPN_USER_CARTS C2, OPN_USERLIST CU
    WHERE
        C2.USERID = CU.USERID
        AND CU.BOT_FLAG = 'Y' AND CU.COUNTRY_CODE = CCODE
            AND C2.USERID NOT IN (SELECT 
                OUUA.ON_USERID
            FROM
                OPN_USER_USER_ACTION OUUA
            WHERE
                OUUA.BY_USERID = orig_uid
                    -- AND OUUA.TOPICID = tid
                    AND OUUA.ACTION_TYPE = 'KO')) B
    WHERE
        A.TOPICID = B.TOPICID
			AND A.KEYID = B.KEYID
            AND A.CART <> B.CART
            AND B.USERID NOT IN 
(SELECT DISTINCT D.USERID FROM 
(SELECT C1.USERID, C1.TOPICID, C1.CART, C1.KEYID FROM OPN_USER_CARTS C1 WHERE C1.USERID = orig_uid -- AND C1.TOPICID = tid
) C ,
(SELECT C2.USERID, C2.TOPICID, C2.CART, C2.KEYID FROM OPN_USER_CARTS C2 ) D
WHERE C.KEYID = D.KEYID AND C.CART = D.CART )
            -- AND A.TOPICID = tid
    GROUP BY B.USERID , B.BOT_FLAG , A.TOPICID
    -- ORDER BY COUNT(*) DESC
    ) UN
    WHERE
        UN.USERID = P.POST_BY_USERID
            -- AND UN.TOPICID = P.TOPICID
            AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 300 DAY
            AND P.CLEAN_POST_FLAG = 'Y') INSTREAM
        INNER JOIN
    (SELECT 
        USERID, USERNAME, DP_URL
    FROM
        OPN_USERLIST
    WHERE
        BOT_FLAG = 'Y') OU ON INSTREAM.POST_BY_USERID = OU.USERID
        LEFT OUTER JOIN
    (SELECT 
        CAUSE_POST_ID,
            SUM(CASE
                WHEN POST_ACTION_TYPE = 'L' THEN 1
                ELSE 0
            END) LCOUNT,
            SUM(CASE
                WHEN POST_ACTION_TYPE = 'H' THEN 1
                ELSE 0
            END) HCOUNT
    FROM
        OPN_USER_POST_ACTION
    GROUP BY CAUSE_POST_ID) POST_LHC ON INSTREAM.POST_ID = POST_LHC.CAUSE_POST_ID
        LEFT OUTER JOIN
    OPN_USER_POST_ACTION UP ON INSTREAM.POST_ID = UP.CAUSE_POST_ID
        AND UP.ACTION_BY_USERID = orig_uid
        LEFT OUTER JOIN
    (SELECT 
        BK.POST_ID
    FROM
        OPN_POST_BOOKMARKS BK
    WHERE
        BK.USERID = orig_uid
            -- AND BK.TOPICID = tid
            ) BK2 ON INSTREAM.POST_ID = BK2.POST_ID
        LEFT OUTER JOIN
    OPN_USER_USER_ACTION UUA ON INSTREAM.POST_BY_USERID = UUA.ON_USERID
        AND UUA.BY_USERID = orig_uid
        LEFT OUTER JOIN
    (SELECT 
        CAUSE_POST_ID, COUNT(1) POST_COMMENT_COUNT
    FROM
        OPN_POST_COMMENTS
    WHERE
        CLEAN_COMMENT_FLAG = 'Y'
            AND COMMENT_DELETE_FLAG = 'N'
    GROUP BY CAUSE_POST_ID) OPC ON INSTREAM.POST_ID = OPC.CAUSE_POST_ID
ORDER BY POST_ID DESC  
LIMIT fromindex, toindex
;

END CASE ; -- THIS IS THE SUSPFLAG CASE END
  
END$$

DELIMITER ;

-- 
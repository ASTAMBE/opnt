SELECT 
        P.POST_ID,
            P.TOPICID,
            P.POST_DATETIME,
            P.POST_UPDATE_DTM,
            P.POST_BY_USERID,
            P.POST_CONTENT,
            UN.TOTAL_NS,
            P.MEDIA_CONTENT,
            P.MEDIA_FLAG
    FROM
        OPN_POSTS P, (SELECT 
        B.USERID, B.BOT_FLAG, A.TOPICID, COUNT(*) TOTAL_NS
    FROM
        (SELECT 
        C1.USERID, C1.TOPICID, C1.CART, C1.KEYID
    FROM
        OPN_USER_CARTS C1
    WHERE
        C1.USERID = 1020530 AND C1.TOPICID = 1) A, (SELECT 
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
        AND C2.TOPICID = 1 AND CU.BOT_FLAG = 'Y'
            AND C2.USERID NOT IN (SELECT 
                OUUA.ON_USERID
            FROM
                OPN_USER_USER_ACTION OUUA
            WHERE
                OUUA.BY_USERID = 1020530
                    AND OUUA.TOPICID = 1
                    AND OUUA.ACTION_TYPE = 'KO')) B
    WHERE
        B.TOPICID = A.TOPICID
            AND B.CART = A.CART
            AND B.KEYID = A.KEYID
            -- AND A.TOPICID = tid
    GROUP BY B.USERID , B.BOT_FLAG , A.TOPICID
    -- ORDER BY COUNT(*) DESC
    ) UN
    WHERE 1=1
    AND P.CLEAN_POST_FLAG = 'Y'
    AND P.POST_DATETIME > CURRENT_DATE() - INTERVAL 100 DAY
            AND UN.USERID = P.POST_BY_USERID 
			AND P.TOPICID = UN.TOPICID
            -- AND P.CLEAN_POST_FLAG = 'Y'
            ;
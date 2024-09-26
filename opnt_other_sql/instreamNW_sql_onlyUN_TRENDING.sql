SELECT 
        B.USERID, B.BOT_FLAG, A.TOPICID, A.CART_LDTM
    FROM
        (SELECT 
        C1.USERID, C1.TOPICID, C1.CART, C1.KEYID, C1.LAST_UPDATE_DTM CART_LDTM
    FROM
        OPN_USER_CARTS C1
    WHERE
        C1.USERID = 1020530 ) A, (SELECT 
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
        AND CU.BOT_FLAG = 'Y'
            AND C2.USERID NOT IN (SELECT 
                OUUA.ON_USERID
            FROM
                OPN_USER_USER_ACTION OUUA
            WHERE
                OUUA.BY_USERID = 1020530
                    -- AND OUUA.TOPICID = 1
                    AND OUUA.ACTION_TYPE = 'KO')) B
    WHERE
        B.TOPICID = A.TOPICID
            AND B.CART = A.CART
            AND B.KEYID = A.KEYID
            -- AND A.TOPICID = tid
    ORDER BY A.CART_LDTM DESC 
    ;
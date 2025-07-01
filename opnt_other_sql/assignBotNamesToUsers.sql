DELIMITER //

DROP PROCEDURE IF EXISTS assignBotNamesToUsers //

CREATE PROCEDURE assignBotNamesToUsers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_row_id INT;
    DECLARE v_true_country_code VARCHAR(5);
    DECLARE v_camp VARCHAR(50);
    DECLARE v_name VARCHAR(100);
    DECLARE v_userid INT;
    DECLARE v_username VARCHAR(100);

    DECLARE bot_cursor CURSOR FOR
        SELECT ROW_ID, TRUE_COUNTRY_CODE, CAMP, NAME
        FROM OPN_BOT_NAMES
        WHERE USERID IS NULL ;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN bot_cursor;

    bot_loop: LOOP
        FETCH bot_cursor INTO v_row_id, v_true_country_code, v_camp, v_name;

        IF done THEN
            LEAVE bot_loop;
        END IF;

        -- Pick a random eligible bot user
        SELECT USERID INTO v_userid
        FROM OPN_USERLIST
        WHERE BOT_FLAG = 'Y'
          AND COUNTRY_CODE = 'GGG'
          AND TRUE_COUNTRY_CODE IS NULL
        ORDER BY RAND()
        LIMIT 1;

        -- Set username from name
        SET v_username = v_name;

        -- Update the userlist with bot identity
        UPDATE OPN_USERLIST
        SET
            USERNAME = v_username,
            TRUE_COUNTRY_CODE = v_true_country_code,
            OPINION_CAMP = v_camp
        WHERE USERID = v_userid;

        -- Update the bot names table with the assigned USERID
        UPDATE OPN_BOT_NAMES
        SET USERID = v_userid
        WHERE ROW_ID = v_row_id;

    END LOOP;

    CLOSE bot_cursor;
END //

DELIMITER ;

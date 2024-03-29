-- loginWithAppleUserApp

-- USE `opntprod`;
DROP procedure IF EXISTS `loginWithAppleUserApp`;

DELIMITER $$
-- USE `opntprod`$$
CREATE DEFINER=`root`@`%` PROCEDURE `loginWithAppleUserApp`
(Apple_userid VARCHAR(100), device_serial VARCHAR(45))
BEGIN
/*  
 08/11/2020 Kapil: Confirmed
 */

INSERT INTO OPN_PROC_LOG(PROC_NAME, PROC_DTM, CONCAT_FIELDS, CONCAT_VALUES)
VALUES('loginWithAppleUserApp', NOW(), 'A_USERID', Apple_userid) ;

SELECT OU.USER_UUID USERID, OU.USERNAME, OU.COUNTRY_CODE 
FROM OPN_USERLIST OU WHERE OU.A_USERID = Apple_userid 
/* 04/06/2021 INSERTING THE SUSPENDED USER EXCLUSION BELOW */
AND  OU.USER_SUSPEND_FLAG = 'N'
/* 04/06/2021 END OF THE SUSPENDED USER EXCLUSION */
LIMIT 5;

END$$

DELIMITER ;

-- 



-- getPhoneCcode

DELIMITER //
DROP PROCEDURE IF EXISTS getPhoneCcode //
CREATE PROCEDURE getPhoneCcode(tcc varchar(5))
BEGIN

/*

12/07/2023 AST: This proc is being built to supply the Phone Country Code for phone-based registration
It accepts the 3 char TRUE_COUNTRY_CODE and sends the Phone Country Code for that CCODE

*/

SELECT IFNULL(PHONE_CCODE, 'Wrong Country Code - ') PHCODE  FROM PHONE_CODES  WHERE C_CODE = tcc ;
-- SELECT PHONE_CCODE  FROM PHONE_CODES  WHERE C_CODE = tcc ;


END //
DELIMITER ;

-- 
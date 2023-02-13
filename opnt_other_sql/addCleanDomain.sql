-- addCleanDomain

 DELIMITER //
DROP PROCEDURE IF EXISTS addCleanDomain //
CREATE PROCEDURE addCleanDomain(sitename varchar(100), udomain VARCHAR(100), udold varchar(100) )
BEGIN

/* 04/22/2020 AST: Adding an example of the call
 addCleanDomain('M.ECONOMICTIMES.COM', 'M.ECONOMICTIMES.COM', 'ECONOMICTIMES.COM')
 01/15/2021 AST: Added U_DOMAIN_OLD
 
 */

INSERT INTO OPN_CLEAN_DOMAINS(SITE_NAME, U_DOMAIN, U_DOMAIN_OLD) VALUES(sitename, udomain, udold) ;


END //
DELIMITER ;

-- 
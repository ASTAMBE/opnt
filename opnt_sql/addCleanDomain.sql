-- addCleanDomain

 DELIMITER //
DROP PROCEDURE IF EXISTS addCleanDomain //
CREATE PROCEDURE addCleanDomain(sitename varchar(100), udomain VARCHAR(100))
BEGIN

/* 04/22/2020 AST: Adding an example of the call
 addCleanDomain('DIAWI', 'DIAWI.COM')*/

INSERT INTO OPN_CLEAN_DOMAINS(SITE_NAME, U_DOMAIN) VALUES(sitename, udomain) ;


END //
DELIMITER ;

-- 
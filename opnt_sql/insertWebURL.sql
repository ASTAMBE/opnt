-- insertWebURL

DELIMITER //
DROP PROCEDURE IF EXISTS insertWebURL //
CREATE PROCEDURE insertWebURL(weburl varchar(300), urlTitle varchar(1000), urlDescription varchar(1000), urlImage varchar(1000) )
THISPROC: BEGIN
/*
 08/11/2020 Kapil: Confirmed
 */

CASE WHEN urlImage IS NOT NULL THEN

INSERT INTO OPN_WEB_LINKS
(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM) 
VALUES(weburl, urlTitle, urlDescription, urlImage, NOW())   ;

WHEN urlImage IS  NULL THEN
INSERT INTO OPN_WEB_LINKS
(WEB_URL, URL_TITLE, URL_DESCRIPTION, IMAGE_URL, CREATION_DTM) 
VALUES(weburl, urlTitle, urlDescription, 'https://www.opinito.com/images/orange/OPINITOLogo2.png', NOW())   ;

END CASE ;
  
END //
DELIMITER ;

-- 
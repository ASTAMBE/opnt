-- bringKWByKID

DELIMITER //
DROP FUNCTION IF EXISTS bringKWByKID //
CREATE FUNCTION bringKWByKID(KID INT) RETURNS varchar(60)
BEGIN

/*

05/26/2020 AST: This Function is used in the  OPN_USER_BHV_LOG of addSearchKwToCart

Hence it is a part of regular functions

*/

  DECLARE kw varchar(60) ;

SET kw = (SELECT MAX(KEYWORDS) FROM OPN_P_KW WHERE KEYID = KID);

  RETURN kw;
END;//

-- 
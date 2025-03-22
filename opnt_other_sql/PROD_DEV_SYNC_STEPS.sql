SELECT CCODE, TOPICID, TCCODE, COUNT(1) FROM OPN_MAIN_BOTS group by CCODE, TOPICID, TCCODE ORDER BY CCODE, TOPICID, TCCODE  ;
SELECT * FROM OPN_MAIN_BOTS WHERE TCCODE = 'IND' AND OPINION_CAMP IS NOT NULL ;
SELECT * FROM OPN_USERLIST WHERE TRUE_COUNTRY_CODE = 'NGA' AND BOT_FLAG = 'Y' ;
SELECT USERID, USERNAME, TOPICID, OPINION_CAMP FROM OPN_MAIN_BOTS WHERE TCCODE = 'IND' AND OPINION_CAMP IS NOT NULL  ORDER BY USERID ;
SELECT USERNAME, TOPICID, COUNT(1) FROM OPN_MAIN_BOTS WHERE TCCODE = 'IND' AND OPINION_CAMP IS NOT NULL GROUP BY USERNAME, TOPICID HAVING COUNT(1) > 1 ;
SELECT USERID, USERNAME, TOPICID, OPINION_CAMP FROM OPN_MAIN_BOTS WHERE USERNAME = 'ninjaSimran' ;

UPDATE OPN_MAIN_BOTS SET USERNAME = 'SoniyaandSimran' where USERID = 1019714 ;
-- Randomly select 10 ANTIMODI rows and update them to PROMODI
UPDATE OPN_MAIN_BOTS
SET OPINION_CAMP = 'ANTIMODI'
WHERE USERID IN (
    SELECT USERID FROM (
        SELECT USERID
        FROM OPN_MAIN_BOTS
        WHERE OPINION_CAMP = 'PROMODI'
        ORDER BY RAND()
        LIMIT 2
    ) AS TEMP
);

-- Update PROMODI usernames
-- Update PROMODI usernames
UPDATE OPN_MAIN_BOTS
SET USERNAME = CASE
    WHEN OPINION_CAMP = 'PROMODI' THEN ELT(FLOOR(1 + RAND() * 60),
        'sureshReddy', 'lakshmiNair', 'rajeshIyer', 'anjaliMenon', 'naiduKumar', 'divyaShetty', 'arunRao', 'krishnaPillai', 
        'maliniChetty', 'sreeRam', 'ajayGupta', 'priyaSharma', 'rahulVerma', 'anitaJain', 'vikramPatel', 'meeraDesai', 
        'amitMishra', 'reenaSaxena', 'sanjayAgarwal', 'nehaTiwari', 'jaspreetSingh', 'gurdeepKaur', 'manpreetBrar', 
        'harmanjeetSandhu', 'navjotDhillon', 'sureshPhoenix', 'lakshmiShadow', 'rajeshBlaze', 'anjaliAce', 'naiduNinja', 
        'lhouVang', 'tsheringDorji', 'neilLepcha', 'sangmaBoro', 'adiThong', 'marakMomin', 'birenSingh', 'nagaAo', 
        'konyakPhom', 'jamirZeliang', 'shadowRajiv', 'blazeAnkit', 'ninjaSimran', 'frostZoya', 'aceKumar', 'sureshReddy7', 
        'lakshmiNair12', 'rajeshIyer8', 'anjaliMenon4', 'naiduKumar9', 'divyaShetty6', 'arunRao11', 'krishnaPillai3', 
        'maliniChetty5', 'sreeRam7', 'lhouVang10', 'tsheringDorji8', 'neilLepcha4', 'sangmaBoro3', 'adiThong9'
    )
END
WHERE OPINION_CAMP = 'PROMODI';
-- Update ANTIMODI usernames
-- Update ANTIMODI usernames
UPDATE OPN_MAIN_BOTS
SET USERNAME = CASE
    WHEN OPINION_CAMP = 'ANTIMODI' THEN ELT(FLOOR(1 + RAND() * 40),
        'anjaliSharma', 'priyaVerma', 'rahulAgarwal', 'nehaPatel', 'sanjayMishra', 'amitKumar', 'divyaGupta', 'arunSingh', 
        'krishnaReddy', 'maliniIyer', 'sreeMenon', 'rajeshNair', 'zoyaBegum', 'aliRizvi', 'simranSheikh', 'farhanAkhtar', 
        'ayeshaAnsari', 'imranMalik', 'naseemKhan', 'michaelRodrigues', 'elizabethD’Souza', 'josephFernandes', 
        'rachelMascarenhas', 'anthonyPinto', 'frostZoya', 'shadowAyesha', 'blazeFarhan', 'aceKrishna', 'ninjaSimran', 
        'anjaliSharma4', 'priyaVerma7', 'rahulAgarwal11', 'nehaPatel3', 'sanjayMishra9', 'amitKumar6', 'divyaGupta8', 
        'arunSingh12', 'krishnaReddy5', 'maliniIyer10', 'sreeMenon2'
    )
END
WHERE OPINION_CAMP = 'ANTIMODI';
select count(1) from OPN_MAIN_BOTS WHERE TCCODE = 'IND' AND OPINION_CAMP= 'ANTIMODI' ;

        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-AamAdmiParty.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-Devendra_Fadnavis.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-IndNatCong.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-NaveenPatnaik.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-Nitish_Kumar.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-RSS.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-SharadPawar.jpg",
        "https://s3.us-west-1.amazonaws.com/opinito/1630847796-Tejashwi_Yadav.jpg" ;
        
SELECT KEYID, KEYWORDS, CLEAN_KW_FLAG, KW_IMAGE_URL FROM OPN_P_KW WHERE KW_IMAGE_URL IS NOT NULL AND TOPICID = 1 ;

UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-AamAdmiParty.jpg' WHERE KEYID = 6009 and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-IndNatCong.jpg' WHERE KEYID = 6008 and`TOPICID`='1';

UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-Devendra_Fadnavis.jpg' WHERE KEYID = 5010 and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-NaveenPatnaik.jpg' WHERE KEYID = 105254 and`TOPICID`='1';

UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-RSS.jpg' WHERE KEYID = 5005 and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `KW_IMAGE_URL`='https://s3.us-west-1.amazonaws.com/opinito/1630847796-SharadPawar.jpg' WHERE KEYID = 6011 and`TOPICID`='1';

UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Aam Admi Party (AAP)' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Arvind Kejriwal' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Congress Party' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='22' WHERE `KEYWORDS`='Devendra Fadnavis' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Mamata Banerjee' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Narendra Modi' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='27' WHERE `KEYWORDS`='Naveen patnaik' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='Rahul Gandhi' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='1' WHERE `KEYWORDS`='RSS' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='22' WHERE `KEYWORDS`='Sharad Pawar' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='22' WHERE `KEYWORDS`='Uddhav Thakrey' and`TOPICID`='1';
UPDATE `opntprod`.`OPN_P_KW` SET `STATE_CODE`='36' WHERE `KEYWORDS`='Yogi Adityanath' and`TOPICID`='1';

SELECT * FROM OPN_STATE_CODES ;





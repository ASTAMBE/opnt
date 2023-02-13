CREATE TABLE `opntprod`.`OPN_BOLO_CART` (
  `ROW_ID` INT NOT NULL AUTO_INCREMENT,
  `CART_ID` INT NULL,
  `USERID` INT NULL,
  `USER_UUID` VARCHAR(45) NULL,
  `TOPICID` SMALLINT(2) NULL,
  `KEYID` INT NULL,
  `CART` VARCHAR(5) NULL,
  `CREATION_DTM` DATETIME NULL,
  `LAST_UPDATE_DTM` DATETIME NULL,
  PRIMARY KEY (`ROW_ID`));
  
  ALTER TABLE `opntprod`.`OPN_P_KW` 
ADD COLUMN `APPROVED_FLAG` VARCHAR(5) NULL AFTER `CLEAN_KW_FLAG`,
ADD COLUMN `KW_IMAGE_URL` VARCHAR(1000) NULL AFTER `APPROVED_FLAG`;

ALTER TABLE `opntprod`.`OPN_P_KW` 
CHANGE COLUMN `IRANK` `IRANK` DECIMAL(10,6) NULL DEFAULT NULL ;

ALTER TABLE `opntprod`.`OPN_P_KW` 
ADD COLUMN `STATE_CODE` VARCHAR(5) NULL AFTER `KW_IMAGE_URL`,
ADD COLUMN `STATE_NAME` VARCHAR(45) NULL AFTER `STATE_CODE`,
ADD COLUMN `NATIONAL_FLAG` VARCHAR(5) NULL AFTER `STATE_NAME`,
ADD COLUMN `REGIONAL_FLAG` VARCHAR(5) NULL AFTER `NATIONAL_FLAG`,
ADD COLUMN `STATE_FLAG` VARCHAR(5) NULL AFTER `REGIONAL_FLAG`;

ALTER TABLE `opntprod`.`OPN_STATE_CODES` 
ADD COLUMN `COUNTRY_CODE` VARCHAR(4) NULL AFTER `ROW_ID`;

ALTER TABLE `opntprod`.`OPN_P_KW` 
ADD COLUMN `NEWS_ONLY_FLAG` VARCHAR(5) NULL AFTER `STATE_FLAG`;

ALTER TABLE `opntprod`.`OPN_KW_TAGS` 
ADD COLUMN `NEWS_ONLY_FLAG` VARCHAR(5) NULL AFTER `KW_DTM`;

DROP TABLE OPN_KILLED_KW ;

CREATE TABLE OPN_KILLED_KW AS SELECT * FROM OPN_P_KW WHERE 1 =2 ;

CREATE TABLE `opntprod`.`OPN_APP_PARAMS` (
  `APP_NAME` VARCHAR(20) NOT NULL,
  `COUNTRY_CODE` VARCHAR(5) NULL,
  `SINGLE_TOPIC` VARCHAR(5) NULL,
  `LANG_CODE` VARCHAR(5) NULL,
  PRIMARY KEY (`APP_NAME`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

CREATE TABLE `WEB_SCRAPE_DEDUPE` (
  `SCRAPE_SOURCE` varchar(100) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `SCRAPE_TOPIC` varchar(50) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `NEWS_URL` varchar(1000) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `NEWS_PIC_URL` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NEWS_HEADLINE` varchar(500) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `NEWS_EXCERPT` varchar(2000) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `MOVED_TO_POST_FLAG` varchar(2) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT 'N',
  `COUNTRY_CODE` varchar(5) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `SCRAPE_TAG1` varchar(300) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `SCRAPE_TAG2` varchar(300) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `SCRAPE_TAG3` varchar(300) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT * FROM WEB_SCRAPE_DEDUPE ;

/*
-- Query: SELECT * FROM opntprod.WEB_SCRAPE_DEDUPE LIMIT 10
-- Date: 2021-09-25 20:50
*/
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/2nd-nationwide-vaccine-dry-run-in-33-states-uts-today/story-iO39rySm5PDL0v6N7Kk2HP.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/hindustan-lucknow-january-pradesh-dheeraj-tuesday-vaccination_35c3d998-5133-11eb-be6b-425a95343f6a.jpg','2nd nationwide vaccine dry run in 33 states, UTs today','India’s drug regulator on January 3 approved the Oxford-AstraZeneca vaccine and the indigenously developed Bharat Biotech vaccine for restricted emergency use in the country.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/swaminathan-says-msp-better-than-loan-waiver/story-2qopTgacvZ8VQmXRHS8gLJ.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/msp-for-paddy-hiked-by-rs-200_a554da42-5132-11eb-be6b-425a95343f6a.jpg','Swaminathan says MSP better than loan waiver','The protesting farmers, apart from a repeal of the laws, have also demanded a law guaranteeing MSPs calculated using the C2 yardstick. The farmers will hold the next round of negotiations with the Centre on Friday.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/3-000-tractors-at-farmers-march/story-03L9M5ypiWHobN5HknEckM.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/_b7d47bbe-5128-11eb-be6b-425a95343f6a.jpg','3,000 tractors at farmers’ march','In Nuh district of Haryana, some farmers alleged that they were prevented from joining the rally. The protesters, along with local residents.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/govt-begin-surveillance-of-human-population/story-AhpRfzjiMRpXkpwCcLvXsO.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/bird-flu-outbreak-jammu-on-alert_5b0ba98c-5120-11eb-be6b-425a95343f6a.jpg','Govt: Begin surveillance of human population','Thousands of birds have died in Kerala (mostly poultry), Himachal Pradesh (mostly migratory birds), and Rajasthan and Madhya Pradesh (mostly crows) since December-end.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/jammu-srinagar-national-highway-remains-shut-for-5thday-due-to-slippery-stretches-landslides/story-whNZPTT36KWcgIGgKT9BhM.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/weather-snowfall-in-kashmir_dd0b0526-5117-11eb-be6b-425a95343f6a.jpg','Jammu-Srinagar national highway remains shut for 5thday due to slippery stretches, landslides','At Samroli, the authorities had to blast big boulders, which had blocked the highway since Wednesday.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/nia-arrests-key-suspect-from-tn-in-ssi-wilson-murder-case/story-UBmypwmIyG0GR4IxE8RS7L.html','https://www.hindustantimes.com/res/img/ht2020/444x250_1.png','NIA arrests key suspect from tn in SSI wilson murder case','NIA arrests key suspect from tn in SSI wilson murder case','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/nadda-to-launch-new-campaign-on-farm-laws-during-bengal-visit/story-B5WbqG5iv9zTx8MDBeHXCJ.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/08/Pictures/jp-nadda-aaddresses-press-conference_f707c062-5118-11eb-be6b-425a95343f6a.jpg','Nadda to launch new campaign on farm laws during Bengal visit','JP Nadda will also lead the party’s door-to-door canvassing ahead of the West Bengal assembly elections scheduled to take place before May this year.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/jammu-and-kashmir-cadre-of-all-india-services-merged-with-agmut/story-ug1jcyxIMcBmtCr7j6IxxL.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/07/Pictures/india-kashmir-fighting_8e0965d8-5114-11eb-be6b-425a95343f6a.jpg','Jammu and Kashmir cadre of All India Services merged with AGMUT','This J&K cadre of All India services had stopped inducting new officers after the government had recategorised the erstwhile state into two UTs – J&K and Ladakh after scrapping Article 370, which gave the state somewhat special status, on August 5, 2019.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/nia-arrests-key-suspect-from-tn-in-ssi-wilson-murder-case/story-6g63s4oXDE2ycGwi6OCEIN.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/07/Pictures/nia-building_152a1d2a-5113-11eb-be6b-425a95343f6a.jpg','NIA arrests key suspect from TN in SSI Wilson murder case','The January 8, 2020 murder in Kanyakumari was part of a conspiracy by some Islamic State operatives led by Khaja Mohideen to revive the activities of the global terror outfit in the region, officials said.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');
INSERT INTO `WEB_SCRAPE_DEDUPE` (`SCRAPE_SOURCE`,`SCRAPE_TOPIC`,`NEWS_URL`,`NEWS_PIC_URL`,`NEWS_HEADLINE`,`NEWS_EXCERPT`,`MOVED_TO_POST_FLAG`,`COUNTRY_CODE`,`SCRAPE_TAG1`,`SCRAPE_TAG2`,`SCRAPE_TAG3`) VALUES ('HT/POLITICS','POLITICS','https://www.hindustantimes.com/india-news/train-on-high-speed-trial-run-crushes-four-people-near-haridwar/story-RRsgVQdm9QSS7PpeuPCGoL.html','https://www.hindustantimes.com/rf/image_size_300x169/HT/p2/2021/01/05/Pictures/crime-scene_8bc1a9ac-4f75-11eb-98bd-18b55e3bb9aa.jpg','Train on high-speed trial run crushes four people near Haridwar','The train was on a trial run at 100 kmph to test the newly laid Haridwar-Laksar double line track.','N','IND','INDPOLLW','INDPOLLW','INDPOLLW');


CREATE TABLE `WSR_DEDUPE_NDTM` (
  `ROW_ID` int(11) NOT NULL AUTO_INCREMENT,
  `SCRAPE_SOURCE` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `SCRAPE_TOPIC` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `COUNTRY_CODE` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NEWS_URL` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NDTM` datetime DEFAULT NULL,
  PRIMARY KEY (`ROW_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=476805 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Amit Shah' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Arnab Goswami' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Barkha Dutt' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='bolo' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='DOMESTIC ISSUES' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='gigl' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Hardik Patel' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='jks' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Lalu Yadav' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='MNS' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='new keyword' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='P Chidambaram' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Politics News' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Rajdeep Sardesai' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Shivsena' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Smriti Irani' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Sonia Gandhi' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='srk' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='Testing! ' and`TOPICID`='1';
DELETE FROM `opntprod`.`OPN_P_KW` WHERE `KEYWORDS`='yogi' and`TOPICID`='1';


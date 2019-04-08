CREATE DATABASE SocialResumeDatabase;

USE SocialResumeDatabase;

CREATE TABLE `SocialResumeDatabase`.`users` (
  `user_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(256) NOT NULL,
  `lname` VARCHAR(256) NOT NULL,
  `Born_date` date  NOT NULL,
  `sex` VARCHAR(256) NOT NULL,
  `password` VARCHAR(256) NOT NULL,
  `language` VARCHAR(256) NOT NULL,
  `email` VARCHAR(256) NOT NULL,
   CONSTRAINT `unique_users` UNIQUE (`email`),
   PRIMARY KEY (`user_id`),
   CONSTRAINT `languageFK` FOREIGN KEY (`language`)
   REFERENCES diller(`dil`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE `SocialResumeDatabase`.`diller` (
  `dil` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`dil`)
);

CREATE TABLE `SocialResumeDatabase`.`profil` 
(
	`profile_id` INT(10) UNSIGNED NOT NULL,
    `user_id` INT(10) UNSIGNED NOT NULL,
    `baslik` VARCHAR(256),
	`yasadigi_yer` VARCHAR(256) NOT NULL,
	`memleket` VARCHAR(256) NOT NULL,
	`sektor` VARCHAR(256) NOT NULL,
	`ozet` VARCHAR(256),
	CONSTRAINT `unique_users` UNIQUE (`user_id`),
    PRIMARY KEY (`profile_id`),
    CONSTRAINT `profile_idFK` FOREIGN KEY (`user_id`)
    REFERENCES users(`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `yasadigi_yerFK` FOREIGN KEY (`yasadigi_yer`)
    REFERENCES Sehir_Ulke(`sehir_ulke`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
	CONSTRAINT `memleketFK` FOREIGN KEY (`memleket`)
    REFERENCES Sehir_Ulke(`sehir_ulke`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `sektor_FK` FOREIGN KEY (`sektor`)
    REFERENCES sektorler(`sektor_adi`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);  

CREATE TABLE `SocialResumeDatabase`.`Sehir_Ulke` (
  `sehir_ulke` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`sehir_ulke`)
);

CREATE TABLE `SocialResumeDatabase`.`egitimler` (

  `profile_id` INT UNSIGNED NOT NULL,
  `okul` VARCHAR(256) NOT NULL,
  `bolum` VARCHAR(256) NOT NULL,
  `basladıgı_tarih` date  NOT NULL,
  `bitirdigi_tarih` date  NOT NULL,
  `acıklama` VARCHAR(256) ,
   CONSTRAINT `profileFK` FOREIGN KEY (`profile_id`)
   REFERENCES profil(`profile_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE `SocialResumeDatabase`.`yetenekler` (
  `profile_id` INT UNSIGNED NOT NULL,
  `yetenek` VARCHAR(256) NOT NULL,
   CONSTRAINT `unique_yetenekler` UNIQUE (`profile_id`,`yetenek`),
   CONSTRAINT `profile_yetenekFK` FOREIGN KEY (`profile_id`)
   REFERENCES profil(`profile_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE `SocialResumeDatabase`.`is_deneyimleri`
(
  `profile_id` INT UNSIGNED NOT NULL,
  `unvan` VARCHAR(256) NOT NULL,
  `sirket_adi` VARCHAR(256) NOT NULL,
  `sektor` VARCHAR(256) NOT NULL,
  `baslangic_tarihi` date NOT NULL,
  `bitis_tarihi` date NOT NULL,
  `konum` VARCHAR(256) NOT NULL,
  `aciklama` VARCHAR(256),
   CONSTRAINT `profile_is_deneyimleriFK` FOREIGN KEY (`profile_id`)
   REFERENCES profil(`profile_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `konum_deneyimFK` FOREIGN KEY (`konum`)
   REFERENCES Sehir_Ulke(`sehir_ulke`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `sektor_is_deneyimFK` FOREIGN KEY (`sektor`)
   REFERENCES sektorler(`sektor_adi`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);


CREATE TABLE `SocialResumeDatabase`.`yetkin_diller`
(
  `profile_id` INT UNSIGNED NOT NULL,
  `dil` VARCHAR(256) NOT NULL,
  `duzey` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
   CONSTRAINT `unique_yetkin_diller` UNIQUE (`profile_id`,`dil`),
   CONSTRAINT `dilFK` FOREIGN KEY (`dil`)
   REFERENCES diller(`dil`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `profile_dilFK` FOREIGN KEY (`profile_id`)
   REFERENCES profil(`profile_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);


CREATE TABLE `SocialResumeDatabase`.`is_ilanlari`
( 
   `is_ilani_id` INT UNSIGNED NOT NULL,
   `user_id` INT UNSIGNED NOT NULL,
   `sirket_adi` VARCHAR(256) NOT NULL,
   `is_basligi` VARCHAR(256) NOT NULL,
   `konum` VARCHAR(256) NOT NULL,
   `sektor` VARCHAR(256) NOT NULL,
   `calisan_turu` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
   `aciklama` VARCHAR(256),
    PRIMARY KEY (`is_ilani_id`),
    CONSTRAINT `is_ilanlari_user_idFK` FOREIGN KEY (`user_id`)
    REFERENCES users(`user_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `konumFK` FOREIGN KEY (`konum`)
    REFERENCES Sehir_Ulke(`sehir_ulke`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CONSTRAINT `sektor_is_ilaniFK` FOREIGN KEY (`sektor`)
    REFERENCES sektorler(`sektor_adi`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`is_ilani_basvuranlar` 
( 
  `is_ilani_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
   CONSTRAINT `unique_followed_pages` UNIQUE (`is_ilani_id`,`user_id`),
   CONSTRAINT `is_ilani_idFK` FOREIGN KEY (`is_ilani_id`)
   REFERENCES is_ilanlari(`is_ilani_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `user_id_basvuruFK` FOREIGN KEY (`user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER is_ilani BEFORE INSERT
ON is_ilani_basvuranlar
FOR EACH ROW
BEGIN
     if exists(select user_id 
               from SocialResumeDatabase.is_ilanlari
               where  is_ilanlari.user_id = new.user_id 
               and is_ilanlari.is_ilani_id=new.is_ilani_id) then
        signal sqlstate '45000' set message_text=" iş ilanı yayınlayan kişi kendi ilanına basvuramaz ";
     end if;
   
END//
DELIMITER ;

CREATE TABLE `SocialResumeDatabase`.`ayarlar` (
  `user_id` INT UNSIGNED NOT NULL,
  `arkadas_listesi_gizli_mi` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `paylasimlar_gizli_mi` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `epostanizi_kimler_gorebilir` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `takip_ettigin_sayfalari_kim_gorebilir` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `profil_gorunurlugu` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `kullanicilar_sizi_etiketliyebilirmi` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  CONSTRAINT `unique_ayarlar` UNIQUE (`user_id`),
  CONSTRAINT `ayarlar_user_idFK` FOREIGN KEY (`user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);


CREATE TABLE  `SocialResumeDatabase`.`baglanti_kurulan_kullanicilar` 
( 
  `istek_gonderen_user_id` INT(10) UNSIGNED NOT NULL,
  `istegi_alan_user_id` INT(10) UNSIGNED NOT NULL,
  `arkadaslik_durumu` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  CONSTRAINT `unique_friends` UNIQUE (`istek_gonderen_user_id`,`istegi_alan_user_id`),
  CONSTRAINT `action_user_id_FK` FOREIGN KEY (`istek_gonderen_user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT `other_user_id_FK` FOREIGN KEY (`istegi_alan_user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);


DELIMITER //
CREATE TRIGGER baglantilar BEFORE INSERT
ON baglanti_kurulan_kullanicilar
FOR EACH ROW
BEGIN
   IF (new.istek_gonderen_user_id = new.istegi_alan_user_id) 
   THEN
   signal sqlstate '45000' set message_text="iki kullanıcı aynıdır";
   END IF;
   
   if exists(select istegi_alan_user_id,istek_gonderen_user_id,arkadaslik_durumu from baglanti_kurulan_kullanicilar 
   where new.istek_gonderen_user_id=istegi_alan_user_id and new.istegi_alan_user_id=istek_gonderen_user_id)
   then
   signal sqlstate '45000' set message_text="bu kayıt daha onceden eklenmis";
   END IF;
   
END//
DELIMITER ;

DROP TRIGGER baglantilar;


CREATE TABLE  `SocialResumeDatabase`.`message` 
( 
  `alici_user_id` INT(10) UNSIGNED NOT NULL,
  `gonderici_user_id` INT(10) UNSIGNED NOT NULL,
  `spam_status` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `archived_status` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `unread_status` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  `icerik` VARCHAR(256) NOT NULL,
  `mesaj_turu` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `arkadas_mesaji` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
  CONSTRAINT `alici_user_idFK` FOREIGN KEY (`alici_user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT `gonderici_user_idFK` FOREIGN KEY (`gonderici_user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER messages BEFORE INSERT
ON message
FOR EACH ROW
BEGIN

   IF (new.mesaj_turu=0)  THEN 
       if exists(select istegi_alan_user_id,istek_gonderen_user_id  
                 from SocialResumeDatabase.baglanti_kurulan_kullanicilar 
                 where ((baglanti_kurulan_kullanicilar.istek_gonderen_user_id = new.alici_user_id or
                      baglanti_kurulan_kullanicilar.istegi_alan_user_id = new.alici_user_id) and 
                      (baglanti_kurulan_kullanicilar.istek_gonderen_user_id = new.gonderici_user_id or
                      baglanti_kurulan_kullanicilar.istegi_alan_user_id = new.gonderici_user_id)  and 
                      baglanti_kurulan_kullanicilar.arkadaslik_durumu=3)) then
             signal sqlstate '45000' set message_text=" engelli kullanıcı,mesaj gönderemezsiniz";
       end if;
   END IF;
   
   IF (new.mesaj_turu=1)  THEN 
     if not exists(select kurucu_user_id from SocialResumeDatabase.sayfalar
                   where kurucu_user_id = new.alici_user_id) then
        signal sqlstate '45000' set message_text=" mesajı alan kayıtlı sayfa admini yok";
     end if;
   END IF;
   
   IF (new.mesaj_turu=2)  THEN 
     if not exists(select kurucu_user_id from SocialResumeDatabase.social_groups 
                   where kurucu_user_id = new.alici_user_id) then
        signal sqlstate '45000' set message_text=" mesajı alan kayıtlı grup admini yok";
     end if;
   END IF;
   
   IF (new.arkadas_mesaji=1)  THEN 
     if not exists(select istek_gonderen_user_id,istegi_alan_user_id,arkadaslik_durumu
                   from SocialResumeDatabase.baglanti_kurulan_kullanicilar 
                   where (istek_gonderen_user_id =new.alici_user_id
                   or istek_gonderen_user_id = new.gonderici_user_id)
                   and (istegi_alan_user_id = new.alici_user_id or istegi_alan_user_id = new.gonderici_user_id) 
                   and baglanti_kurulan_kullanicilar.arkadaslik_durumu=1) 
		then
        signal sqlstate '45000' set message_text=" bu kişi arkadaşınız değildir";
     end if;
   END IF;
   
END//
DELIMITER ;

DROP TRIGGER messages;

CREATE TABLE `SocialResumeDatabase`.`sektorler`
(
 `sektor_adi` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`sektor_adi`)
);

CREATE TABLE `SocialResumeDatabase`.`sirket_turu`
(
 `sirket_turu_adi` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`sirket_turu_adi`)
); 

CREATE TABLE  `SocialResumeDatabase`.`sayfalar` 
(  
  `page_id` INT(10) UNSIGNED NOT NULL,
  `kurucu_user_id` INT(10) UNSIGNED NOT NULL,
  `page_name` VARCHAR(256) NOT NULL,
  `hakkında` VARCHAR(256) NOT NULL,
  `sayfa_turu` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  `sektor` VARCHAR(256) NOT NULL,
  `sirket_turu` VARCHAR(256) NOT NULL,
   PRIMARY KEY (`page_id`),
   CONSTRAINT `unique_pages` UNIQUE (kurucu_user_id),
   CONSTRAINT `kurucu_user_idFK` FOREIGN KEY (`kurucu_user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `sektor_sayfalarFK` FOREIGN KEY (`sektor`)
   REFERENCES sektorler(`sektor_adi`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `sirket_turu_sayfalarFK` FOREIGN KEY (`sirket_turu`)
   REFERENCES sirket_turu(`sirket_turu_adi`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`sayfa_takipcileri` 
( 
  `page_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
   CONSTRAINT `unique_followed_pages` UNIQUE (`page_id`,`user_id`),
   CONSTRAINT `page_idFK` FOREIGN KEY (`page_id`)
   REFERENCES sayfalar(`page_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `user_idFK` FOREIGN KEY (`user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER sayfa_takipciler BEFORE INSERT
ON sayfa_takipcileri
FOR EACH ROW
BEGIN
     if exists(select kurucu_user_id 
               from SocialResumeDatabase.sayfalar
               where  kurucu_user_id = new.user_id 
               and sayfalar.page_id=new.page_id) then
        signal sqlstate '45000' set message_text=" sayfanın kurucusunu normal takipçi olarak ekleyemezsiniz";
     end if;
   
END//
DELIMITER ;

DROP TRIGGER sayfa_takipciler;

CREATE TABLE  `SocialResumeDatabase`.`social_groups` 
( 
  `group_id` INT(10) UNSIGNED NOT NULL,
  `kurucu_user_id` INT(10) UNSIGNED NOT NULL,
  `group_name` VARCHAR(256) NOT NULL,
  `hakkında` VARCHAR(256),
   PRIMARY KEY (`group_id`),
   CONSTRAINT `unique_social_groups` UNIQUE (kurucu_user_id),
   CONSTRAINT `kurucu_user_id_grupFK` FOREIGN KEY (`kurucu_user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`grup_uyeleri` 
( 
  `group_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
   CONSTRAINT `unique_followed_group` UNIQUE (`group_id`,`user_id`),
   CONSTRAINT `group_idFK` FOREIGN KEY (`group_id`)
   REFERENCES social_groups(`group_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `user_id_groupFK` FOREIGN KEY (`user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER grubun_uyeleri BEFORE INSERT
ON grup_uyeleri
FOR EACH ROW
BEGIN
     if exists(select kurucu_user_id 
               from SocialResumeDatabase.social_groups 
               where  kurucu_user_id = new.user_id 
               and social_groups.group_id=new.group_id) then
        signal sqlstate '45000' set message_text=" grubun kurucusunu normal üye olarak ekleyemezsiniz";
     end if;
   
END//
DELIMITER ;

DROP TRIGGER grubun_uyeleri;

CREATE TABLE `SocialResumeDatabase`.`etkinlikler` (
  `etkinlik_id` INT UNSIGNED NOT NULL,
  `olusturan_user_id` INT UNSIGNED NOT NULL,
  `etkinlik_adi` VARCHAR(256) NOT NULL,
  `adress` VARCHAR(256) NOT NULL,
  `etkinlik_konumu` VARCHAR(256) NOT NULL,
  `Baslangic_tarihi` date  NOT NULL,
  `Bitis_tarihi` date  NOT NULL,
  `etkinlik_Aciklamasi` VARCHAR(256) ,
  `etkinlik_turu_Sayfa_Grup` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
   PRIMARY KEY (`etkinlik_id`),
   CONSTRAINT `unique_etkinlikler` UNIQUE (`etkinlik_adi`),
   CONSTRAINT `etkinlik_yeriFK` FOREIGN KEY (`etkinlik_konumu`)
   REFERENCES Sehir_Ulke(`sehir_ulke`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `etkinlikler_user_idFK` FOREIGN KEY (`olusturan_user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`etkinlige_gidenler` 
( 
  `etkinlik_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
   CONSTRAINT `unique_etkinlige_gidenler` UNIQUE (`etkinlik_id`,`user_id`),
   CONSTRAINT `etkinlige_gidenlerFK` FOREIGN KEY (`etkinlik_id`)
   REFERENCES etkinlikler(`etkinlik_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE,
   CONSTRAINT `user_id_etkinlige_gidenlerFK` FOREIGN KEY (`user_id`)
   REFERENCES users(`user_id`)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);

DELIMITER //
CREATE TRIGGER etkinlik BEFORE INSERT
ON etkinlikler
FOR EACH ROW
BEGIN
   IF (new.etkinlik_turu_Sayfa_Grup=1)  THEN 
     if not exists(select kurucu_user_id from SocialResumeDatabase.sayfalar 
                   where (kurucu_user_id = new.olusturan_user_id)) then
        signal sqlstate '45000' set message_text=" etkinliği olusturan kayıtlı sayfa admini yok";
     end if;
   END IF;
   
   IF (new.etkinlik_turu_Sayfa_Grup=2)  THEN 
      if not exists(select kurucu_user_id from SocialResumeDatabase.social_groups 
                    where (kurucu_user_id  = new.olusturan_user_id)) then
        signal sqlstate '45000' set message_text=" etkinliği olusturan kayıtlı grup admini yok";
     end if;
   END IF;
   
END//
DELIMITER ;

DROP TRIGGER etkinlik;

CREATE TABLE  `SocialResumeDatabase`.`posts` 
( 
  `post_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
  `icerik` VARCHAR(256) NOT NULL,
  `date` date  NOT NULL,
  `paylasim_turu` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`post_id`),
  CONSTRAINT `user_id_postFK` FOREIGN KEY (`user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);


DELIMITER //
CREATE TRIGGER postlar BEFORE INSERT
ON posts
FOR EACH ROW
BEGIN
   IF (new.paylasim_turu=1)  THEN 
     if not exists(select kurucu_user_id from SocialResumeDatabase.sayfalar where kurucu_user_id = new.user_id)
	 then
        signal sqlstate '45000' set message_text=" paylasım yapabilecek kayıtlı sayfa admini yok";
     end if;
   END IF;
   
   IF (new.paylasim_turu=2)  THEN 
     if not exists(select kurucu_user_id from SocialResumeDatabase.social_groups where kurucu_user_id = new.user_id) 
     then
        signal sqlstate '45000' set message_text="paylasım yapabilecek kayıtlı grup admini yok";
     end if;
   END IF;
   
END//
DELIMITER ;

DROP TRIGGER postlar;

CREATE TABLE  `SocialResumeDatabase`.`post_favs` 
( 
  `post_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
   CONSTRAINT `unique_followed_pages` UNIQUE (`post_id`,`user_id`),
  CONSTRAINT `post_idFK` FOREIGN KEY (`post_id`)
  REFERENCES posts(`post_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT `user_id_post_favFK` FOREIGN KEY (`user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`posts_comments` 
( 
  `comment_id` INT(10) UNSIGNED NOT NULL,
  `post_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
  `icerik` VARCHAR(256) NOT NULL,
  `date` date  NOT NULL,
  PRIMARY KEY (`comment_id`),
  CONSTRAINT `post_id_commentsFK` FOREIGN KEY (`post_id`)
  REFERENCES posts(`post_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT `user_id_commentsFK` FOREIGN KEY (`user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE  `SocialResumeDatabase`.`post_comment_favs` 
( 
  `comment_id` INT(10) UNSIGNED NOT NULL,
  `user_id` INT(10) UNSIGNED NOT NULL,
  CONSTRAINT `unique_followed_pages` UNIQUE (`comment_id`,`user_id`),
  CONSTRAINT `comment_idFK` FOREIGN KEY (`comment_id`)
  REFERENCES posts_comments(`comment_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  CONSTRAINT `user_id_comment_favsFK` FOREIGN KEY (`user_id`)
  REFERENCES users(`user_id`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);


                                   /* SİLME VE GÜNCELLEME */
                                   
                                   

DELETE FROM is_ilanlari WHERE is_ilani_id=2 AND sirket_adi="Apple";

UPDATE ayarlar SET epostanizi_kimler_gorebilir=0 WHERE user_id=15;

DELETE FROM posts_comments WHERE comment_id=7 AND post_id=11;

UPDATE profil SET yasadigi_yer="ankara,turkey" WHERE profile_id=8 AND user_id=8;
	
DELETE FROM yetenekler WHERE profile_id=5 AND yetenek="Senaryo Yazımı";

UPDATE social_groups SET group_name="Apple  workers" WHERE group_id=1 AND kurucu_user_id=2;





                                          /*  KAYITLAR  */

   /* DİLLER KAYIT EKLEME*/

INSERT INTO `diller` (dil)
VALUES ("turkce"),("english"),("russian"),("german"),("spanish");

SELECT * FROM diller;


   /* USERS KAYIT EKLEME*/
    
INSERT INTO `users` (user_id,name,lname,Born_date,sex,password,language,email)
VALUES (15,"mervenur","cetin","1993-03-22","female",sha2('mervenur', 256),"turkce",'mervenur@gmail.com' );

SELECT * FROM users;



   /* SEHİR-ULKE KAYIT EKLEME*/

INSERT INTO `Sehir_Ulke` (sehir_ulke)
VALUES ("usa");

SELECT * FROM sehir_ulke;



   /* SEKTOR KAYIT EKLEME*/
   
INSERT INTO `sektorler` (sektor_adi)
VALUES ("makina");

SELECT * FROM sektorler;



   /*PROFILES KAYIT EKLEME */
   
INSERT INTO `profil` (profile_id,user_id,baslik,yasadigi_yer,memleket,sektor,ozet)
VALUES (15,15,"Şu okulda ogrenci: Ege universitesi","izmir,turkey","sivas,turkey","saglik","tip son sinif ogrencisiyim." );

SELECT * FROM profil;



   /* EĞİTİM KAYIT EKLEME */
   
INSERT INTO `egitimler` (profile_id,okul,bolum,basladıgı_tarih,bitirdigi_tarih,acıklama)
VALUES (15,"Ege universitesi","tip","2012-09-12","2018-06-20","");

SELECT * FROM egitimler;




   /* YETENEK KAYIT EKLEME*/
   
INSERT INTO `yetenekler` (profile_id,yetenek)
VALUES (1,"Mac, Linux ve Unix Sistemleri");

SELECT * FROM yetenekler;



   /* IS DENEYİMLERİ KAYIT EKLME */
   
INSERT INTO `is_deneyimleri` (profile_id,unvan,sirket_adi,sektor,baslangic_tarihi,bitis_tarihi,konum,aciklama)
VALUES (12,"Phd","Gazi universitesi","makina","2016-12-15","2040-06-24","ankara,turkey","");

SELECT * FROM is_deneyimleri;



   /* YETKİN DİLLER KAYIT EKLEME*/
INSERT INTO `yetkin_diller`(profile_id,dil,duzey)
VALUES (15,"turkce",5);

SELECT * FROM yetkin_diller;




   /* İŞ İLANLARI KAYIT EKLEME */
   
INSERT INTO `is_ilanlari` (is_ilani_id,user_id,sirket_adi,is_basligi,konum,sektor,calisan_turu,aciklama)
VALUES
(1,2,"Apple","Pro at Artificial Intellegince","usa","bilgisayar yazilimi",3,"salary is 8000$");

SELECT * FROM is_ilanlari;




   /* İŞ İLANI BAŞVURANLAR KAYIT EKLEME */
   
     /* iş ilanı yayınlayanlar:(1,2)/(2,2)/(3,6)/(4,9)/(5,15) (kendi yayınladıgı iş ilanına basvuramaz)*/
   
INSERT INTO `is_ilani_basvuranlar` (is_ilani_id,user_id)
VALUES (5,15);

SELECT * FROM is_ilani_basvuranlar;



   /* AYARLAR KAYIT EKLEME */
   
INSERT INTO `ayarlar` (user_id,arkadas_listesi_gizli_mi,paylasimlar_gizli_mi,epostanizi_kimler_gorebilir,
takip_ettigin_sayfalari_kim_gorebilir,profil_gorunurlugu,kullanicilar_sizi_etiketliyebilirmi)
VALUES (15,0,0,1,1,1,2);

SELECT * FROM ayarlar;



   /* BAĞLANTI KURULAN KULLANICILAR KAYIT EKLEME*/
    /*aynı iki kullanıcı eklenemez,girilen bir kayıt tekrar girilemez(orn: 2 1 / 1 2)*/
   
   
INSERT INTO `baglanti_kurulan_kullanicilar` (istek_gonderen_user_id,istegi_alan_user_id,arkadaslik_durumu)
VALUES (7,15,1);

SELECT * FROM baglanti_kurulan_kullanicilar;



   /* MESAJLAR KAYIT EKLEME */
   
     /* (1,3),(2,8),(3,13),(4,14) nolu  kullanıcılar sayfaların yoneticisidir */
	 /* (1,1),(2,3),(3,6) nolu  kullanıcılar grupların yoneticisidir */
     /*  9,10 / 13,14 arasındaki kayıtlar girilemez(aralarında engellenmis ilişkisi vardır)*/ 
   
   
INSERT INTO `message` (alici_user_id,gonderici_user_id,spam_status,archived_status,unread_status,icerik,mesaj_turu,arkadas_mesaji)
VALUES (10,14,1,0,0,"!!",0,0);

SELECT * FROM message;



   /* ŞİRKET TURU KAYIT EKLEME */
   
INSERT INTO `sirket_turu`(sirket_turu_adi)
VALUES ("sahis isletmesi");

SELECT * FROM sirket_turu;




  /* SAYFA KAYIT EKLEME */
  
INSERT INTO `sayfalar` (page_id,kurucu_user_id,page_name,hakkında,sayfa_turu,sektor,sirket_turu)
VALUES (2,9,"Ege universitesi","1955'ten beri",0,"bilgisayar yazilimi","devlet dairesi");

SELECT * FROM sayfalar;




  /* SAYFA TAKİPÇİLERİ KAYIT EKLEME*/
  /* (1,1),(2,9) nolu  kullanıcılar sayfaların yoneticisidir */
  
INSERT INTO `sayfa_takipcileri` (page_id,user_id)
VALUES (2,9);

SELECT * FROM sayfa_takipcileri;




  /* SOCIAL GROUPS KAYIT EKLEME */
  
INSERT INTO `social_groups` (group_id,kurucu_user_id,group_name,hakkında)
VALUES (2,10,"Ege uni ders notları","Tum ders notları paylaşımı yapılır");

SELECT * FROM social_groups;



  /* GRUP TAKİPÇİLERİ KAYIT EKLEME */
    /* (1,2),(2,10) nolu  kullanıcılar grupların yoneticisidir */
  
  
INSERT INTO `grup_uyeleri` (group_id,user_id)
VALUES (2,10);

SELECT * FROM grup_uyeleri;



   /*ETKİNLİKLER  KAYIT EKLEME */
   /*( 1,9 nolu  kullanıcılar sayfaların yoneticisidir 
	   2,10 nolu kullanıcılar grupların yöneticisidrir.)*/
   
INSERT INTO `etkinlikler` (etkinlik_id,olusturan_user_id,etkinlik_adi,adress,
etkinlik_konumu,Baslangic_tarihi,Bitis_tarihi,etkinlik_Aciklamasi,etkinlik_turu_Sayfa_Grup) 
VALUES (6,8,"About C#","berlin somewhere","berlin,germany","2019-12-12","2019-12-14","Waiting all of coders!",2);

SELECT * FROM etkinlikler;



  /* ETKİNLİĞE GİDENLER */ 
  
INSERT INTO `etkinlige_gidenler` (etkinlik_id,user_id)
VALUES (6,12);

SELECT * FROM etkinlige_gidenler;




  /* POST KAYIT EKLEME */
  /*( 1,9 nolu  kullanıcılar sayfaların yoneticisidir 
	   2,10 nolu kullanıcılar grupların yöneticisidrir.)*/
  
INSERT INTO `posts` (post_id,user_id,icerik,date,paylasim_turu)
VALUES (15,2,"Part-time iş arıyorum yardımcı olabilecek var mı?","2018-05-01",2);

SELECT * FROM posts;




  /* POST FAVS KAYIT EKLEME*/
  
INSERT INTO `post_favs` (post_id,user_id)
VALUES (15,15);

SELECT * FROM post_favs;




  /* POST COMMENTS KAYIT EKLEME*/
  
INSERT INTO `posts_comments` (comment_id,post_id,user_id,icerik,date)
VALUES (15,15,15,"Teşekkürler..","2018-09-13");

SELECT * FROM posts_comments;




  /* POST COMMENT FAVS KAYIT EKLEME */ 
  
INSERT INTO `post_comment_favs` (comment_id,user_id)
VALUES (15,12);

SELECT * FROM post_comment_favs;





                                                /* SORGULAR */ 
                                
                                
                                
/* adı mervenur soyadı cetin olan kullanıcının arkadas listesini göster */
SELECT  B.user_id,B.name,B.lname
FROM    users A,users B,baglanti_kurulan_kullanicilar 
WHERE   A.name="mervenur" AND  A.lname="cetin" 
        AND (A.user_id=baglanti_kurulan_kullanicilar.istek_gonderen_user_id 
        OR  A.user_id=baglanti_kurulan_kullanicilar.istegi_alan_user_id) 
        AND (B.user_id=baglanti_kurulan_kullanicilar.istek_gonderen_user_id 
        OR B.user_id=baglanti_kurulan_kullanicilar.istegi_alan_user_id)
        AND baglanti_kurulan_kullanicilar.arkadaslik_durumu=1 AND A.user_id != B.user_id;
        
        
        
/*her  postun begeni sayısını görüntüleyiniz*/ 
SELECT posts.post_id,posts.icerik AS postun_içeriği, COUNT(post_favs.post_id) AS begeni_sayisi,
users.name AS paylasım_yapan_isim,users.lname AS paylasım_yapan_soyisim
FROM   posts,post_favs,users
WHERE  post_favs.post_id=posts.post_id  and users.user_id=posts.user_id
GROUP BY posts.post_id;


/* her sayfanın takipci sayısını görüntüleyiniz*/
SELECT sayfalar.page_id,sayfalar.page_name, COUNT(sayfa_takipcileri.page_id) AS takipci_sayisi
FROM   sayfalar,sayfa_takipcileri
WHERE  sayfalar.page_id=sayfa_takipcileri.page_id
GROUP BY sayfalar.page_id;


									
/* berlin'de yaşayan kullanıcıların listesi */
SELECT users.name,users.lname,profil.yasadigi_yer
FROM   users,profil
WHERE  profil.yasadigi_yer="berlin,germany" and profil.user_id = users.user_id;



/* ismi merve olan herkesin yetenekleri */
SELECT users.name,users.lname,yetenekler.yetenek
FROM   users,profil,yetenekler
WHERE  users.name="merve" and users.user_id = profil.user_id and profil.profile_id = yetenekler.profile_id;



/* memleketi usa olanların kullanıcı bilgileri, hangi sektorde olduklarını ve unvanlarını listeleyen sorgu */
SELECT users.name,users.lname,profil.sektor,is_deneyimleri.unvan
FROM   profil,users,is_deneyimleri
WHERE  profil.memleket="usa" and profil.profile_id = is_deneyimleri.profile_id and profil.user_id = users.user_id;



/* sinema sektorunde çalışmış kişilerin kullanıcı bilgileri ile birlikte çalıştıkları şirket adları
    ve bu şirkete ait bilgiler sorgusu */
SELECT users.name,users.lname,is_deneyimleri.sirket_adi,is_deneyimleri.unvan,is_deneyimleri.konum,is_deneyimleri.aciklama
FROM   users,is_deneyimleri,profil
WHERE  is_deneyimleri.sektor="sinema" and is_deneyimleri.profile_id = profil.profile_id and profil.user_id = users.user_id;



/* 2 nolu kullanıcının oluşturduğu etkinliğe gidenlerin kullanıcı bilgilerini, memleket ve sektoru listeleyiniz. */
SELECT users.name,users.lname,profil.memleket,profil.sektor
FROM   users,profil,etkinlikler,etkinlige_gidenler
WHERE  etkinlikler.olusturan_user_id=2 and etkinlikler.etkinlik_id = etkinlige_gidenler.etkinlik_id and
etkinlige_gidenler.user_id = users.user_id and users.user_id = profil.user_id;



/* memleketi istanbul olan kullanıcıların takip ettigi sayfalar bilgisi ve kullanıcı bilgilerini gösteren query */
SELECT users.name,users.lname,sayfalar.page_id,sayfalar.page_name,sayfalar.hakkında
FROM   sayfalar,users,profil
WHERE  page_id IN
			(SELECT sayfa_takipcileri.page_id
             FROM   sayfa_takipcileri
             WHERE  users.user_id = sayfa_takipcileri.user_id and users.user_id = profil.user_id
             AND    profil.memleket = "istanbul,turkey");



/* 12 no'lu kullanıcının bilgileri ve yetenekleri ve egitim bilgilerini görüntüleyen query*/
SELECT users.name,users.lname,yetenekler.yetenek,egitimler.okul,egitimler.bolum,egitimler.acıklama
FROM   users,yetenekler,egitimler,profil
WHERE  users.user_id = 12 and users.user_id = profil.user_id and profil.profile_id = egitimler.profile_id and
profil.profile_id = yetenekler.profile_id;



/* en az 2 dil bilenlerin kullanıcı bilgileri*/
select users.name,users.lname,users.email,COUNT(yetkin_diller.profile_id) AS toplam_bilinen_dil_sayisi
from   users,yetkin_diller,profil
where  yetkin_diller.profile_id = profil.profile_id and profil.user_id = users.user_id
group by users.user_id
HAVING COUNT(yetkin_diller.profile_id)>1;



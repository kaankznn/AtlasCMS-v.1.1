CREATE DATABASE IF NOT EXISTS cms_nodejs
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE cms_nodejs;


-- TABLOLAR 

CREATE TABLE roller (
  rol_id INT AUTO_INCREMENT PRIMARY KEY,
  rol_adi VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE kullanicilar (
  kullanici_id INT AUTO_INCREMENT PRIMARY KEY,
  kullanici_adi VARCHAR(50) NOT NULL UNIQUE,
  sifre_hash VARCHAR(255) NOT NULL,
  eposta VARCHAR(120) UNIQUE,
  rol_id INT NOT NULL DEFAULT 2,
  olusturma_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_kullanici_rol
    FOREIGN KEY (rol_id) REFERENCES roller(rol_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE kategoriler (
  kategori_id INT AUTO_INCREMENT PRIMARY KEY,
  kategori_adi VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE yazilar (
  yazi_id INT AUTO_INCREMENT PRIMARY KEY,
  kullanici_id INT NOT NULL,
  kategori_id INT NOT NULL,
  baslik VARCHAR(150) NOT NULL,
  icerik TEXT NOT NULL,
  durum VARCHAR(10) NOT NULL DEFAULT 'draft',
  olusturma_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guncelleme_tarihi DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_yazi_durum CHECK (durum IN ('draft','published')),
  CONSTRAINT fk_yazi_kullanici
    FOREIGN KEY (kullanici_id) REFERENCES kullanicilar(kullanici_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_yazi_kategori
    FOREIGN KEY (kategori_id) REFERENCES kategoriler(kategori_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE sayfalar (
  sayfa_id INT AUTO_INCREMENT PRIMARY KEY,
  kullanici_id INT NOT NULL,
  slug VARCHAR(80) NOT NULL UNIQUE,
  baslik VARCHAR(150) NOT NULL,
  icerik TEXT NOT NULL,
  yayin_durumu VARCHAR(10) NOT NULL DEFAULT 'draft',
  olusturma_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_sayfa_durum CHECK (yayin_durumu IN ('draft','published')),
  CONSTRAINT fk_sayfa_kullanici
    FOREIGN KEY (kullanici_id) REFERENCES kullanicilar(kullanici_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE yorumlar (
  yorum_id INT AUTO_INCREMENT PRIMARY KEY,
  yazi_id INT NOT NULL,
  yazar_adi VARCHAR(80) NOT NULL,
  yazar_email VARCHAR(120),
  icerik TEXT NOT NULL,
  onayli TINYINT(1) NOT NULL DEFAULT 0,
  olusturma_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_yorum_onay CHECK (onayli IN (0,1)),
  CONSTRAINT fk_yorum_yazi
    FOREIGN KEY (yazi_id) REFERENCES yazilar(yazi_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- LOG TABLOSU (1 adet)
CREATE TABLE log_kayitlari (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  tablo_adi VARCHAR(50) NOT NULL,
  islem VARCHAR(10) NOT NULL,
  eski_veri TEXT,
  yeni_veri TEXT,
  islem_tarihi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Roller
INSERT INTO roller (rol_adi) VALUES ('admin'), ('editor');


-- 3NF ACIKLAMA
-- kullanicilar: PK = kullanici_id. Kullanici_adi, sifre_hash, eposta, rol_id direkt PK'ye bagli.
--   Kismi bagimlilik yok (PK tek alan). Rol bilgisi roller tablosunda tutuldu, transitif bagimlilik yok.
-- roller: PK = rol_id. rol_adi sadece PK'ye bagli.
-- kategoriler: PK = kategori_id. kategori_adi sadece PK'ye bagli.
-- yazilar: PK = yazi_id. baslik, icerik, durum, kategori_id, kullanici_id ve tarihler PK'ye bagli.
--   Kategori adi vb. burada tutulmuyor, kategori_id ile bagli (3NF).
-- sayfalar: PK = sayfa_id. alanlar direkt PK'ye bagli, baska tablodan gelen alan yok.
-- yorumlar: PK = yorum_id. yorum alanlari sadece PK'ye bagli, yazi bilgisi FK ile bagli.
-- Sonuc: Tum tablolar 1NF + 2NF + 3NF kosullarini saglar.


-- VIEWLER 

CREATE VIEW users AS
  SELECT
    kullanici_id AS user_id,
    kullanici_adi AS username,
    sifre_hash AS password_hash,
    eposta AS email,
    olusturma_tarihi AS created_at
  FROM kullanicilar;

CREATE VIEW categories AS
  SELECT
    kategori_id AS category_id,
    kategori_adi AS category_name
  FROM kategoriler;

CREATE VIEW posts AS
  SELECT
    yazi_id AS post_id,
    kullanici_id AS user_id,
    kategori_id AS category_id,
    baslik AS title,
    icerik AS content,
    durum AS status,
    olusturma_tarihi AS created_at
  FROM yazilar;


-- TRIGGERLER (INSERT/UPDATE/DELETE)

DELIMITER //

CREATE TRIGGER trg_yazi_insert
AFTER INSERT ON yazilar
FOR EACH ROW
BEGIN
  INSERT INTO log_kayitlari(tablo_adi, islem, eski_veri, yeni_veri)
  VALUES ('yazilar', 'INSERT', NULL,
          CONCAT('yazi_id=', NEW.yazi_id, ', baslik=', NEW.baslik, ', durum=', NEW.durum));
END //

CREATE TRIGGER trg_yazi_update
AFTER UPDATE ON yazilar
FOR EACH ROW
BEGIN
  INSERT INTO log_kayitlari(tablo_adi, islem, eski_veri, yeni_veri)
  VALUES ('yazilar', 'UPDATE',
          CONCAT('yazi_id=', OLD.yazi_id, ', baslik=', OLD.baslik, ', durum=', OLD.durum),
          CONCAT('yazi_id=', NEW.yazi_id, ', baslik=', NEW.baslik, ', durum=', NEW.durum));
END //

CREATE TRIGGER trg_yazi_delete
AFTER DELETE ON yazilar
FOR EACH ROW
BEGIN
  INSERT INTO log_kayitlari(tablo_adi, islem, eski_veri, yeni_veri)
  VALUES ('yazilar', 'DELETE',
          CONCAT('yazi_id=', OLD.yazi_id, ', baslik=', OLD.baslik, ', durum=', OLD.durum),
          NULL);
END //

DELIMITER ;


-- STORED PROCEDURE (3 adet)

DELIMITER //

CREATE PROCEDURE sp_kullanici_ekle(
  IN p_kullanici_adi VARCHAR(50),
  IN p_eposta VARCHAR(120),
  IN p_sifre_hash VARCHAR(255),
  IN p_rol_id INT
)
BEGIN
  INSERT INTO kullanicilar(kullanici_adi, eposta, sifre_hash, rol_id)
  VALUES (p_kullanici_adi, p_eposta, p_sifre_hash, p_rol_id);
END //

CREATE PROCEDURE sp_yazi_ekle(
  IN p_kullanici_id INT,
  IN p_kategori_id INT,
  IN p_baslik VARCHAR(150),
  IN p_icerik TEXT,
  IN p_durum VARCHAR(10)
)
BEGIN
  INSERT INTO yazilar(kullanici_id, kategori_id, baslik, icerik, durum)
  VALUES (p_kullanici_id, p_kategori_id, p_baslik, p_icerik, p_durum);
END //

CREATE PROCEDURE sp_yazi_durum_degistir(
  IN p_yazi_id INT,
  IN p_durum VARCHAR(10)
)
BEGIN
  UPDATE yazilar
  SET durum = p_durum
  WHERE yazi_id = p_yazi_id;
END //

DELIMITER ;

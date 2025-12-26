-- 10 karmasik sorgu + 3 transactions + optional procedure calls

USE cms_nodejs;

-- Karmasik Sorgu (10 adet)

-- 1) Join + Order By
SELECT y.baslik, k.kategori_adi, u.kullanici_adi, y.olusturma_tarihi
FROM yazilar y
JOIN kategoriler k ON y.kategori_id = k.kategori_id
JOIN kullanicilar u ON y.kullanici_id = u.kullanici_id
ORDER BY y.olusturma_tarihi DESC;

-- 2) Group By + Having
SELECT k.kategori_adi, COUNT(*) AS yazi_sayisi
FROM yazilar y
JOIN kategoriler k ON y.kategori_id = k.kategori_id
GROUP BY k.kategori_adi
HAVING COUNT(*) >= 2;

-- 3) Subquery (en son tarihli yazi)
SELECT *         
FROM yazilar
WHERE olusturma_tarihi = (SELECT MAX(olusturma_tarihi) FROM yazilar);

-- 4) Join + Group By (kullanici bazli)
SELECT u.kullanici_adi, COUNT(y.yazi_id) AS toplam
FROM kullanicilar u
LEFT JOIN yazilar y ON u.kullanici_id = y.kullanici_id
GROUP BY u.kullanici_adi;

-- 5) Subquery + Where (yazisi olmayan kullanici)
SELECT u.kullanici_id, u.kullanici_adi
FROM kullanicilar u
WHERE u.kullanici_id NOT IN (SELECT kullanici_id FROM yazilar);

-- 6) Join + Where + Order
SELECT y.baslik, y.durum, k.kategori_adi
FROM yazilar y
JOIN kategoriler k ON y.kategori_id = k.kategori_id
WHERE y.durum = 'published'
ORDER BY y.baslik ASC;

-- 7) Group By + Having (yorum sayisi)
SELECT y.baslik, COUNT(yo.yorum_id) AS yorum_sayisi
FROM yazilar y
LEFT JOIN yorumlar yo ON y.yazi_id = yo.yazi_id
GROUP BY y.baslik
HAVING COUNT(yo.yorum_id) > 0;

-- 8) Subquery (en cok yazan kullanici)
SELECT u.kullanici_adi
FROM kullanicilar u
WHERE u.kullanici_id = (
  SELECT y.kullanici_id
  FROM yazilar y
  GROUP BY y.kullanici_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
);

-- 9) Join + Filtre (yayinlanan sayfalar)
SELECT s.baslik, s.slug, u.kullanici_adi
FROM sayfalar s
JOIN kullanicilar u ON s.kullanici_id = u.kullanici_id
WHERE s.yayin_durumu = 'published'
ORDER BY s.olusturma_tarihi DESC;

-- 10) Subquery + Join (kategori, yazi sayisi)
SELECT k.kategori_adi,
       (SELECT COUNT(*) FROM yazilar y WHERE y.kategori_id = k.kategori_id) AS adet
FROM kategoriler k
ORDER BY adet DESC;


-- TRANSACTION ORNEKLERI (3 adet)

-- TRANSACTION 1: Yazı ekleme
START TRANSACTION;
  INSERT INTO yazilar(kullanici_id, kategori_id, baslik, icerik, durum)
  VALUES (1, 1, 'Deneme Baslik', 'Deneme icerik', 'draft');
COMMIT;

-- TRANSACTION 2: Hatalı güncelleme senaryosu
START TRANSACTION;
  UPDATE yazilar SET kategori_id = 2 WHERE yazi_id = 1;
  -- Burada bir problem olduğunu varsayalım
ROLLBACK;

-- TRANSACTION 3: Kullanıcı + Sayfa ekleme birlikte
START TRANSACTION;
  INSERT INTO kullanicilar(kullanici_adi, eposta, sifre_hash, rol_id)
  VALUES ('ornek_user', 'ornek@mail.com', 'hash_buraya', 2);

  INSERT INTO sayfalar(kullanici_id, slug, baslik, icerik, yayin_durumu)
  VALUES (LAST_INSERT_ID(), 'hakkimizda', 'Hakkimizda', 'Kisa metin', 'published');
COMMIT;

-- CRUD ornekleri (kisa)
-- INSERT: INSERT INTO kategoriler(kategori_adi) VALUES ('Teknoloji');
-- UPDATE: UPDATE kategoriler SET kategori_adi = 'Matematik' WHERE kategori_id = 1;
-- DELETE: DELETE FROM kategoriler WHERE kategori_id = 3;
-- SELECT: SELECT * FROM kategoriler;
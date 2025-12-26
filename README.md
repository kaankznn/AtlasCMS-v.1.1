# NodeCore-CMS v1.1

![Node.js](https://img.shields.io/badge/Node.js-Backend-success)
![MySQL](https://img.shields.io/badge/MySQL-Relational-blue)
![SQL](https://img.shields.io/badge/SQL-3NF%20Design-orange)

NodeCore-CMS, Node.js ve MySQL kullanılarak geliştirilmiş, ilişkisel veritabanı tasarımı ve veri bütünlüğü odaklı bir Content Management System (CMS) projesidir.

Bu proje, yalnızca bir demo uygulama değil; **gerçek dünyada kullanılabilecek bir CMS backend mimarisini** örneklemek amacıyla tasarlanmıştır.  
Veritabanı normalizasyonu, SQL kısıtlamaları ve ileri seviye SQL yapıları projenin merkezindedir.

---

## 📌 Genel Bakış

Bu projede aşağıdaki gereksinimler eksiksiz şekilde sağlanmıştır:

- En az **5 ana tablo + 1 log tablosu**
- **3NF (Third Normal Form)** uyumlu veritabanı tasarımı
- Kısıtlama ayarlamaları
- 3 adet **VIEW**
- 3 adet **STORED PROCEDURE**
- 3 adet **TRANSACTION** örneği
- 10 adet **kompleks SQL sorgusu**
- Trigger kullanılarak **otomatik veritabanı loglama**

**Mevcut sürüm:** `v1.1`

---

## 🛠️ Kullanılan Teknolojiler

- **Node.js**
- **MySQL (XAMPP)**
- **phpMyAdmin**
- **mysql2 / promise**
- **bcrypt / bcryptjs**
- **Express + EJS**

---

## ✨ Özellikler

- **Rol tabanlı kullanıcı yönetimi (admin / editor)**
- **Yazı (post) yönetimi: ekleme, güncelleme, silme, yayınlama**
- **Kategori sistemi**
- **Statik sayfa yönetimi**
- **Yorum sistemi**
- **Veritabanı otomatik loglama sistemi**
- **View, Stored Procedure, Transaction ve SQL sorguları**

---

## 📁 Proje Yapısı

```
nodecore-cms-nodejs/
│
├─ controllers/
├─ middlewares/
├─ routes/
├─ views/
├─ sql/
│ ├─ schema.sql # Veritabanı kurulumu (tablolar, constraint’ler, trigger’lar, view’lar, SP)
│ └─ examples.sql # Kompleks sorgular, transaction örnekleri
│
├─ project-report/
│ └─ CMS_Project_Report.docx
│
├─ app.js
├─ db.js
├─ package.json
├─ .env.example
├─ .gitignore
└─ README.md
```

## Kurulum ve Çalıştırma

1) Kurulum aşaması

+ `npm install`
+ `.env` oluştur: .env.example dosyasını kopyalayarak .env oluştur ve kendi MySQL bilgilerini yaz.

2) Veritabanını kur:

`phpMyAdmin → SQL sekmesi`

+ Önce `sql/schema.sql` çalıştır
+ Sonra `sql/examples.sql` çalıştır.

3) Uygulamayı çalıştır:

`node app.js`

`Uygulama`: `http://localhost:3000`

## Notlar

+ `.env` dosyası güvenlik için repo'ya eklenmemiştir.
+ `node_modules/` ayrıca repo dışında tutulmuştur.

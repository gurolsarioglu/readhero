# 🧪 READHERO - MANUEL TEST SENARYOLARI

**Test Tarihi:** 16 Ocak 2026  
**Test Eden:** [İsim]  
**Platform:** Android Emulator

---

## 📱 TEST ORTAMI HAZIRLIĞI

### Ön Koşullar
- [ ] Emülatör çalışıyor
- [ ] Uygulama yüklendi
- [ ] İnternet bağlantısı var
- [ ] Veritabanı temiz (ilk test için)

### Test Verileri
- **Email:** test@example.com
- **Telefon:** 05551234567
- **Şifre:** Test123!
- **İsim:** Test Veli
- **Email Doğrulama Kodu:** 123456

---

## 🎯 TEST SENARYOLARI

### ✅ TEST 1: VELİ KAYDI VE GİRİŞ

#### Adımlar:
1. [ ] Uygulamayı aç
2. [ ] Splash ekranı göründü mü?
3. [ ] Onboarding ekranlarını geç
4. [ ] "Kayıt Ol" butonuna tıkla
5. [ ] Formu doldur:
   - Email: test@example.com
   - Telefon: 05551234567
   - Şifre: Test123!
   - İsim: Test Veli
6. [ ] "Kayıt Ol" butonuna tıkla
7. [ ] Email doğrulama ekranı açıldı mı?
8. [ ] Doğrulama kodu gir: 123456
9. [ ] "Doğrula" butonuna tıkla
10. [ ] Telefon otomatik doğrulandı mı?

#### Beklenen Sonuçlar:
- [ ] Kayıt başarılı
- [ ] Email doğrulandı
- [ ] Telefon doğrulandı
- [ ] Öğrenci ekleme ekranına yönlendirildi

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 2: ÖĞRENCİ EKLEME (LİMİT TESTİ)

#### Adımlar:
1. [ ] "Öğrenci Ekle" butonuna tıkla
2. [ ] 1. Öğrenci:
   - İsim: Ahmet
   - Sınıf: 1. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
3. [ ] 2. Öğrenci:
   - İsim: Ayşe
   - Sınıf: 2. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
4. [ ] 3. Öğrenci:
   - İsim: Mehmet
   - Sınıf: 3. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
5. [ ] 4. Öğrenci:
   - İsim: Fatma
   - Sınıf: 4. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
6. [ ] 5. Öğrenci:
   - İsim: Ali
   - Sınıf: 1. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
7. [ ] 6. Öğrenci:
   - İsim: Zeynep
   - Sınıf: 2. Sınıf
   - Avatar: Seç
   - [ ] Kaydet
8. [ ] 7. Öğrenci eklemeye çalış
   - [ ] Hata mesajı göründü mü?

#### Beklenen Sonuçlar:
- [ ] İlk 6 öğrenci başarıyla eklendi
- [ ] 7. öğrenci için hata: "Maksimum 6 öğrenci ekleyebilirsiniz"
- [ ] Öğrenci listesi doğru görüntüleniyor

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 3: ÖĞRENCİ OLARAK OKUMA (1. SINIF)

#### Adımlar:
1. [ ] Ahmet'i seç (1. Sınıf)
2. [ ] Ana ekran açıldı mı?
3. [ ] "Kütüphane" butonuna tıkla
4. [ ] Hikaye listesi göründü mü?
5. [ ] 1. Sınıf hikayeleri filtrelendi mi?
6. [ ] Bir hikaye seç (örn: "Küçük Kedi Minnos")
7. [ ] Hikaye detay sayfası açıldı mı?
8. [ ] "Okumaya Başla" butonuna tıkla
9. [ ] Okuma ekranı açıldı mı?
10. [ ] Kronometre GİZLİ mi? (1. sınıf için)
11. [ ] Ses kaydı butonu VAR MI? (1. sınıf için)
12. [ ] Hikayeyi oku (scroll yap)
13. [ ] "Bitir" butonuna tıkla
14. [ ] Quiz giriş ekranı açıldı mı?

#### Beklenen Sonuçlar:
- [ ] 1. sınıf için kronometre gizli
- [ ] Ses kaydı özelliği var (veya placeholder)
- [ ] Metin okunabilir (font, satır aralığı)
- [ ] Biyonik okuma çalışıyor
- [ ] Quiz'e yönlendirildi

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 4: QUIZ ÇÖZME

#### Adımlar:
1. [ ] Quiz giriş ekranı açıldı mı?
2. [ ] "Başla" butonuna tıkla
3. [ ] Soru 1 göründü mü?
4. [ ] Geri sayım çalışıyor mu? (10:00)
5. [ ] Bir şık seç
6. [ ] "Sonraki" butonuna tıkla
7. [ ] Soru 2'ye geçildi mi?
8. [ ] Tüm 5 soruyu cevapla
9. [ ] "Bitir" butonuna tıkla
10. [ ] Sonuç ekranı açıldı mı?

#### Beklenen Sonuçlar:
- [ ] 5 soru gösterildi
- [ ] Geri sayım çalıştı
- [ ] Cevaplar kaydedildi
- [ ] Sonuç ekranı doğru puan gösterdi
- [ ] Puan kazanıldı
- [ ] Konfeti animasyonu (başarılıysa)

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 5: ÖĞRENCİ OLARAK OKUMA (2-4. SINIF)

#### Adımlar:
1. [ ] Ana ekrana dön
2. [ ] Öğrenci değiştir
3. [ ] Ayşe'yi seç (2. Sınıf)
4. [ ] Kütüphaneye git
5. [ ] 2. Sınıf hikayesi seç
6. [ ] "Okumaya Başla" butonuna tıkla
7. [ ] Kronometre GÖRÜNÜR mü? (2. sınıf için)
8. [ ] Ses kaydı butonu YOK mu?
9. [ ] Hikayeyi oku
10. [ ] "Bitir" butonuna tıkla
11. [ ] WPM hesaplandı mı?

#### Beklenen Sonuçlar:
- [ ] 2-4. sınıf için kronometre görünür
- [ ] Ses kaydı yok
- [ ] WPM doğru hesaplandı
- [ ] Okuma süresi kaydedildi

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 6: HEDEF SİSTEMİ

#### Adımlar:
1. [ ] Ana ekranda "Hedeflerim" butonuna tıkla
2. [ ] Hedefler sayfası açıldı mı?
3. [ ] Günlük hedefler tab'ı seçili mi?
4. [ ] Günlük hedefler göründü mü?
   - [ ] Okuma süresi (20 dakika)
   - [ ] Kitap tamamlama (1 kitap)
5. [ ] Haftalık hedefler tab'ına geç
6. [ ] Haftalık hedefler göründü mü?
   - [ ] Kitap tamamlama (5 kitap)
   - [ ] Quiz geçme (5 sınav)
   - [ ] Streak (5 gün)
7. [ ] Aylık hedefler tab'ına geç
8. [ ] Aylık hedefler göründü mü?
   - [ ] Kitap tamamlama (20 kitap)
   - [ ] Mükemmel sınav (10 adet)
9. [ ] İlerleme çubukları çalışıyor mu?
10. [ ] Ödül puanları gösteriliyor mu?

#### Beklenen Sonuçlar:
- [ ] Tüm hedefler doğru gösterildi
- [ ] İlerleme çubukları çalışıyor
- [ ] Ödül puanları doğru
- [ ] Tab geçişleri sorunsuz

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 7: GÖZ SAĞLIĞI SİSTEMİ

#### Adımlar:
1. [ ] Bir hikaye okumaya başla
2. [ ] 20 dakika bekle (veya test için süreyi kısalt)
3. [ ] Göz molası ekranı açıldı mı?
4. [ ] Geri sayım (20 saniye) çalışıyor mu?
5. [ ] Mini oyun (balonlar) var mı?
6. [ ] Molayı tamamla
7. [ ] +5 puan kazanıldı mı?
8. [ ] Ayarlar > Göz Sağlığı'na git
9. [ ] Tüm ayarlar çalışıyor mu?
   - [ ] Font boyutu
   - [ ] Satır aralığı
   - [ ] Mavi ışık filtresi
   - [ ] Hatırlatma aralığı

#### Beklenen Sonuçlar:
- [ ] 20-20-20 kuralı çalışıyor
- [ ] Göz molası ekranı doğru
- [ ] Puan kazanıldı
- [ ] Ayarlar çalışıyor

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 8: VELİ PANELİ - DASHBOARD

#### Adımlar:
1. [ ] Ana ekranda hamburger menüye tıkla
2. [ ] "Veli Paneli" seçeneğine tıkla
3. [ ] Dashboard açıldı mı?
4. [ ] Özet kartlar göründü mü?
   - [ ] Bugün okunan süre
   - [ ] Toplam okunan kitap
   - [ ] Ortalama başarı (%)
   - [ ] Toplam puan
5. [ ] Grafikler yüklendi mi?
   - [ ] Okuma gelişim grafiği (line chart)
   - [ ] Quiz başarı grafiği (bar chart)
6. [ ] Hızlı eylemler çalışıyor mu?

#### Beklenen Sonuçlar:
- [ ] Dashboard doğru açıldı
- [ ] Tüm kartlar doğru veri gösteriyor
- [ ] Grafikler çalışıyor
- [ ] Veriler güncel

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 9: VELİ PANELİ - GEÇMİŞ

#### Adımlar:
1. [ ] Veli panelinde "Okuma Geçmişi" butonuna tıkla
2. [ ] Okuma geçmişi sayfası açıldı mı?
3. [ ] Tüm okuma oturumları listeleniyor mu?
4. [ ] Her oturum için bilgiler doğru mu?
   - [ ] Hikaye adı
   - [ ] Süre
   - [ ] WPM (2-4. sınıf için)
   - [ ] Tarih
5. [ ] "Quiz Geçmişi" butonuna tıkla
6. [ ] Quiz geçmişi sayfası açıldı mı?
7. [ ] Tüm sınavlar listeleniyor mu?
8. [ ] Her sınav için bilgiler doğru mu?
   - [ ] Hikaye adı
   - [ ] Başarı oranı (%)
   - [ ] Tarih

#### Beklenen Sonuçlar:
- [ ] Okuma geçmişi doğru
- [ ] Quiz geçmişi doğru
- [ ] Tüm veriler güncel
- [ ] Filtreleme çalışıyor

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 10: ÖDÜL SİSTEMİ

#### Adımlar:
1. [ ] Veli panelinde "Ödüller" butonuna tıkla
2. [ ] Ödüller sayfası açıldı mı?
3. [ ] "Ödül Ekle" butonuna tıkla
4. [ ] Ödül formu açıldı mı?
5. [ ] Ödül ekle:
   - Başlık: Dondurma
   - Açıklama: Favori dondurmandan
   - Gerekli Puan: 100
6. [ ] Kaydet
7. [ ] Ödül listeye eklendi mi?
8. [ ] Öğrenci paneline geç
9. [ ] "Ödüllerim" butonuna tıkla
10. [ ] Ödül vitrini açıldı mı?
11. [ ] Ödül görünüyor mu?
12. [ ] Kilitli/Açık durumu doğru mu?
13. [ ] İlerleme çubuğu çalışıyor mu?

#### Beklenen Sonuçlar:
- [ ] Veli ödül ekleyebildi
- [ ] Öğrenci ödülü görebiliyor
- [ ] Kilitli/Açık durumu doğru
- [ ] İlerleme doğru hesaplanıyor

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 11: ROZET SİSTEMİ

#### Adımlar:
1. [ ] Öğrenci olarak giriş yap
2. [ ] İlk kitabı oku ve bitir
3. [ ] "İlk Kitap" rozeti kazanıldı mı?
4. [ ] Rozet popup'ı göründü mü?
5. [ ] Profil sayfasına git
6. [ ] Rozetler bölümü var mı?
7. [ ] Kazanılan rozet gösteriliyor mu?
8. [ ] 10 kitap oku
9. [ ] "Kitap Kurdu" rozeti kazanıldı mı?

#### Beklenen Sonuçlar:
- [ ] Rozetler otomatik kazanılıyor
- [ ] Popup animasyonu çalışıyor
- [ ] Rozetler profilde görünüyor
- [ ] Rozet koşulları doğru

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 12: ANİMASYONLAR VE UX

#### Adımlar:
1. [ ] Sayfa geçişlerini test et
2. [ ] Animasyonlar akıcı mı?
3. [ ] Mascot karakteri çalışıyor mu?
4. [ ] Buton tıklama efektleri var mı?
5. [ ] Loading animasyonları çalışıyor mu?
6. [ ] Puan kazanma animasyonu çalışıyor mu?
7. [ ] Konfeti animasyonu çalışıyor mu?
8. [ ] İlerleme çubukları animasyonlu mu?

#### Beklenen Sonuçlar:
- [ ] Tüm animasyonlar akıcı
- [ ] Mascot doğru çalışıyor
- [ ] UX sorunsuz
- [ ] Performans iyi

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

### ✅ TEST 13: SES EFEKTLERİ

#### Adımlar:
1. [ ] Ayarlar > Ses Efektleri'ne git
2. [ ] Ses efektleri açık mı?
3. [ ] Butonlara tıkla
4. [ ] Haptic feedback çalışıyor mu?
5. [ ] Başarı sesi çalıyor mu?
6. [ ] Hata sesi çalıyor mu?
7. [ ] Ses efektlerini kapat
8. [ ] Sesler kapandı mı?

#### Beklenen Sonuçlar:
- [ ] Haptic feedback çalışıyor
- [ ] Sesler doğru çalıyor
- [ ] Ayarlar çalışıyor

#### Notlar:
```
[Test sonuçlarını buraya yazın]
```

---

## 🐛 BULUNAN HATALAR

### Kritik Hatalar
1. 
2. 
3. 

### Orta Seviye Hatalar
1. 
2. 
3. 

### Küçük Hatalar / İyileştirmeler
1. 
2. 
3. 

---

## 📝 GENEL NOTLAR

### Performans
```
[Performans gözlemlerinizi buraya yazın]
```

### Kullanıcı Deneyimi
```
[UX gözlemlerinizi buraya yazın]
```

### Öneriler
```
[Önerilerinizi buraya yazın]
```

---

## ✅ TEST SONUCU

- [ ] **TÜM TESTLER BAŞARILI**
- [ ] **BAZI TESTLER BAŞARISIZ** (Yukarıda belirtildi)
- [ ] **MAJOR SORUNLAR VAR** (Acil düzeltme gerekli)

**Test Tamamlanma Tarihi:** _______________  
**Test Eden İmza:** _______________

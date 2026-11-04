# V36 Özellik Kuyruğu: rakiplerin en iyisi, Kabinsiz yoluyla

- **Tarih:** 2026-11-04.
- **Kaynaklar:**
  - `docs/research/rivals/parity.md` (MISSING ve PARTIAL satırlar);
  - `feedback.md` (kullanıcı yorumlarından düzeltmeler);
  - ADR-017.
- **Her iş paketinin döngüsü:** SPEC → THREAT → CODE → TEST → EVIDENCE.
- **Durum sınıfları:** CODED, SIMULATOR_TESTED, DEVICE_VERIFIED, BLOCKED_EXTERNAL, NOT_RUN.
- **Sıra kuralı:** önce kullanıcının açık isteği (beden formu), sonra her gün kullanılan özellikler (ekleme ve günlük kombin), sonra seyahat ve keşif.

| # | İş paketi | Rakipten alınan iş | Kabinsiz yolu (cihazda) | Mahremiyet sınırı | Testler | Durum |
|---|---|---|---|---|---|---|
| V36-01 | Beden formu seçici + ölçü ekranı | Alta (ölçüden avatar), Doji (yeniden kur) | Benim Modelim → "Beden formu: Kadın / Erkek / Nötr"; göğüs (büst), bel, kalça ve omuz öne çıkar; ana ekran figürü formu izler | Form yalnız kullanıcının seçimi, hiçbir şeyden çıkarılmaz | BFORM-T01..T07 (paket); BodyFormUITests + ekran görüntüleri | DONE, SIMULATOR_TESTED (2026-11-04): başlangıç ekranında ve stüdyoda segmentli seçici; Kadın'da göğüs satırı "Göğüs (büst) çevresi"; değer korunur, geri al/yinele, yeniden açılışta form kalır; ana ekran figürü formu izler. Simülatörde profildeki RealityView bazen çizilmiyor (ADR-016 bilinen açığı, OPEN). Cihaz REAL_DEVICE_BLOCKED (R-002) |
| V36-02 | Takvimden günün ihtiyacı | Alta | EventKit okuma izni (isteğe bağlı) → başlık `OccasionReader` ile cihazda okunur → `DayNeeds` → TodayOutfit resmiyet tabanı; "neden bu kombin" satırı | Başlık saklanmaz, loglanmaz, gönderilmez; izin yoksa özellik kapalı | INS-T08; izin reddi UI testi | Paket CODED + test |
| V36-03 | Fotoğraftan dolaba: kesip çıkarma, otomatik etiket, toplu ekleme | Alta (SAM), Cladwell | PhotosPicker çoklu seçim → `VNGenerateForegroundInstanceMaskRequest` (iOS 17+) → renk pikselden, kategori cihaz sınıflandırıcısından → kullanıcı onaylar | Fotoğraf cihazda kalır, kesilmiş görsel Vault'ta; SAM 3 yok (CUDA, lisans) | PHOTO-T01..T08 | Paket CODED + macOS test (2026-11-04): Vision ön plan maskesi cihazda; düz arka plan yedeği; renk Lab k-means (düğme/kıvrım karar vermez); piksel değişmez; tür önerisi Apple sınıflandırıcısı ≥0,3 değilse şekil kuralları — kendi 13 giysimizde 12/13 (ceket→üst bilinen eksik). UI (PhotosPicker toplu + onay kuyruğu) sırada |
| V36-04 | Giyim günlüğü, stil takvimi, en çok/az giyilenler, giyim başı maliyet, boşluklar | Alta, Cladwell | "Bugün bunu giydim" → `WearLedger`; Dolabım'da "Dolap raporu" (`ClosetReport`, `ClosetGapFinder`); fiyatı yalnız kullanıcı girer | Yerel ve şifreli (Vault alanı); demo dolapta "örnek" etiketi | INS-T01..T06; UI testi | Paket CODED + test |
| V36-05 | Şehir dünyası ekranı: gerçek şehir adı, A/B/C katman, güneş ışığı, 6 hava | — (Kabinsiz'e özgü) | `CitySceneResolver` + `LightPhase.stageLight` + `SceneWeatherState` (kar, sis, bulut, rüzgâr parçacıkları); konumdan şehir: katalog → CLGeocoder; varsayılan stüdyo | Konum noktası saklanmaz; CLGeocoder isteği konum izni metninde yazılı; rüzgâr giysiyi oynatmaz (ADR-016) | CITY-T01..T07, SUN-T01..T04, WX-T01..T04; pixel-diff UI | Paket CODED + test; sahne sırada |
| V36-06 | Bağlantıdan ya da paylaşımla ürün ekleme | Doji, Google, Anywear | Share Extension → URL → yalnız lisanslı alan adları için ürün sayfası okunur (`BrandSourceGate`); diğerlerinde yalnız ad ve fotoğraf kullanıcıdan | Marka sitesi kazınmaz (V32-WEB-02); kişisel veri gitmez | Gate testleri | NOT_RUN |
| V36-07 | Fişten ekleme | Alta | Fiş fotoğrafı ya da PDF paylaşılır → `VNRecognizeText` → satır adayları → kullanıcı seçer | Fiş cihazda; fiyat yalnız kullanıcı onayıyla `UserPrice` olur | OCR fixture testleri | NOT_RUN |
| V36-08 | Çok şehirli seyahat | Alta | `TripPlanner` bacakları (her bacak: şehir, tarih aralığı, hava) → tek valiz | Hava yalnız hedef şehir için, cihaz konumu için değil | TravelEngine testleri | NOT_RUN |
| V36-09 | Doğal dille kombin isteme | Alta, Cladwell | Cihaz desteklerse Apple Foundation Models (cihaz içi), değilse anahtar kelime kuralları → `DayNeeds` | Metin cihazdan çıkmaz | Kural testleri; model yoksa geri dönüş testi | NOT_RUN |
| V36-10 | Fotogerçekçi tek kare (L1) | Google, Doji | FASHN VTON 1.5, Mac'te çevrim dışı PoC, `segmentation_free`, ayrıştırıcı yok | Kullanıcı fotoğrafı kullanılmaz (yalnız sentetik ya da rızalı); bulut yok | Kalite ölçütü, lisans kapısı | RUN 2026-11-04: Mac'te çalıştı (64–290 s/kare); bizim avatarımızı fotogerçekçi yapmıyor → avatar yolu olarak kapandı, yalnız stüdyo/öğretmen (`docs/research/fashn-poc/`) |
| V36-11 | Rakip yorum düzeltmeleri | `feedback.md` "Top 8" | Her düzeltme yukarıdaki paketlerden birine bağlanır ya da yeni satır olur | — | — | `feedback.md` tamamlanınca bağlanır |

## Rakip yorum düzeltmeleri → paket eşlemesi

**Kaynak:** `docs/research/rivals/reviews.csv` (420 yorum, 6 uygulama). Yorumlar yalnız Apple'ın resmi RSS akışından alındı; özetler 20 kelimeyi geçmez, yorumcu adı yok. Yorum sayıları ve sınırları `feedback.md` içinde.

**En sık temalar** (temalı yorum / bunların şikâyet olanları):

| Tema | Yorum | Şikâyet |
|---|---|---|
| Ücret, ödeme duvarı | 59 | 43 |
| Kombin önerisinin isabeti | 59 | 29 |
| Çökme, hata, veri kaybı | 37 | 36 |
| Ekleme zahmeti | 32 | 16 |
| Hava ve takvim | 27 | 16 |
| Avatarın kişiye benzemesi | 26 | 10 |
| Giysiyi değiştiren yapay zekâ temizliği | 20 | 12 |
| Giriş zorluğu | 16 | 15 |

**Sayılar yaklaşıktır:** temalar özetlenmiş metinden atandı (bkz. `feedback.md`).

| Düzeltme (feedback.md Top 8) | Paket |
|---|---|
| 1. Beden yazılan ölçülerden, Kadın/Erkek/Nötr formla | V36-01 (DONE, simülatör) |
| 2. Giysi aslına sadık: orijinal fotoğraf esas, cihazda maske, önce/sonra, renk ve biçim değişmez | V36-03 |
| 3. Yalnız kendi dolabından öneri | TodayOutfit değişmezi (zaten yalnız `Wardrobe`); V36-02/04'te "sessize al" ve mevsim bayrakları |
| 4. Hesap yok, veri yerel, dışa aktarma ve yedek | DONE (hesapsız, Vault); dışa aktarma → V36-14 |
| 5. Hızlı toplu ekleme | V36-03 |
| 6. Katmanlı 3B kabuk (alt, orta, dış, aksesuar), içe sokulmuş ve açık ceket durumları | V36-12 (yeni) |
| 7. Hava, takvim, kalıcı plan ve giyim takvimi, çok günlük valiz | V36-02, V36-04, V36-08 |
| 8. Dürüst uyum: kullanıcının girdiği giysi ölçüsü × beden ölçüsü, "tahmin" etiketli dar/bol ısı haritası | V36-13 (yeni) |

**Yeni paketler:**

| # | İş paketi | Kabinsiz yolu | Sınır | Durum |
|---|---|---|---|---|
| V36-12 | Katman durumları | `DressedAvatarState` katman sırası + `GarmentMesh` "içe sokulu" ve "açık ceket" varyantları; elle döndürülen modelde | Hiçbir şey kendiliğinden hareket etmez (ADR-016) | NOT_RUN |
| V36-13 | Giysi ölçüsüyle uyum tahmini | Kullanıcının düz ölçtüğü giysi ölçüsü (göğüs, bel, boy) − beden ölçüsü + kolaylık payı → bölge bölge dar/bol | Yalnız kullanıcı ölçümüyle; lisanslı tablo yoksa marka bedeni iddiası yok (R-004); ekranda "tahmin · ölçüm değil"; AG-06 Fit Science incelemesi | NOT_RUN |
| V36-14 | Dışa aktarma ve yedek | Vault'tan şifreli arşiv, Dosyalar'a paylaşım | Anahtar cihazda; arşiv parolasız gitmez | NOT_RUN |

**Ücret teması (59 yorum, 43 şikâyet):** fiyatlandırma insan onayı gerektirir; bu iş kod kuyruğunda değildir. Öneri: çekirdek özellikler ücretsiz, ödeme duvarı açılışta değil.

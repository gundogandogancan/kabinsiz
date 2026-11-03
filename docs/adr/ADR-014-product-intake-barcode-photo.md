# ADR-014 — Ürünü getir: canlı barkod, etiket/barkod fotoğrafı ya da kod; okuma cihazda

- **Durum:** Kabul edildi (2026-11-04). D-002'nin "kamera taraması P0'da ertelendi" kısmının yerini alır; elle kod girişi yedek yol olarak kalır.
- **Kaynak:** Kullanıcı kararı 2026-11-04: "Sadece ürün kodunu yazmayacak, ürünün barkod veya fotoğrafını çekebilir." v1.3 §60 (Tara → karar kartı), §64.2 (girdi kuralları), T-V13-003 (benzer ürün yok), V15-T-SEC-05 (barkoddaki bağlantı açılmaz); v2.8 D-030 (Dene = barkod/kod + dolap + model + ayna).
- **İş paketi:** SCAN-WP01 (SCAN-T001…T015).

## Bağlam

Önceki durum:

- Tara ekranı yalnız elle kod yazmayı kabul ediyordu.
- Canlı barkod taraması yalnız Dene'de ve yalnız VisionKit `DataScannerViewController` destekleyen iPhone'larda vardı.
- "Fotoğraftan" kutucuğu "Bu sürümde yok" diyordu.

Kullanıcı ürünü yazmadan getirmek istiyor: barkodu taratarak ya da fotoğrafını çekerek.

## Karar 1 — Üç yol, aynı karar kartı

Tara ekranında (Dene'deki "Barkod tara", "Kodu yaz" ve "Fotoğraftan" kutucukları ve Bugün'deki "Ürünü tara" buraya açılır) şu yollar var:

1. **Barkodu tara:** canlı kamera, VisionKit. Yalnız desteklenen cihazlarda.
2. **Fotoğraf çek:** sistem kamerasıyla tek kare. Kamera yoksa düğme kapalıdır ve ekran nedenini söyler.
3. **Fotoğraf seç:** `PhotosPicker`, süreç dışında çalışır, galeri izni istemez. Yalnız seçilen fotoğraf gelir; varlık kimliği istenmez.
4. **Ya da kodu yaz:** elle giriş, önceki yedek yol.

Canlı tarama olmayan cihazlarda Dene'deki "Barkod tara" kapalı kalmaz, fotoğraf yoluna açılır.

## Karar 2 — Fotoğraf cihazda okunur, saklanmaz, gönderilmez

`ProductCapture` modülü (KabinsizCore) iki parçadan oluşur:

- **`ProductLabelReader`:**
  - Fotoğrafı ImageIO ile en fazla 2048 px'e küçültür ve dik çevirir. Bu adım EXIF ve konum bilgisini de düşürür; yalnız pikseller kalır.
  - Vision ile barkodları okur: EAN-13/8, UPC-E, Code 128/39/93, ITF-14, QR, DataMatrix, PDF417.
  - Vision ile yazıyı da okur: dil düzeltmesi kapalı, çünkü kodlar kelime değildir.
- **Dayanıklılık (2026-11-04'te ölçüldü):**
  - Barkod ve yazı ayrı istekle okunur; biri çalışmazsa diğeri sonuç verir ve ekran "yalnız barkoda/yazıya bakıldı" der.
  - Vision hızlandırıcı bağlamı kuramazsa her istek bir kez CPU'da yeniden çalışır.
  - En yeni barkod modeli (revizyon 4) iOS simülatöründe hata 9 verdi; CPU'da da hiç sonuç döndürmedi. Klasik dedektör (revizyon 2) aynı barkodu okudu. Bu yüzden en yeni model hata verir ya da hiçbir şey bulamazsa revizyon 2 bir kez daha bakar.
  - Aynı 11 test hem macOS'ta hem iOS simülatöründe geçti (`xcodebuild -scheme KabinsizCore-Package -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:ProductCaptureTests`).
  - Okuyucu hiç çalışmazsa ekran "Fotoğraf açılamadı" demez. "Etiket okunamadı, tahmin etmiyoruz" der; dosyanın açılamaması ayrı bir durumdur.
- **`ProductCodeMatcher`:** saf ve deterministik eşleştirici. Kuralları:
  - Barkodlar yazıdan önce gelir.
  - Ürün kodu, çözümleyicinin girdi kurallarına uyan, 2–6 parçalı, harf ve rakam içeren koddur.
  - GTIN, GS1 kontrol hanesiyle doğrulanır.
  - Bağlantı, telefon ya da betik içeren barkod içeriği **reddedilir ve sayılır**; açılmaz, çözülmez (V15-T-SEC-05).
  - OCR karışıklıkları (O/0, I/1, S/5, B/8) yalnız yazıdan okunan ve rakam içeren parçalarda düzeltilir, ve düzeltilen kod katalogda yoksa kabul edilmez. Barkod asla "düzeltilmez".

Fotoğraf ekranda tutulmaz. Okuma bittikten sonra yalnız okunan kodlar kalır. Ağ yok, depolama yok; mevcut statik ağ taraması yeni dosyaları da kapsar.

## Karar 3 — Yalnız katalog eşleşmesi; benzer ürün yok

Dört sonuç, ekranda açıkça:

| Sonuç | Ekran |
|---|---|
| Tek ürün | Karar kartı + "Fotoğraftaki barkoddan (Code128) okundu: KB-JKT-01-NVY" ya da "Etiketteki yazıdan okundu" |
| Birden fazla ürün ya da renk | "Hangisi?" listesi; tahmin yok |
| Kod okundu, katalogda yok | Okunan kod ve türü (ör. EAN-13); "mağaza kataloğu bağlı değil, benzer ürün göstermiyoruz" |
| Hiçbir şey okunamadı | "Etiketi ya da barkodu yakından, düz ve aydınlık çek. Ürünü yalnız görünüşünden tanıma bu sürümde yok" |

**Görünüşten ürün tanıma yapılmaz.** Etiketsiz bir giysi fotoğrafından "hangi ürün" demek için lisanslı bir katalog ve görsel eşleme gerekir. Bu dış bağımlılıktır (`BLOCKED_EXTERNAL`, R-004). Tahmini bir ürünü gerçekmiş gibi göstermek T-V13-003 ihlali olur.

## Karar 4 — Kamera izni metni

`NSCameraUsageDescription` artık iki kullanımı da söylüyor: Canlı Ayna ve barkod/etiket okuma. Görüntü yalnız bu iPhone'da işlenir; kaydedilmez ve gönderilmez. Kamera izni yalnız kullanıcı "Fotoğraf çek" ya da "Barkodu tara"ya dokununca sistem tarafından istenir.

## Test ve kanıt

- **SCAN-T001…T010 + T006b** (`ProductCaptureTests`, gerçek Vision; macOS ve iOS simülatöründe):
  - Code 128 etiket ve yalnız basılı kod (4° eğik) doğru varyanta gider.
  - Katalogda olmayan EAN-13 "katalogda yok" der.
  - QR içindeki bağlantı reddedilir.
  - Etiketsiz giysi fotoğrafı "okunamadı" der.
  - Küçültme ve bozuk veri reddi çalışır.
  - Model kodu renk sorar; iki ürün ikisini de sunar.
  - OCR düzeltme sınırlarına uyulur.
  - GTIN kontrol hanesi denetlenir; fiyat ve beden gürültüsü kod sayılmaz.
- **SCAN-T011…T015** (`ProductPhotoUITests`, simülatör): Simülatörde gerçek bir etiketin fotoğrafı çekilemez. Bu yüzden DEBUG `-productPhotoFixture` cihazda sentetik bir etiket çizer ve aynı okuyucudan geçirir. Ekranda "örnek" rozeti görünür. iOS 26 simülatörü kamera bildirdiği için "Fotoğraf çek" açık; canlı tarama (VisionKit) kapalı ve ekran bunu söylüyor.

## Açık kalanlar

- `REAL_DEVICE_BLOCKED`: canlı tarama, gerçek kamera karesi, gerçek etiketlerde okuma oranı ve süre.
- Gerçek mağaza barkodları (EAN) katalogda yok. Lisanslı katalog bağlanana kadar "katalogda yok" denir (R-004).
- "Fotoğraftan dolaba ekle" (UI28-09) ayrı iş: kendi kıyafetinin fotoğrafından dolap parçası oluşturma. Bu ADR yalnız satın alma/deneme için ürün getirmeyi kapsar.

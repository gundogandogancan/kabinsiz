# ADR-013 — Dünya şehirleri: kişinin şehrindeki ünlü cadde, Apple Look Around ile, kapıdan geçerek

- **Durum:** Kabul edildi (2026-11-04). Yayın öncesi hukuk/şartlar incelemesi `HUMAN_APPROVAL_PENDING`.
- **Kaynak:** Kullanıcı kararı 2026-11-04: "Sadece Barcelona, Galata değil, tüm dünya şehirleri için olmalı. Kişinin konumu neresi ise oranın en meşhur caddesinin fotoğrafı görünmeli." v2.8 §06; D-027 (şehir fotoğrafı ve harita verisi yok); CITADEL (WP15-03, ADR-006).
- **İş paketi:** UI28-05b (dünya caddeleri).

## Bağlam

Kabinsiz'in özgün 3B sokakları yalnız iki şehir için var (ADR-012). Kullanıcı her şehirde, kişinin bulunduğu şehrin en meşhur caddesini istiyor. D-027 internetten şehir fotoğrafı almayı ve izinsiz harita verisi kullanmayı yasaklıyor: telif, kişisel veri (yüzler, plakalar) ve harita lisansı yüzünden. Blender'da her şehri elle üretmek ölçeklenmez.

Uyumlu tek yol, platform sağlayıcısının resmi API'si: **Apple MapKit Look Around**.

- `MKLookAroundSceneRequest` ile sahne istenir, SwiftUI `LookAroundPreview` ile gösterilir.
- Apple görüntüyü kendi sunucusundan, kendi şartları ve bulanıklaştırmasıyla verir. Uygulama görüntüyü kaydetmez, kopyalamaz, işlemez.
- Apple atıf rozeti görünür kalır.

## Karar 1 — Elle yazılmış ünlü cadde kataloğu

`FamousStreetCatalog` (LivingWorld) 36 şehirde birer cadde içerir; hiçbiri kazınmadı, genel bilgiden elle yazıldı. Örnekler: İstanbul İstiklal, Paris Champs-Élysées, Tokyo Omotesandō, New York Fifth Avenue.

- Her girişin alanları: kimlik, şehir, ülke, cadde, caddede bir nokta ve saat dilimi.
- Koordinatlar yaklaşıktır ve `UNVERIFIED` olarak işaretlidir; bir sahne yüklenene kadar doğrulanmış sayılmaz.
- İstanbul ve Barcelona kendi 3B sokaklarına bağlıdır (`ownedScene`).
- "En meşhur cadde" bir editör seçimidir, ölçülmüş bir iddia değildir.

## Karar 2 — Konum yalnız dokununca, yaklaşık, cihazda eşlenir, saklanmaz

"Konumumdaki şehir" düğmesi (`CoarseCityLocator`, UI28-T060):

- Konum izni açılışta değil, yalnız bu düğmeye dokununca istenir (When In Use).
- `kCLLocationAccuracyReduced` ile tek bir konum alınır.
- Konum telefonda en yakın katalog şehrine eşlenir (60 km yarıçap) ve atılır; yalnız şehrin kimliği tutulur.
- Konum asla saklanmaz, loglanmaz, gönderilmez. Statik kaynak taraması bunu dosya bazında zorlar:
  - `CLLocationManager` yalnız bu dosyada kullanılabilir.
  - Bu dosyada `UserDefaults`, `FileManager`, `print(`, `Logger`, `startUpdatingLocation`, tam hassasiyet ve Always izni yasak.
- Yakında katalog şehri yoksa kullanıcıya bunu söyler; şehir listeden seçilebilir.

## Karar 3 — Tek dış istek EG-003, CITADEL kapısından

- Apple'a giden tek şey, seçilen caddenin **katalogdaki sabit noktasıdır**. 4 ondalığa yuvarlanır (`street_coordinate`) ve herkes için aynıdır.
- Cihaz konumu hiçbir zaman gönderilmez.
- `LookAroundProvider` her istekte şunları yapar:
  - `occasionVenue` (OCT-17) modülüne tek kullanımlık `streetImagery.fetch` izni alır.
  - İsteği `CitadelGate.send` ile gönderir.
  - MapKit çağrısı yalnız kapının taşıyıcı kapanışı içinde ve kapının onayladığı noktayla yapılır.
- Bu kural, statik tarama ve UI28-T063 testiyle zorlanır. UI28-T063 yazılırken gerçek bir hata buldu: kapı, sokak amacını sınıflandırma tablosunda tanımıyordu. Bu yüzden her istek `egressBlocked` olacaktı. Düzeltildi.
- Rıza kapsamı `STREET_IMAGERY`. Şehir ve hava sheet'indeki anahtarla kapatılır. Kapatınca uçuştaki iş iptal edilir, yeni istek yapılmaz ve kendi sokağa ya da stüdyoya dönülür (UI28-T064).

## Karar 4 — Ekran gerçekte ne varsa onu söyler

- Fotoğraf varken doğruluk satırı şöyledir: "Temsili 3B giysi · cadde fotoğrafı: Apple · beden uyumunu göstermez". Kendi 3B şehrimiz ya da Blender diye geçmez (UI28-T062).
- Look Around görüntüsü yoksa ya da ağ yoksa bunu bir satırla söyler. Kendi sokak varsa onu, yoksa nötr stüdyoyu gösterir. Benzer bir şehir göstermez.
- Fotoğrafın önünde yağmur çizilmez; ışık gündüz figür ışığıdır. Fotoğraf hava kanıtı değildir.
- Figür fotoğrafın önüne yerleştirilir. Zemin hizası yaklaşıktır; bu bir kompozit, gerçek sahne değil.
- Kendi sokağı olmayan bir şehirde günün planı o şehrin saat dilimiyle yapılır (`timeZoneOverride`, UI28-T061). Hava çipi şehrin adını taşır.

## Sonuçlar ve açık kalanlar

- **Hukuk/şartlar (`HUMAN_APPROVAL_PENDING`):** Apple MapKit şartları ve Look Around görüntüsünün bir kombin uygulamasında arka plan olarak kullanımı yayından önce insan tarafından incelenmeli. Apple Developer Program Lisans Sözleşmesi ve MapKit kullanım kuralları ile atıf gereklilikleri buna dahil. Bu inceleme yapılmadan TestFlight veya App Store'a çıkmaz.
- Simülatörde (iPhone 17, iOS 26.5, 2026-11-04) Paris için Look Around yüklendi: "Paris · Avenue des Champs-Élysées: Apple Look Around". Doğruluk satırı "cadde fotoğrafı: Apple" dedi. Apple Maps logosu ve Look Around rozeti göründü. Kullanılabilirlik ağa ve Apple'ın kapsamına bağlı; UI testi (UI28-T065) iki dürüst sonucu da kabul edip kaydeder.
- **Yakalanan açılış yarışı:** Kapı, saklı rıza okunana kadar kapalı defterle başlar (fail-closed). Cadde isteği o arada çalışınca "Cadde fotoğrafı kapalı" deyip bir daha denemiyordu; kaydedilmiş şehri olan her kullanıcı açılışta bunu görecekti. Çözüm: `AppModel.consentLoaded` olmadan istek yapılmaz ve "kapalı" denmez. Test, rıza kapatılmamışken "kapalı" görürse başarısız olur.
- Rozet ve logo her zaman tam görünmeli. Fotoğrafın alt kenarı alt düğmelerin üstünde biter; simülatörde "Örnek beden" düğmesi rozeti kırpıyordu, düzeltildi.
- Cihazda doğrulanmadı (`REAL_DEVICE_BLOCKED`): konum izni akışı, gerçek konumla eşleme, Look Around yükleme süresi ve bellek.
- Katalog koordinatları sahada doğrulanmadı.

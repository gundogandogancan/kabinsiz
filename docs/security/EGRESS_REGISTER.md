# Egress register (§112.2, §117)

Uygulamanın her ağ yolu burada listelenir. Koddaki allowlist `EgressRoute.registered` (SystemContracts/CitadelGate.swift) bu tabloyla birebir aynı olmalı. `V15-T-SEC-06` testi tabloyla kodu karşılaştırır; ayrıca üçüncü taraf Swift paketi eklenirse test kırılır.

Statik tarama (`StoreAndPrivacyTests.staticEgress`) paket ve app kaynaklarında başka ağ kodu bulursa test kırılır. Tarama ayrıca şunları denetler:
- Uygulama kendi `EgressRoute`'unu kuramaz.
- WeatherKit dosyası `gate.send(` üzerinden gönderir ve içinde tam bir WeatherKit çağrısı vardır.

| ID | Host | Method | Path | Amaç | Dosya | Ne gider | Ne gitmez | Tetik | Rıza | Durum |
|---|---|---|---|---|---|---|---|---|---|---|
| EG-001 | weatherkit.apple.com | GET | /api/v1/weather | WEATHER_FORECAST | `apps/ios/Kabinsiz/Services/AppleWeatherProvider.swift` | `city_center_coordinate`: paketli `CityDirectory` tablosundan, 4 ondalığa yuvarlanmış şehir merkezi. Seyahat dosyasında koordinat yoktur | Cihaz konumu, kimlik, tarih aralığı, dolap, ölçü | Kullanıcının "Apple Weather'dan tahmin al" dokunuşu. İstek sürerken buton kapalıdır | Her dokunuşta tek kullanımlık, 60 saniyelik grant verilir (OCT-16, `weather.fetch`). Profil'deki "Dokununca hava tahmini iste" anahtarı kapalıysa grant verilmez | CODED + kapı testli. Canlı çağrı `BLOCKED_EXTERNAL` (PLA kabul edilmedi) |
| EG-002 | Apple attribution varlıkları (sistem URL'si) | GET | WeatherKit'in döndürdüğü logo/yasal sayfa | Attribution | Aynı dosya, `WeatherAttributionView` | Standart görsel isteği | Kullanıcı verisi | Ekranda Apple Weather verisi varken | WeatherKit kullanım koşulu gereği zorunlu | CODED. Kullanıcı verisi taşımadığı için kapıdan geçmez; sistem ağ envanterinde |
| EG-003 | mapkit.apple.com (MapKit kendi Apple host'larını seçer) | GET | /look-around/scene | STREET_IMAGERY | `apps/ios/Kabinsiz/Services/LookAroundProvider.swift` | `street_coordinate`: paketli `FamousStreetCatalog` tablosundaki caddenin 4 ondalığa yuvarlanmış noktası. O şehri seçen herkes için aynıdır. Sahne gelirse MapKit Look Around görüntü karolarını kendisi indirir; uygulama görüntüyü kaydetmez ve dışa aktarmaz | Cihaz konumu (yalnız cihazda en yakın katalog şehrini seçmek için okunur, sonra atılır), kimlik, dolap, ölçü, avatar | Kullanıcının şehir sheet'inde "Cadde fotoğrafı"nı açması ya da bir dünya şehri seçmesi. Açıkken o şehir için ana ekranın açılması da istektir | Her istek için tek kullanımlık, 60 saniyelik grant (OCT-17, `streetImagery.fetch`). "Cadde fotoğrafı" kapalıysa (`STREET_IMAGERY` REVOKED) grant verilmez ve sahibi olduğumuz 3B sokağa düşülür | CODED + kapı testli. Simülatörde denendi; Apple şartlarının hukuk incelemesi `HUMAN_APPROVAL_PENDING` |
| EG-004 (beklemede) | Ortak sözleşmesindeki tek host (henüz yok) | GET | Ortağın imzalı katalog dosyası + `.sig` | Lisanslı ortak kataloğu (V37-06) | `Packages/KabinsizCore/Sources/ShoppingCopilot/PartnerFeedTransport.swift` (`EphemeralFeedTransport`), doğrulama `PartnerFeedConnector.swift` | Hiçbir kullanıcı verisi: gövdesiz GET; çerez, önbellek, kimlik bilgisi, sorgu dizesi yok; sabit `User-Agent` ve `Accept-Language` | Ölçü, dolap, fotoğraf, avatar, konum, cihaz/uygulama sürümü, dil tercihi | Kullanıcının "kataloğu güncelle" dokunuşu (planlanan) | `authorizeFetch` kancası uygulamada OCT-23 `network.productOnly` tek kullanımlık grant'ini tüketir; kabul ancak pinlenmiş Ed25519 imzası + izinli host + HTTPS + şema + boyut + ürün başına köken/lisans ile | CODED + yerel imzalı akışla testli (`PartnerFeedConnectorTests`, 12 test). `EgressRoute.registered` içinde **yok**; gerçek ortak, sözleşme ve DPA yok → `BLOCKED_EXTERNAL` |

## Kapı sırası (`CitadelGate.send`)

1. `EgressIntent.validate()`. Bildirim eksik veya yanlışsa istek reddedilir (`SCHEMA_INVALID` / `EGRESS_BLOCKED`).
2. Host + method + path + amaç `EgressRoute.registered` listesinde olmalı. Değilse `EGRESS_BLOCKED` (SEC-06).
3. Modül registry'de bu yeteneğe sahip olmalı, grant geçerli olmalı ve rıza `REVOKED` olmamalı. Aksi halde `CAPABILITY_NOT_GRANTED` veya `POLICY_DENIED`.
4. DTO sınıflandırılmış olmalı (`EgressPayload.egressClassification`). Sınıfı yoksa `UNKNOWN_CLASSIFICATION` (SEC-07). Sınıfı bildirimle uyuşmazsa `EGRESS_BLOCKED`.
5. DTO ağa gidecek biçimde serileştirilir. Şunların hepsi sağlanmalı, aksi halde `EGRESS_BLOCKED` (SEC-08):
   - Anahtarlar bildirilen alanlarla birebir aynı.
   - Değerler düz skaler.
   - En fazla 64 ASCII karakter.
   - URL, e-posta veya JSON değil.
6. Transport, yalnız kapının ürettiği `AuthorizedEgress`'i alır ve yalnız onun içindeki kontrol edilmiş değeri gönderir.
7. Cevap geldiğinde rıza bu arada geri alınmışsa sonuç atılır (`discardedAfterRevocation`, §112.3).

Denetim kaydında yalnız amaç, host, alan adları ve sonuç tutulur; değerler kaydedilmez. Kayıt en fazla 200 satırdır.

## Notlar

- Seyahat hedefi kişisel bir bilgi olduğu için istek `LOCAL_PRIVATE` sayılır.
- Demo seyahati hiçbir zaman ağa çıkmaz; hava verisi sentetiktir.
- Plan oluşturulurken hava otomatik istenmez. `AppleWeatherProvider.snapshots` her zaman `NO_DATA` döndürür; canlı veri yalnız dokunuşla çağrılan `fetch` üzerinden gelir.
- `PRODUCT_LOOKUP` için kayıtlı bir rota yok, çünkü lisanslı katalog API'si yok. `ProductLookupRequest` yalnız testlerde kullanılır.
- EG-004: `ShoppingCopilot` paketi `SystemContracts`'a bağımlı değildir, bu yüzden kapı içeri alınmaz, `authorizeFetch` kancasıyla dışarıdan verilir. Statik taramada `PartnerFeedTransport.swift` yalnız `URLSession`/`URLRequest` için muaftır ve tarama dosyanın ephemeral, çerezsiz, gövdesiz, yalnız GET ve yönlendirme reddeden ayarlarını da denetler. Ortak sözleşmesi imzalandığında: `EgressIntent.Purpose`'a feed amacı + `EgressRoute.registered`'a EG-004 eklenir ve `CitadelGate.send` üzerinden geçirilir.
- EG-003'te HTTP çağrısını MapKit yapar; kapı, `MKLookAroundSceneRequest` çağrısını bildirim, rota, grant, rıza ve alan kontrolünden sonra transport kapanışı içinde çalıştırır. `LookAroundPreview` sahne geldikten sonra görüntü karolarını kendisi yükler. Bu karolar kullanıcı verisi taşımaz.
- Konum: `CLLocationManager` yalnız `CoarseCityLocator.swift` içinde, azaltılmış hassasiyetle ve yalnız "Konumumdaki şehir" dokunuşuyla kullanılır. Koordinat bellekte bir kez en yakın katalog şehrini bulmak için kullanılır; ne saklanır ne gönderilir. Saklanan tek şey seçilen şehrin kimliğidir (ör. `FR-PAR`).
- Dinamik ağ yakalama testi yok; bunun için cihaz gerekiyor (`REAL_DEVICE_BLOCKED`).

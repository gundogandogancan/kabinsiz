# Egress register (§112.2, §117)

Her ağ yolu burada. Statik tarama (`StoreAndPrivacyTests.staticEgress`) paket ve app kaynaklarında başka ağ kodu bulursa test kırılır.

| ID | Dosya | Hedef | Ne gider | Ne gitmez | Tetik | Rıza | Durum |
|---|---|---|---|---|---|---|---|
| EG-001 | `apps/ios/Kabinsiz/Services/AppleWeatherProvider.swift` | Apple WeatherKit (sistem framework'ü) | Seyahat şehrinin şehir merkezi: istek anında `CityDirectory.cityCenter` ile paketli tablodan alınır, seyahat dosyasında koordinat yoktur (düzenlenmiş dosya başka nokta gönderemez) | Cihaz konumu, kimlik, tarih aralığı, dolap, ölçü | Kullanıcı "Apple Weather'dan tahmin al" dokunuşu; istek sürerken buton kapalı | Butonun altındaki açıklama; her istekten önce `EgressIntent.validate()` | CODED. Canlı çağrı `BLOCKED_EXTERNAL` (PLA kabul edilmedi) |
| EG-002 | Aynı dosya, `WeatherAttributionView` | Apple'ın attribution logo URL'si ve yasal sayfa | Standart HTTP isteği (görsel) | Kullanıcı verisi | Apple Weather verisi ekrandayken | WeatherKit kullanım koşulu gereği zorunlu | CODED |

Notlar:
- Seyahat hedefi kişisel bir bilgi olduğu için istek `LOCAL_PRIVATE` sayılır; `EgressIntent` bunu yalnız `WEATHER_FORECAST` amacı ve `city_center_coordinate` alanı için açık dokunuşla kabul eder.
- Demo seyahati hiçbir zaman ağa çıkmaz (sentetik hava).
- Plan oluştururken otomatik hava isteği yok; ilk plan `NO_DATA` ile kurulur.
- Statik tarama tam dosya yoluyla istisna tanır ve kod kalıplarına bakar (`import WeatherKit`, ` WeatherKit.`, `WeatherService`, `AsyncImage`, `CLLocationManager`, `CLGeocoder`, `MKLocalSearch`, `WKWebView`, `openURL`, `URLSession`, `URLRequest`, …).
- Dinamik ağ yakalama testi yok (cihaz gerekiyor).

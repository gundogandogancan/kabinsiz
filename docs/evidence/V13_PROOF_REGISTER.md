# Kanıt raporu — v1.3 dilimi (§57 / §74.1 formatı)

Tarih: 2026-11-03 · Makine: Apple M5, macOS 26.4, Xcode 26.6, Swift 6.3.3 · Sürüm durumu: **yerel, yayımlanmamış**

## 1. Ne çalışıyor (kanıtla)

| Kanıt | Komut | Sonuç | Etiket |
|---|---|---|---|
| EV-CORE-01 | `swift test` (Packages/KabinsizCore) | 68/68 geçti | TESTED (macOS) |
| EV-UI-01 | `scripts/check.sh` → `testDemoTripFlow` | geçti | SIMULATOR_ONLY (iPhone 17, iOS 26.5) |
| EV-UI-02 | `scripts/check.sh` → `testScanDecisionCard` | geçti | SIMULATOR_ONLY |
| EV-PERF-01 | T-TRV-064: 500 parça / 14 gün | ~0,2 sn | macOS debug; cihazda ölçülmedi |
| EV-SHOT-01..07 | `docs/evidence/screenshots/SIMULATOR_ONLY-0[1-7]-*.png` | UI testinden dışa aktarıldı | SIMULATOR_ONLY |

## 2. Sentetik / mock olanlar

- Dolap, Barselona demo seyahati, hava (`SYNTHETIC_FIXTURE`), ürün kataloğu (7 ürün) ve beden tabloları: hepsi `SYNTHETIC_DEMO_ONLY`; ekranda "Örnek veri — gerçek değil" etiketiyle.
- Sponsorlu ürün yalnız etiket testidir; gerçek reklam yok.

## 3. Engelli olanlar

| Konu | Durum | Neden |
|---|---|---|
| WeatherKit | BLOCKED_EXTERNAL | Apple geliştirici hesabı/entitlement insan onayı ister |
| Gerçek cihaz testi | REAL_DEVICE_BLOCKED | 3 iPhone çevrimdışı |
| Kamera ile barkod | SPEC_ONLY | P0'da manuel kod girişi |
| Gerçek katalog / partner | BLOCKED_EXTERNAL | Sözleşme ve veri hakkı yok |
| Fit Truth Lab | SPEC_ONLY | Gerçek gönüllü verisi yok; metrik üretilmedi |
| TestFlight / App Store | BLOCKED (insan onayı) | |

## 4. Bilinen açıklar (UNKNOWN / test edilmedi)

- `AppModel` için birim testi yok: okuma hatası koruması (#3), sıralı kayıt (#11), bayat onay (#4) yalnız kod incelemesi + UI akışıyla doğrulandı.
- Wizard (kıyafet kuralı #10), FitFeedbackView ve ağırlık girişi alert'i için UI testi yok.
- VoiceOver / Dynamic Type manuel denetimi yapılmadı.
- Dinamik ağ testi yok; egress kontrolü statik kaynak taraması.

## 5. Bağımsız review

AG-12 review: 15 bulgu → bkz. `docs/product/TRACEABILITY.md` "Bağımsız review" tablosu. Ekran görüntüsü incelemesinde 16. bir hata bulundu (kilitli parça diğer günlerde sınırsız tekrar ediliyordu: bir gömlek 5 gün). Düzeltildi; regresyon testi eski mantıkta kırmızı, yenide yeşil.

# Traceability — REQ → kod → test (2026-11-03)

Durum sözlüğü (§74.1): `SPEC_ONLY | CODED | TESTED | DEVICE_VERIFIED | USER_VALIDATED | LIVE_PARTNER | BLOCKED`.
Bu oturumda en yüksek ulaşılan seviye **TESTED** (macOS `swift test` + iOS 26.5 Simulator UI testi). `DEVICE_VERIFIED` yok.

## v1.2 Travel

| REQ / WP | Kod | Testler | Durum |
|---|---|---|---|
| REQ-TRV-001..005 wizard, tarih, saat dilimi, yaşam döngüsü (TRV-03/04) | `TravelEngine/LocalDate.swift`, `CityDirectory.swift`, `TripModels.swift`, `apps/ios/.../TripWizardView.swift` | T-TRV-003, 004, 005, 006, 007, 008, 009; lifecycle; manual TZ | TESTED (birim). Wizard UI'ı elle/otomatik test edilmedi, demo yolu UI testli |
| REQ-TRV-006..010 hava evidence, NO_DATA, stale (TRV-06) | `Weather.swift` | T-TRV-018, 019, 021, 025, 030 | TESTED. WeatherKit `BLOCKED_EXTERNAL` |
| REQ-TRV-011..016 aday kombin, gerekçe, kilit, swap (TRV-07/10) | `OutfitCandidates.swift`, `TripPlanner.swift`, `TripSummaryView.swift` | T-TRV-042, 046, 058, 059; dinner formality | TESTED |
| REQ-TRV-017..026 kapsül, sahip olunan önce, ağırlık, valiz (TRV-08/09) | `CapsuleOptimizer.swift`, `PackingList.swift`, `SuitcaseView.swift` | T-TRV-002, 043, 044, 047, 048, 049, 053, 054, 056, 061, 065, 066, 064 (perf) | TESTED |
| REQ-TRV-027..031 venue/kültür | yalnız kullanıcının yazdığı dress code alanı | — | SPEC_ONLY (G-TRV-CULTURE fallback) |
| REQ-TRV-032..037 yerel veri, silme, egress | `LocalStore.swift`, `AppModel.deleteTrip/deleteAllData` | T-TRV-011, 013 (dosya düzeyi), 087 (statik egress: paket + app kaynakları); UI testDemoTripFlow seyahat silme → dolap duruyor | TESTED. Dinamik ağ testi yok. `AppModel` birim testi yok (app test hedefi yok) |
| REQ-TRV-043 plan diff + onay (TRV-12/13) | `PlanDiff.swift`, `ReplanCard` | T-TRV-062; UI testDemoTripFlow (kilit onaydan sonra korunuyor) | TESTED (sentetik hava). Bayat öneri onayı `AppModel.approveReplan` içinde revizyonla engelleniyor, birim testi yok (CODED) |
| TRV-11 WeatherKit, TRV-14 3D, TRV-15 çok duraklı, TRV-16 retail | — | — | BLOCKED / SPEC_ONLY |

## v1.3

| WP | Kod | Testler | Durum |
|---|---|---|---|
| V13-WP02 Fit Passport şema + kalıcılık | `FitPassport/FitPassport.swift`, `AppModel` | T-V13-016, 017 (yalnız model düzeyi), 019, 020; store roundtrip | TESTED |
| V13-WP03 giydim/uydu/uymadı girişi | `FitFeedbackView` | — (UI testi yok) | CODED |
| V13-WP04 tek kart karar + abstain | `DecisionComposer.swift`, `ScanView.swift` | T-V13-001, 003, 004, 006, 007, 009/052, 034; UI testScanDecisionCard | TESTED (manuel kod girişi; kamera yok) |
| V13-WP05 dolabımda var mı | `ShoppingGuard.swift` | T-V13-008, 045, 046 | TESTED |
| Fit kapsam kuralları | `SizeAdvisor.swift` | T-V13-013, 014, 015, 018 (statik) | TESTED |
| V13-WP06 Fit Truth Lab | — | — | SPEC_ONLY: gerçek gönüllü verisi yok, metrik üretilmedi |
| V13-WP07 kapsayıcılık / a11y denetimi | Etiketler, 44pt hedefler, ikon+metin durumları | — | CODED. VoiceOver/Dynamic Type manuel testi yapılmadı |
| V13-WP08..16 | — | — | SPEC_ONLY / BLOCKED |

## Bağımsız review (AG-12) sonuçları — 2026-11-03

15 bulgu. Hepsi ele alındı; kalan açıklar aşağıda yazılı.

| # | Bulgu | Düzeltme | Kanıt |
|---|---|---|---|
| 1 | Limit aşan kilit tüm açık slotları boşaltıyor | Kilit yalnız kendi günleri kadar limit aşabilir; aday yoksa en düşük maliyetli aday + açık "gap" | `conflictingLock`, `lockDoesNotLiftLimitElsewhere` (eski mantıkta kırmızı olduğu doğrulandı) |
| 2 | Swap sonrası valizdeki satır düşüyor | Builder, planın kullanmadığı ama valize konmuş satırları tutar; "Plan artık kullanmıyor" etiketi | `swapKeepsPacked` |
| 3 | `load()` ilk hatada duruyor, sonraki kayıt okunmamış dosyayı ezer | Her koleksiyon ayrı yüklenir; okunamayanlara yazma engellenir | CODED (app birim testi yok) |
| 4 | Replan onayı eski anlık görüntüyü geri yüklüyor | Bekleyen öneri hava verisini tutar; onayda güncel plana yeniden uygulanır; revizyon değiştiyse öneri yenilenir | CODED + UI testi (kilit korunuyor) |
| 5 | Önbellek/mevsimsel hava canlı gibi görünüyor | `chipText` etiket öneki; ekranda gösterim anında yeniden yaşlandırma + kaynak satırı | `labelledNumbers`, `displayReAges` |
| 6 | Çeşitlilik ayarı sahte boşluk üretiyor | Çeşitlilik için onarım döngüsü atlanıyor | `varietyNoFalseGaps` |
| 7 | "likely" çelişen kaydı yok sayıyor | Çelişen kayıt veya birden fazla tam beden → abstain | `contradiction` (×2), `twoFittingSizes` |
| 8 | Revizyonlar farklı ürünler arasında karşılaştırılıyor | Bayatlık yalnız aynı `productModelID` içinde | `revisionScopedToModel`, T-V13-015 güncellendi |
| 9 | Ağırlık uyarısı erişilemez | Sahip olunan iç çamaşırı ağırlığı; valiz ekranında ağırlık girişi; kullanıcı ağırlığı replan'da korunur | `weightSurvivesReplan`, T-TRV-054 |
| 10 | İş kıyafet kuralı kayboluyor | Kural akşam bloğuna değil etkinlik türüne bağlı | CODED (wizard UI testi yok) |
| 11 | Kayıtlar araya girebiliyor | Kayıtlar zincirlenmiş Task ile sırayla | CODED |
| 12 | T-TRV-062 `?? true` | `#require(...).isPacked == true` | test |
| 13 | Kolay vakalar | Yukarıdaki zor vakalar eklendi | 68 test |
| 14 | T-TRV-013 / T-V13-017 / 087 app kodunu sınamıyor | 087 app kaynaklarını da tarıyor; 013 UI testine eklendi; 017 dürüstçe "model düzeyi" | bu tablo |
| 15 | UI testi az şey doğruluyor | Kilit zorunlu, onay sonrası kilit, paketleme durumu, silme → dolap | testDemoTripFlow |

# V19 gerçeklik ve boşluk raporu (V21-00)

Tarih: 2026-11-03 · Denetlenen commit: `f5caa71` (`main` = `origin/main`) · Kuyruk satırı: `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md` §4 sıra 6 (V21-00 = R17-00, R18-WP01, WP19-00, UI20-WP01, LM21-WP01)
Kaynak sorular: Ek v1.9 V19-20 (`V19-Q01..Q40`), Ek v2.0 §16 (12 denetim sorusu), Ek v2.1 LM21-15 (25 denetim sorusu). Teslim listesi: V19-21.

Bu dosya kanıt değil, kanıt dizinidir. Kod veya test çalıştırma sonucu olmayan hiçbir şey "yapıldı" diye yazılmadı.

## 0. Etiketler ve kurallar

| Etiket | Anlamı |
|---|---|
| `EVIDENCE` | `f5caa71`'deki bir dosya/satır veya bu denetimde koşulan komut çıktısı gösteriliyor (`path:line`). "Yok" cevapları da `EVIDENCE` olabilir: `grep` sonucu sıfır ise bu bir ölçümdür |
| `ASSUMPTION` | Belgelerden ve koddan türetilmiş öneri/çıkarım; ölçülmedi |
| `UNKNOWN` | Repoda ve erişilebilir kaynakta cevabı yok |
| `BLOCKED` | Cevap ancak dış engel kalkınca verilebilir: `REAL_DEVICE_BLOCKED`, `BLOCKED_EXTERNAL` (hesap, sözleşme, lisans, para), `HUMAN_REVIEW_PENDING` |

Ek etiket: `SIMULATOR_ONLY` = kanıt yalnız iPhone 17 simülatöründe (iOS 26.5) üretildi; cihaz kanıtı değildir.

### 0.1 Bu denetimde koşulan komutlar

| Komut | Sonuç |
|---|---|
| `cd Packages/KabinsizCore && swift test` | Çıkış kodu 0 · "Test run with **194 tests in 13 suites** passed after 8.813 seconds" (macOS, Apple M5) |
| `git rev-parse HEAD origin/main` | ikisi de `f5caa71ab7b7ffbe9dda40af753ed5cc8c0d1364` |
| `git ls-remote --heads origin` | yalnız `refs/heads/main` |
| `gh pr list --state open` | boş (açık PR yok) |
| `git status --short` | HEAD temiz değil: başka bir ajanın V21-01 işi çalışma ağacında (bkz. Q01) |
| `xcrun devicectl list devices` | 3 eşleşmiş iPhone, hepsi `unavailable`: iPhone 16 Pro (iOS 26.5), iPhone 14 Pro Max (26.6), iPhone 13 Pro Max (26.2.1) |
| `grep -rnE "thermalState\|isLowPowerModeEnabled\|AVCapture\|VNDetect\|DataScanner\|VisionKit\|import Vision\|RealityKit\|SceneKit\|PhotosPicker\|PHPicker\|URLSession\|import Network\|StyleDNA\|astrolog\|numerolog\|liveMirror\|Decart\|NSCameraUsage"` (Sources, Tests, apps/ios/Kabinsiz, UITests, project.yml) | Tek eşleşme: `Packages/KabinsizCore/Tests/KabinsizCoreTests/StoreAndPrivacyTests.swift:91` (yasaklı ağ API listesinin kendisi). Kamera, Vision, RealityKit, fotoğraf, termal, Style DNA, sembolik katman ve bulut ayna kodu **yok** |

UI testleri bu denetimde yeniden koşulmadı. Son koşu: `docs/evidence/WP15-05.yaml` (`ui_test_exit_code: 0`, 4 test, `SIMULATOR_ONLY`).

### 0.2 Eklerin eski bulguları — durum güncellemesi

Ek v1.6 §1.2 ve Ek v1.9 V19-01 `77e00ff`'i, Ek v2.1 LM21-07 `25897e7`'yi denetledi.

| Eski bulgu | `f5caa71` durumu | Kanıt |
|---|---|---|
| DATA-01 / V19-01 `LocalStore` şifresiz, vault yok | **KAPANDI** (TESTED, SIMULATOR_ONLY) | `Packages/KabinsizCore/Sources/Vault/VaultModel.swift:160-165` (AES-GCM), `Vault/KeyStore.swift:64` (Keychain KEK), `Vault/LegacyImport.swift:18` (göç); `docs/evidence/WP15-04.yaml` |
| V19-01 `EgressIntent.validate()` yalnız beyan | **KAPANDI (statik + runtime kapı)**; dinamik paket yakalama yok | `SystemContracts/CitadelGate.swift:157-200`, `:39-41`; `Tests/KabinsizCoreTests/StoreAndPrivacyTests.swift:78-91`; `docs/evidence/WP15-03.yaml` |
| V19-01 `CLAUDE.md` v1.5'i işaret ediyor | **KAPANDI** | `CLAUDE.md:7` (kanonik v2.1) |
| V19-01 `MyModelView` "3D yok", iki manuel ölçü | **KISMEN**: 5 parametreli gövde + kaydırıcı + revizyon + undo + kasa; önizleme 2D | `BodyGeometry/BodyProfile.swift:5-10`, `apps/ios/Kabinsiz/Features/Profile/BodyStudioView.swift:250`; `docs/evidence/WP15-05.yaml` |
| V19-01 Octopus yalnız sözleşme | **KISMEN**: gerçek koordinatör var, yalnız gövde yolculuğunda kullanılıyor | `Octopus/OctopusCoordinator.swift:14,45`; `apps/ios/Kabinsiz/App/AppModel.swift:243` |
| FIT-01..04, SKU-01, MAT-01, TMP-01, VIZ-01 (3D), SCAN-01, QA-01, OPS-01 | **AÇIK** | Aşağıda Q09–Q15, Q03, Q33, Q37 |

---

## 1. V19-Q01..Q40 (Ek v1.9 V19-20)

"Sıra #" = `V21_QUEUE_AND_CONFLICT_MAP.md` §4 satırı.

### 1.1 Ürün doğruluğu

| ID | Soru (kısa) | Etiket | Cevap ve kanıt | Kapatan iş (sıra #) |
|---|---|---|---|---|
| V19-Q01 | HEAD, working tree, PR/branch, test çıkış kodu | `EVIDENCE` | HEAD `f5caa71` = `origin/main`; tek dal `main`; açık PR yok (§0.1). `swift test` çıkış 0, 194 test / 13 suite. UI: 4 test (`apps/ios/KabinsizUITests/AcceptanceDemoUITests.swift:7,61,89,132`), son koşu çıkış 0 (`docs/evidence/WP15-05.yaml`, `SIMULATOR_ONLY`). **Working tree temiz değil:** `docs/DECISION_REGISTER.md`, `docs/audit/V21_QUEUE_AND_CONFLICT_MAP.md`, `docs/security/THREAT_MODEL.md` değişik; `docs/adr/ADR-006..008` izlenmiyor (eşzamanlı V21-01 işi); denetim sonunda ayrıca WP15-06 taslağı belirdi (`Octopus/DeviceGovernor.swift`, `DeviceSignals.swift`, `BackgroundWindow.swift`, `EphemeralArea.swift`, `Tests/OctopusTests/DeviceGovernorTests.swift` izlenmiyor; `OctopusCoordinator.swift`, `ResourceGovernor.swift` değişik). Commit edilmeden hiçbiri kanıt sayılmaz; bu rapor yalnız `f5caa71`'i cevaplar. Cihaz: 3 eşleşmiş iPhone, hepsi çevrimdışı | — |
| V19-Q02 | v1.8/v1.9 ↔ `CLAUDE.md` çelişkisi | `EVIDENCE` | `CLAUDE.md:7` artık v2.1'i kanon sayıyor; v1.5-kanon çelişkisi kapandı. Kalan çatışmalar C-9..C-23 (`V21_QUEUE_AND_CONFLICT_MAP.md` §3). HEAD'de D-003 hâlâ `GEÇİCİ` ("3D önizleme P0 dışı", `git show HEAD:docs/DECISION_REGISTER.md` satır 12) ve v1.6 VIZ-01 / v1.7 R17-06 / WP19-07 ile çelişiyor. Kapatan ADR-007 yalnız çalışma ağacında | V21-01 (7) |
| V19-Q03 | Kamera gerçekten açılıyor mu | `EVIDENCE` | Hayır. `apps/ios/Kabinsiz/Features/Scan/ScanView.swift:21` "Kamera ile tarama bu sürümde yok"; giriş `TextField` (`ScanView.swift:23`). `AVCapture`/`VNDetect`/`DataScanner` sıfır eşleşme; `Info.plist`'te `NSCameraUsageDescription` yok. D-002 `GEÇİCİ` | R17-03 (18); cihaz `REAL_DEVICE_BLOCKED` |
| V19-Q04 | Offline/online kimlik kesinlik seviyeleri | `EVIDENCE` | Yalnız offline, yerel sentetik katalog. Sonuçlar `found / ambiguous / notFound / invalidInput` (`ShoppingCopilot/Catalog.swift:29-37`); "benzer ürün" ikamesi yok (`Catalog.swift:33`, test `ShoppingAndFitTests.swift:27`). Online yol yok: tek kayıtlı rota hava (`CitadelGate.swift:39-41`); `ProductLookupRequest` yalnız testte (`CitadelGate.swift:287`, `docs/security/EGRESS_REGISTER.md` Notlar). `EXACT_VERIFIED / CONFIRMED_BY_USER / CANDIDATE` seviyeleri yok | R17-03 (18), R17-02 (10) |
| V19-Q05 | Feed yokken "tüm markalarda gerçek kumaş" nasıl engelleniyor | `EVIDENCE` | Her iddia kaynak taşıyor: `MaterialClaim.source: Provenance` (`DomainContracts/Garment.swift:73-76`); `unknown` kaynak iddia sayılmaz (`Garment.swift:132-134`); kumaş yoksa kartta "Eksik bilgi: Kumaş bilgisi" (`DecisionComposer.swift:38`); tüm katalog `SYNTHETIC_DEMO_ONLY` ve kartta rozet (`DecisionComposer.swift:53`). `EvidenceRecord.isDisplayableAsVerified` lisanssız "doğrulandı"yı engelliyor (`SystemContracts/EvidenceRecord.swift:87`, test `RegistryAndPolicyTests.swift:163`) **ama karar kartı bu sözleşmeyi kullanmıyor**: `ShoppingDecisionCard` `DecisionEnvelope`'a sarılmıyor (`DecisionComposer.swift:7-18`) | R17-02 (10), R18-WP03 (11) |
| V19-Q06 | GTIN / SKU / styleCode / renk-beden varyantı / feed revizyonu tipleri | `EVIDENCE` | Ayrım zayıf: `code` (varyant), `modelCode` (model), `catalogRevision: Int` (`Catalog.swift:8-11,20`). GTIN alanı katalogda yok (yalnız `ProductLookupRequest.gtin`, `CitadelGate.swift:290`); beden varyantı, styleCode, GTIN check digit, Digital Link yok. `ProductIdentityV1` (v1.7 §4) `SPEC_ONLY` | R17-02 (10) |
| V19-Q07 | GS1 erişimi, limit, lisans, cache hakkı | `BLOCKED` | Doğrulanmadı; hesap/sözleşme gerektirir (`BLOCKED_EXTERNAL`). Repoda GS1 kodu yok | R17-03 dış kısım; NEEDS_USER_ACTION §5 |
| V19-Q08 | Marka verisi çelişince kim kazanır, nasıl loglanır | `EVIDENCE` | Mekanizma yok. `EvidenceRecord` kaynak türü/lisans/TTL/tombstone alanlarını taşıyor (`EvidenceRecord.swift:10-37`) ama çözücü, `CONFLICTING_SOURCES` durumu veya çatışma günlüğü yok (grep 0) | R18-WP03 (11) |
| V19-Q09 | Hedef beden ölçüsü ↔ bitmiş giysi ölçüsü ayrımı | `EVIDENCE` | Ayrılmıyor. `SizeChart.Row` yalnız vücut aralığı `chestCm`, `waistCm` (`FitPassport/SizeAdvisor.swift:6-10`); bitmiş ölçü, ease, tolerans, esneme tipi yok (v1.6 FIT-02 açık) | R17-02 (10) → R17-05 (15) |
| V19-Q10 | Yanlış kesin beden: falsification, abstain, kalibrasyon | `EVIDENCE` | Abstain var ve testli: tablo yok (`SizeAdvisor.swift:121-123`, test `ShoppingAndFitTests.swift:44`), çelişen kayıt (`SizeAdvisor.swift:108-110`, test `:127`), iki farklı tam beden (`:111-112`, test `:137`). Yüzde yok (`SizeAdvisor.swift:34`). **Açık hata (v1.6 FIT-04, canlı):** `chartMatch` satırda olmayan ölçüyü atlıyor (`SizeAdvisor.swift:133-135`); paketli sentetik tabloda üstlerin satırları yalnız göğüs, pantolonunki yalnız bel içeriyor → göğüs+bel girmiş kullanıcıya tek ölçüden tam "Ölçülerine göre tabloda M" çıkıyor, eksik bölge söylenmiyor. Sentetik etiketli olduğu için gerçek kullanıcıya gerçek iddia değil, ama `STOP_THE_LINE` sınıfı ("yanıltıcı beden iddiası"). **Açık (v1.6 FIT-03):** aynı marka+kategoride başka modelin iki "tam" kaydı yeni modele `likely` veriyor ve test bunu doğru sayıyor (`Tests/KabinsizCoreTests/ShoppingAndFitTests.swift:119-125`, `KB-JKT-01` geçmişi → `KB-JKT-09` için `likely L`); ADR-005 kararı ile v1.6/V19-01 çelişiyor. Kalibrasyon / ECE yok (gerçek veri yok) | R17-05 (15); bkz. §6 öneri |
| V19-Q11 | Kalça/omuz/kol ve deneyimler hangi kodda | `EVIDENCE` | Gövde profilinde boy, omuz, göğüs, bel, kalça var (`BodyGeometry/BodyProfile.swift:5-10`); kol, iç bacak, uyluk yok. Beden önerisi yalnız göğüs+bel kullanıyor (`apps/ios/Kabinsiz/App/AppModel.swift:65-67`, `SizeAdvisor.swift:24-27`). `FitRegion` (omuz…uyluk) yalnız deneme kaydında (`FitPassport.swift:17-18,46`), öneriye girmiyor | R17-05 (15) |
| V19-Q12 | Lif %, kalınlık, esneklik fotoğraftan uyduruluyor mu | `EVIDENCE` | Uydurulmuyor, çünkü fotoğraf girişi hiç yok (`PhotosPicker` grep 0; dolap boş durumu "Fotoğraf izni gerekmez", `Features/Wardrobe/WardrobeView.swift:12`). Lif %, gramaj, örgü modeli de yok: yalnız 4 boolean iddia (`Garment.swift:74`) | R17-04 (16) |
| V19-Q13 | 30 °C yıkama ↔ 30 °C hava tip ayrımı | `EVIDENCE` | Bakım/yıkama tipi hiç yok; hava `lowC/highC: Double?` (`TravelEngine/Weather.swift:29-30`). Çakışma bugün oluşamıyor; R17-04 bakım etiketi eklerken ayrı tip (`WashCareTemperature` ≠ hava) zorunlu, test `R17-MAT`, `V19-T` "30° wash confusion" | R17-04 (16) |
| V19-Q14 | Konfor tahmini hangi güven kademesi | `EVIDENCE` | Konfor modeli yok. Tek kural sabit eşik `low <= 15` (`Weather.swift:77-79`), seyahat planında dış katman tetikliyor (`TravelEngine/OutfitCandidates.swift:95`). Kademe etiketi yok (v1.6 TMP-01 açık) | R17-09 (17) |
| V19-Q15 | 3D mesh + kaydırıcı birleşti mi | `EVIDENCE` | Hayır, 3D mesh yok. Kaydırıcı → revizyon → **2D** ön siluet → kasaya kayıt zinciri çalışıyor ve testli (`Octopus/BodyJourney.swift:149`, `BodyGeometry/Silhouette.swift:4-5`, `BodyStudioView.swift:250`; testler `OctopusTests/BodyJourneyTests.swift:13-470`; UI `AcceptanceDemoUITests.swift:132`). `SIMULATOR_ONLY` | WP15-07/08 (9) |
| V19-Q16 | Ürün asset'i hangi varyanta ait, lisanslı mı | `EVIDENCE` | Ürün asset'i yok; kart her zaman `.flat2D` (`DecisionComposer.swift:47`), eksik bilgi "Ürüne özel 3D görünüm" (`:39`). Gerçek asset `BLOCKED_EXTERNAL` (marka CAD/foto hakkı) | WP19-08 (26); R17-08 dış |
| V19-Q17 | Logo/etiket/dikiş/doku yanlış üretim testi | `EVIDENCE` | Yok (grep: logo/texture testi 0). Üretilecek görsel de yok | WP19-08 (26) |
| V19-Q18 | VTON ↔ fiziksel fit UI'da neden ayrı | `EVIDENCE` | VTON yok. Kart görünüm kademesini ayrı satırda "2D kart (3D yok)" diye gösteriyor (`DomainContracts/Evidence.swift:19`, `ScanView.swift:114`); beden satırı ayrı (`DecisionComposer.swift:28-31`). Ayrımın gelecekteki kuralı ADR-008 madde 4 (çalışma ağacında) | LM21-WP09 (25) |

### 1.2 Stilist ve kişi anlayışı

| ID | Soru (kısa) | Etiket | Cevap ve kanıt | Kapatan iş (sıra #) |
|---|---|---|---|---|
| V19-Q19 | Kombin uyumu yalnız renk+kategori mi | `EVIDENCE` | Evet, ve biçimsellik: alışverişte tamamlayıcı kategori + biçimsellik örtüşmesi + nötr renk önce (`ShoppingCopilot/ShoppingGuard.swift:33-56`); seyahatte biçimsellik + hava + yürüyüş konforu, puan `neutralShare*2 - gaps*5` (`OutfitCandidates.swift:90,143`). Siluet, doku, oran, konfor vektörü yok | WP19-10 (21) |
| V19-Q20 | Style DNA 12 eksen sözleşmesi, unut/override | `EVIDENCE` | Yok (`StyleDNA` grep 0) | WP19-09 (20) |
| V19-Q21 | Klasik/yaratıcı/cesur gerçekten farklı mı | `EVIDENCE` | Üç varyant üreticisi yok. Seyahat planı slot başına aday üretiyor, stil varyantı değil (`OutfitCandidates.swift:89-146`) | WP19-10 (21) |
| V19-Q22 | Ten tonu/renk çıkarımı ne zaman yapılmaz, kontrol | `EVIDENCE` | Hiç yapılmıyor: fotoğraf yok, renk kullanıcının yazdığı `colorName` dizgesi (`Garment.swift:90`). `SensitiveAttributeGuard` kökleri ten/cilt tonu içermiyor (`SystemContracts/UntrustedInput.swift:37-42`) → Style DNA öncesi eklenmeli | WP19-09 (20) |
| V19-Q23 | Hangi bağlam kesin beyan, hangisi çıkarım | `EVIDENCE` | Hepsi beyan: etkinlik türü/biçimsellik/dress code kullanıcıdan (`TravelEngine/TripModels.swift:84,91,97`); hava ya `NO_DATA` ya etiketli fixture (`Weather.swift:116-137`); çıkarım yapan modül yok (registry'de ML modeli yok, test `RegistryAndPolicyTests.swift:76`) | — |
| V19-Q24 | "Yakışır" için insan stilist A/B | `BLOCKED` | Kurulmadı; insan paneli ve rızalı katılımcı gerekir (`HUMAN_REVIEW_PENDING`, V19-08.4) | WP19-12 (dış) |
| V19-Q25 | Ruh hali/kişilik/kültür/etnisite/din fotoğraftan çıkarılıyor mu | `EVIDENCE` | Hayır; fotoğraf işleme yok. Din/etnik/sağlık/biyometrik anahtarları şema ve kasa sınırında reddediliyor (`UntrustedInput.swift:37-42`, `Vault/Vault.swift:145`; testler `CitadelGateTests.swift:301`, `VaultTests.swift:314`). Boşluk: kök listesinde `mood`, `personality`, `culture`, `skin` yok | WP19-09 (20) öncesi |
| V19-Q26 | Numeroloji/astroloji varsayılan OFF mu | `EVIDENCE` | Özellik yok (grep 0), yani kapalı. "Öneride kullanım gösterimi" henüz yok | WP19-14 (29) |
| V19-Q27 | "Bunu unut" geri alınabiliyor mu | `EVIDENCE` | Fit Passport için evet: kayıt silme/düzenleme sonucu sıfırdan hesaplatıyor (`FitPassport/FitPassport.swift:108-118`), öğrenme kapatma ve marka hariç tutma (`:90-93`); testler `ShoppingAndFitTests.swift:147,163` (T-V13-016/017/020). Embedding/öğrenen model yok | WP19-09 (20) |
| V19-Q28 | Yerel ranker eski tavsiyeden iyi mi; ablation | `BLOCKED` | Öğrenen ranker yok; kıyas için gerçek tercih verisi ve insan paneli yok | WP19-10 (21), WP19-12 (dış) |

### 1.3 Entegrasyon, güvenlik, performans, ticari

| ID | Soru (kısa) | Etiket | Cevap ve kanıt | Kapatan iş (sıra #) |
|---|---|---|---|---|
| V19-Q29 | Octopus gerçek scheduler mı | `EVIDENCE` | Kısmen. Gerçek actor koordinatör: DAG, governor grant, deadline/fallback, circuit breaker, latest-wins, coalescing (`Octopus/OctopusCoordinator.swift:14-276`, `Octopus/ResourceGovernor.swift:23-82`; testler `OctopusTests/CoordinatorTests.swift:13-358`). Uygulamada **yalnız gövde stüdyosu** kullanıyor (`AppModel.swift:243`). Tarama kartı koordinatörsüz (`ScanView.swift:71` → `DecisionComposer.compose`), seyahat de (`AppModel.swift:383`). Registry 24 OCT kimliğinden 13'ünü kaydediyor (`SystemContracts/ModuleRegistry.swift:161`, `docs/system/AGENT_REGISTRY.yaml`) | R17-02/R17-03 (10, 18); WP15-09..14 (35) |
| V19-Q30 | `EgressIntent` tüm ağ yollarında mı | `EVIDENCE` | Statik olarak evet: paket ve app kaynaklarında `URLSession/Network/NWConnection/CFNetwork/URLRequest` yok (`StoreAndPrivacyTests.swift:78-91`); tek rota EG-001 (`CitadelGate.swift:39-41`); kod allowlist = belge (`CitadelGateTests.swift:124`); kapı sırası `CitadelGate.swift:157-200`. İstisna: EG-002 WeatherKit attribution kapıdan geçmez (kullanıcı verisi taşımaz, `EGRESS_REGISTER.md`). Dinamik paket yakalama yok → `REAL_DEVICE_BLOCKED` | WP15-18 (14); cihaz |
| V19-Q31 | Vault CryptoKit/Keychain + migration kodlu/testli mi | `EVIDENCE` | Evet. AES-256-GCM (`Vault/VaultModel.swift:160-165`), KEK Keychain `WhenUnlocked` (`Vault/KeyStore.swift:64`, D-008), alan DEK'leri, tombstone, rotasyon (`Vault/Vault.swift:228`), düz metin göçü doğrula-sonra-sil (`Vault/LegacyImport.swift:18`); testler `SecurityTests/VaultTests.swift:38-389` (CRY-01..05, 10, SEC-10). Simülatör Keychain'i UI testte (`AcceptanceDemoUITests.swift:89`). Açık: CRY-06 kilit durumu `REAL_DEVICE_BLOCKED`; kriptograf incelemesi `HUMAN_REVIEW_PENDING`; R1–R7 (`docs/security/THREAT_MODEL.md` HEAD) | WP15-18 (14); dış |
| V19-Q32 | Kritik termalde ne duruyor | `EVIDENCE` | Hiçbir şey OS sinyaliyle durmuyor: `thermalState` / `isLowPowerModeEnabled` grep 0. Kademe tablosu var (`SystemContracts/DeviceBudget.swift:16-52`: `survival` → yalnız P0, ağ yok, 2D) ama onu seçen sinyal yok (`ResourceGovernor.swift:12-13` "WP15-06 feeds it"). Çalışma ağacında commit edilmemiş bir WP15-06 taslağı var (Q01); commit + kanıt YAML'ı gelince bu satır yeniden denetlenmeli | WP15-06 (8) |
| V19-Q33 | İlk kart / onaylı ürün / 3D için cihaz p95 | `BLOCKED` | Yok: tüm kanıt dosyalarında `benchmarks: []` (`docs/evidence/WP15-02..05.yaml`). Registry `deadlineMs` hedef, ölçüm değil (D-013) | WP19-13 (32); `REAL_DEVICE_BLOCKED` |
| V19-Q34 | iPhone testi yoksa hangi gate BLOCKED, hangi iddia yasak | `EVIDENCE` | BLOCKED: v1.7 Gate E (perf) ve F (gerçek fit); v1.6 §13 dikey dilim; V18-SON `DONE`; LM21-16 ilk ispat; CRY-06; dinamik egress (`WP15-03.yaml` `blocked_reasons`); UI20-T-023. Yasak iddialar: "saniyesinde", "cihazda doğrulandı", "VoiceOver tam geçti" (`WP15-05.yaml` `partial`), "canlı ayna yaptık", "gerçek mağaza doğrulandı" (LM21-00.1) | — |
| V19-Q35 | Kullanıcı kısıtı ↔ sponsor/affiliate ayrımı | `EVIDENCE` | Sponsor yalnız etiket; beden ve dolap sponsordan önce ve ondan bağımsız hesaplanıyor (`DecisionComposer.swift:15-16,27-34,52`); test `ShoppingAndFitTests.swift:65` (T-V13-009/052). Affiliate/organik ranker yok | R18-WP04/05 (19); canlı gelir `BLOCKED_EXTERNAL` |
| V19-Q36 | Marka/merchant/logo/foto hakkı | `BLOCKED` | Hiçbiri yok. Katalog 7 ürün, hepsi `SYNTHETIC_DEMO_ONLY` (`ShoppingCopilot/Resources/SyntheticCatalog.json`; R-004 `BLOCKED_EXTERNAL`) | R17-07 dış |
| V19-Q37 | Model/kod/ağırlık lisansı, SBOM | `EVIDENCE` | Üçüncü taraf Swift paketi yok (`Packages/KabinsizCore/Package.swift` `.package(` 0; test `CitadelGateTests.swift:124` paket eklenirse kırılır); ML modeli/ağırlık yok (`RegistryAndPolicyTests.swift:76`). SBOM dosyası ve CI yok (`.github/` yok) | WP19-16 / R17-12 (34) |
| V19-Q38 | İnsan uzman yokken hangi özellikler sınırlı kalmalı | `ASSUMPTION` | Belge kurallarından: (1) beden `likely` ve tablo eşleşmesi "tavsiye" değil "kayıt/tablo bilgisi" diliyle; (2) "yakışır/en iyi" stil dili yok, yalnız gerekçe; (3) termal konfor yalnız "koşullu"; (4) logo/doku fidelity iddiası yok; (5) Fit Truth Lab metriği yayımlanmaz. Kaynak V19-08.4, V19-19.2, v1.7 Gate F | WP19-12 (dış) |
| V19-Q39 | En pahalı 3 risk, en ucuz falsification PoC | `ASSUMPTION` | (1) **Gerçek ürün verisi/hakkı** (her şey sentetik) — PoC: tek lisanslı ürün ailesi için `ProductPhysicalSpecV1` doldurup abstain oranını ölçmek, partner olmadan yapılamaz; ucuz ara adım: kullanıcının kendi giysisinin etiketini `USER_ENTERED` kanıtla girmesi. (2) **Cihaz performansı/termal** (kamera+3D+ayna) — PoC: eşleşmiş iPhone 13 Pro Max'te yalnız `AVCaptureSession` + Vision barkod ilk sonuç p95, 50 tarama. (3) **Fit doğruluğu** — PoC: 10 kendi giysisiyle `SizeAdvisor` + bitmiş ölçü karşılaştırması, abstain/yanlış-kesin oranı; insan modelist olmadan "doğruluk" yazılmaz | §6 |
| V19-Q40 | Yarın mağazada kullanıcı ne görür | `EVIDENCE` | Gerçek etiketi taradığında **hiçbir şey**: kamera yok; kodu elle yazarsa gerçek ürün kodu `notFound` döner ("kayıtlı katalogda yok…", `ScanView.swift:86`). Yalnız 7 sentetik kod kart verir (sentetik rozetli). Gerçek olan: kendi yazdığı ölçüyle sentetik tablodan etiketli eşleşme, Fit Passport geçmişi, dolabında benzer var/yok, şifreli yerel kayıt. SPEC_ONLY: kamera, gerçek kimlik, kumaş, bölgesel fit, 3D, kombin üçlüsü, canlı ayna | R17-10 (28) |

---

## 2. Ek v2.0 §16 — 12 denetim sorusu

| # | Soru (kısa) | Etiket | Cevap ve kanıt | Kapatan iş |
|---|---|---|---|---|
| UI20-Q1 | Son SHA, UI/test baseline | `EVIDENCE` | Q01. Ekran görüntüleri 12 adet, hepsi `SIMULATOR_ONLY` (`docs/evidence/screenshots/`) | — |
| UI20-Q2 | `Theme.swift`/`Components.swift` v2.0 tokenlara göç | `EVIDENCE` | Göç yok. Eski token `brandInk #283D46` (`apps/ios/Kabinsiz/DesignSystem/Theme.swift:10`), 10 renk rolü ışık/koyu çift (`Theme.swift:6-15`), serif yok. Göç planı ADR olarak yazılmadı (C-14) | UI20-WP02 (13) |
| UI20-Q3 | 3 sekme + Tara eylemi | `EVIDENCE` | Var: `TabView` Bugün / Dolabım / Benim Modelim (`apps/ios/Kabinsiz/App/KabinsizApp.swift:36-39`), Tara toolbar butonu (`KabinsizApp.swift:57`). Üçüncü sekme adı v2.0'da "Ben" (C-15) | UI20-WP04 (13) |
| UI20-Q4 | İlk açılış izinsiz/kayıtsız yolculuk | `EVIDENCE` | Hesap yok ("Hesap yok, sunucu yok", `Features/Profile/MyModelView.swift:39`); `Info.plist`'te hiçbir izin açıklaması yok, yani ilk açılışta kamera/foto/konum istemi teknik olarak çıkamaz. UI20-T-008 adıyla test yok | UI20-WP05 (23) |
| UI20-Q5 | Wireframe → SwiftUI bileşen eşlemesi | `EVIDENCE` | Yapılmadı. Mevcut bileşenler: `StatusBadge`, `SyntheticBadge`, `Chip`, `ToggleChip`, `EmptyState` (`DesignSystem/Components.swift:17,31,44,58,117`); `K-001..K-020` eşlemesi yok | UI20-WP03 (13) |
| UI20-Q6 | Serif/sans karışımı Türkçe + Dynamic Type testi | `EVIDENCE` | Serif yok (grep 0); Dynamic Type testi yok (`dynamicTypeSize` grep 0) | UI20-WP03 (13) |
| UI20-Q7 | Görsel yokken premium UI | `EVIDENCE` | Uygulama hiç fotoğraf kullanmıyor; boş durumlar SF Symbol + metin (`Components.swift:117`, `WardrobeView.swift:12`) | UI20-WP05 (23) |
| UI20-Q8 | "Kanıtlı" dediğinde kaynak var mı | `EVIDENCE` | Kart "kanıtlı" demiyor; sentetik tablo "Örnek (sentetik) beden tablosu. Gerçek ürün tablosu değil." (`SizeAdvisor.swift:68`), sentetik rozet (`DecisionComposer.swift:53`). `verifiedFacts` yalnız `licensedCatalog` tablosunda (`SizeAdvisor.swift:50`), böyle tablo yok | R17-02 (10) |
| UI20-Q9 | 3D slider alanı minimum iPhone genişliğinde çakışıyor mu | `UNKNOWN` | Yalnız iPhone 17 simülatörü koşuldu; SE/mini genişliği test edilmedi (UI20-T-001) | UI20-WP07 / WP15-07/08 (9) |
| UI20-Q10 | Termal / Reduce Motion UI sadeleştirmesi | `EVIDENCE` | Reduce Motion: gövde morfu kapanıyor (`BodyStudioView.swift:10,76`, D-015). Termal: sinyal yok (Q32) | WP15-06 (8) |
| UI20-Q11 | Screenshot cihaz/tema/commit kaydı | `EVIDENCE` | Cihaz/OS `docs/evidence/WP15-05.yaml` `hardware` alanında; dosya adı `SIMULATOR_ONLY-*`. Screenshot başına SHA, tema, veri kaynağı alanı yok (UI20-T-021 açık); koyu/yüksek kontrast seti yok | UI20-WP05 (23) |
| UI20-Q12 | Çözülemeyen kritik UX, hangi kapıdan BLOCKED | `BLOCKED` | Kamera taraması, 3D stüdyo performansı, VoiceOver tam geçiş, kontrast ölçümü: `REAL_DEVICE_BLOCKED`; gerçek ürün kartı: `BLOCKED_EXTERNAL` (R-004) | UI20-WP10 (33) |

---

## 3. Ek v2.1 LM21-15 — 25 denetim sorusu

| # | Soru (kısa) | Etiket | Cevap ve kanıt | Kapatan iş |
|---|---|---|---|---|
| LM-Q01 | HEAD, PR, cihaz, test exit, kanıt | `EVIDENCE` | Q01. Ayna için ek: 3 iPhone sınıfı eşleşmiş ama çevrimdışı (§0.1) | LM21-WP01 = bu dosya |
| LM-Q02 | Videodaki teknoloji Anywear mı | `UNKNOWN` | Instagram videosu oynatılamadı (Ek v2.1 başlık, satır 9); repoda kaynak yok | Kullanıcı dosyayı verirse |
| LM-Q03 | `lucy-vton-3.6` SDK referans görsel + kamera birlikte çalışıyor mu | `UNKNOWN` | Repoda SDK yok; denemek hesap ister (`BLOCKED_EXTERNAL`) | LM21-WP10 (dış) |
| LM-Q04 | SDK Swift 6 / iOS 18 derleme uyumu | `UNKNOWN` | Ölçülmedi; proje hedefi iOS 18.0 (`apps/ios/project.yml:5`) | LM21-WP10 (dış) |
| LM-Q05 | Yerel kamera önizleme TTFF ve FPS | `BLOCKED` | Kamera kodu yok; ölçüm `REAL_DEVICE_BLOCKED` | LM21-WP04, WP07 (24) |
| LM-Q06 | Omuz/kalça tahmini neyi içerir | `EVIDENCE` | Tahmin yok: gövde değerleri yalnız `NEUTRAL_START / SLIDER_SHAPED / USER_MEASURED` kaynaklı (`BodyProfile.swift:88-90`); beden önerisi yalnız `USER_MEASURED` (D-011, `AppModel.swift:64-67`). Kameradan çevre ölçüsü çıkarılmaz (LM21-04 notu) | — |
| LM-Q07 | Dönüşte clipping oranı | `BLOCKED` | Giysi rig'i yok | LM21-WP06 (24) |
| LM-Q08 | El/saç maske hataları | `BLOCKED` | Segmentasyon yok | LM21-WP05 (24) |
| LM-Q09 | Generatif videoda logo/dikiş kayması ölçüldü mü | `BLOCKED` | Generatif video yok; bulut `BLOCKED_EXTERNAL` | LM21-WP12/15 (dış) |
| LM-Q10 | Ürün model/beden/renk kesin mi; kaynak/lisans | `EVIDENCE` | Q06, Q36: yalnız sentetik varyant kodu | R17-02/03 (10, 18) |
| LM-Q11 | Kumaş bileşimi kaynağı; videodan uydurma | `EVIDENCE` | Video yok; kumaş yalnız katalog JSON iddiası (`Catalog.swift:22`), çoğu ürün için boş | R17-04 (16) |
| LM-Q12 | Yerel modda sıfır video egress | `EVIDENCE` | Statik: kamera ve ağ API'si yok (§0.1, `StoreAndPrivacyTests.swift:78-91`); `EgressIntent.Purpose` yalnız `PRODUCT_LOOKUP`, `WEATHER_FORECAST` (`SystemContracts/EgressIntent.swift:12-13`). Paket yakalama `REAL_DEVICE_BLOCKED` | LM21-WP04 + cihaz harness |
| LM-Q13 | Bulut öncesi ayrı rıza/aydınlatma ekranı | `EVIDENCE` | Bulut mod yok; `ConsentScope`'ta canlı ayna kapsamı yok (`SystemContracts/ConsentLedger.swift:4-9`) | LM21-WP11 (30) |
| LM-Q14 | Decart şartları/DPA Türkiye'den canlı görüntüyü kapsıyor mu | `BLOCKED` | Hukuk incelemesi + DPA `BLOCKED_EXTERNAL` | LM21-WP10 (dış) |
| LM-Q15 | Kalıcı API key nerede; bundle'da olmadığı kanıtlı mı | `EVIDENCE` | Anahtar yok, token sunucusu yok, Decart kodu yok (grep 0); üçüncü taraf paket eklenirse test kırılır (`CitadelGateTests.swift:124`) | LM21-WP11 (30) |
| LM-Q16 | Reconnect/billing kontrolsüz maliyet | `EVIDENCE` | Bugün imkânsız: SDK ve ağ yolu yok. Tasarım şartı LM21-07.8 (otomatik faturalı reconnect yok) | LM21-WP11/13 |
| LM-Q17 | Maksimum saniye cihaz+sunucuda zorlanıyor mu | `BLOCKED` | Oturum yok | LM21-WP12/13 (dış) |
| LM-Q18 | g2g gecikme ölçüm aracı | `BLOCKED` | Ölçüm yok; protokol `docs/quality/V19_BENCHMARK_PROTOCOL.md` §4 | LM21-WP07, WP12 |
| LM-Q19 | MB/dk ve 5 dk batarya | `BLOCKED` | `REAL_DEVICE_BLOCKED` | LM21-WP07 (24) |
| LM-Q20 | Gecikme artınca gerçek fallback | `BLOCKED` | Bulut yok; yerel fallback mimarisi (koordinatör fallback etiketi) yalnız gövde için testli (`CoordinatorTests.swift:172`) | LM21-WP13 |
| LM-Q21 | Kilit/izin çekme/arka planda bağlantı kapanıyor mu | `BLOCKED` | Kamera oturumu yok. Model alınacak desen: rıza geri alınınca uçuştaki cevap atılıyor (`CitadelGate.swift:170-176`, test `CitadelGateTests.swift:227`) | LM21-WP04 (24) |
| LM-Q22 | Demo videoları gerçek cihaz mı | `EVIDENCE` | Repoda video yok; yalnız 12 simülatör ekran görüntüsü (`docs/evidence/screenshots/SIMULATOR_ONLY-*`) | LM21-WP08 (24) |
| LM-Q23 | 1K/10K MAU P&L sponsordan bağımsız | `UNKNOWN` | Model yok. Ek v2.1 LM21-11 yalnız fiyat çarpımı veriyor ($0.02/sn standart) | LM21-WP16 (dış) |
| LM-Q24 | İnsan moda/tekstil/privacy/a11y/red team ayrı mı | `EVIDENCE` | Hayır: tüm incelemeler `INTERNAL_SELF_REVIEW`, aynı model ailesi (`docs/evidence/WP15-05.yaml` `review_independence_level`; WP15-02..04 aynı). İnsan uzman yok | WP15-18 (14); dış |
| LM-Q25 | P0 eksikken rapor nasıl BLOCKED/UNKNOWN yazıyor | `EVIDENCE` | Kanıt şeması `partial`, `not_started`, `blocked_reasons`, `residual_risks` alanları taşıyor (`docs/evidence/WP15-04.yaml`, `WP15-05.yaml`); bu rapor §0 etiketleri. v2.1 durum sözlüğü (`TESTED_SIMULATOR` vb.) koddaki `FeatureStatus`'ta yok (`DomainContracts/Evidence.swift:27-30`) | V21-01 (7) veya LM21-WP03 (12) |

---

## 4. Sayım

| Küme | Soru | EVIDENCE | ASSUMPTION | UNKNOWN | BLOCKED |
|---|---:|---:|---:|---:|---:|
| V19-Q01..Q40 | 40 | 33 | 2 | 0 | 5 |
| v2.0 §16 | 12 | 10 | 0 | 1 | 1 |
| LM21-15 | 25 | 11 | 0 | 4 | 10 |
| **Toplam** | **77** | **54** | **2** | **5** | **16** |

---

## 5. NEEDS_USER_ACTION (V19-21 madde 12)

Onay gelmeden yapılmaz.

| # | Eylem | Neden | Açtığı iş |
|---|---|---|---|
| U-1 | Eşleşmiş bir iPhone'u (tercihen üçü: 13 Pro Max / 14 Pro Max / 16 Pro) kilidi açık, USB/Wi-Fi ile bağlamak; geliştirici modu | Tüm `REAL_DEVICE_BLOCKED` satırları | WP15-06, CRY-06, egress yakalama, R17-03, LM21-WP04..07, WP19-13 |
| U-2 | Apple Developer'da WeatherKit PLA'yı kabul etmek | R-003 | EG-001 canlı |
| U-3 | Bulut ayna istisnası kararı (C-9) | ADR-008 madde 2 | LM21-WP10..13 |
| U-4 | GS1 / marka feed / affiliate hesap ve sözleşmeleri | V19-Q07, Q36 | R17-07, R18-WP08+ |
| U-5 | İnsan uzmanlar: modelist, tekstil, stilist paneli, kriptograf, Türkiye merkezli hukukçu (KVKK) | V19-Q24, Q31, LM-Q14 | WP19-12, R17-11, LM21-WP15 |
| U-6 | GitHub Actions macOS runner maliyeti onayı | C-22 | WP19-16 |
| U-7 | Üçüncü sekme adı ("Ben") ve Canlı Ayna sekme kararı | C-13, C-15 | UI20-WP04 |
| U-8 | NAVER Anny / Meta MHR gövde modeli indirme + lisans incelemesi (gerekirse) | ADR-007 madde 2 | WP15-07/08 |

---

## 6. En önemli 10 boşluk (sıralı)

Sıralama: kullanıcıya yanlış iddia riski → güvenlik/mahremiyet → ürün çekirdeğinin varlığı → dış engel.

| # | Boşluk | Kanıt | Kapatan iş (sıra #) |
|---|---|---|---|
| 1 | `chartMatch` eksik bölgeyi sessizce atlıyor; paketli sentetik tabloda canlı (FIT-04). Ayrıca başka modelin geçmişi `likely` üretiyor (FIT-03, testle kilitli) | `SizeAdvisor.swift:128-137`, `:101-107`; `SyntheticCatalog.json` üst satırlarında yalnız göğüs; `ShoppingAndFitTests.swift:119-125` | R17-05 (15) — **öne çekilmeli**, §7 |
| 2 | Karar kartı kanıt sözleşmesini (`EvidenceRecord` / `DecisionEnvelope`) kullanmıyor; "doğrulandı" kapısı kartta yok | `DecisionComposer.swift:7-18`; `DecisionEnvelope.swift:81-86` yalnız testte | R17-02 (10), R18-WP03 (11) |
| 3 | Termal/düşük güç sinyali yok; `DeviceBudget` kademesini hiçbir şey seçmiyor | grep 0; `ResourceGovernor.swift:12-13` | WP15-06 (8) |
| 4 | Bitmiş giysi ölçüsü ve bölgesel fit yok; öneri yalnız göğüs+bel | `SizeAdvisor.swift:6-10,24-27`; `AppModel.swift:65-67` | R17-02 → R17-05 (10, 15) |
| 5 | Ürün kimliği tipleri (GTIN, beden varyantı, styleCode) ve kamera yok | `Catalog.swift:8-11`; `ScanView.swift:21` | R17-02 (10), R17-03 (18) |
| 6 | 3D gövde mesh'i yok (yalnız 2D); D-003 HEAD'de hâlâ GEÇİCİ | `Silhouette.swift:4-5`; DECISION_REGISTER HEAD satır 12 | V21-01 (7), WP15-07/08 (9) |
| 7 | Octopus yalnız gövde yolunda; tarama ve seyahat koordinatörsüz → ikinci orkestrasyon yolu riski (v1.7 §8 "ikinci paralel filo yok") | `ScanView.swift:71`; `AppModel.swift:383` | R17-02/R17-03 (10, 18) |
| 8 | Bağımsız inceleme yok: hepsi aynı model ailesi; kriptograf yok | `WP15-0x.yaml` `review_independence_level` | WP15-18 (14); U-5 |
| 9 | Kumaş/bakım/termal konfor modeli yok; sabit 15 °C kuralı | `Garment.swift:74`; `Weather.swift:77-79` | R17-04, R17-09 (16, 17) |
| 10 | Cihaz kanıtı sıfır (perf, egress yakalama, CRY-06, VoiceOver) | tüm `benchmarks: []` | WP19-13 (32) + U-1 |

---

## 7. V21 kuyruk sırasıyla çelişen bulgular

1. **FIT-04 sırası.** Boşluk #1 `CLAUDE.md` `STOP_THE_LINE` sınıfında ("yanıltıcı beden/uyum iddiası") ve bugün çalışan uygulamada tetikleniyor. Kuyrukta R17-05 içinde 15. sırada, WP15-06/07/08 ve UI göçünden sonra. Öneri: eksik bölgeyi `PARTIAL` + "tabloda bel yok" diye gösteren küçük düzeltme, R17-05'i beklemeden V21-01'den hemen sonra ayrı bir iş olarak (sözleşme değişikliği yok, `SizeAdvice` vakası + test).
2. **"Cihaz yok" varsayımı.** `DECISION_REGISTER.md` R-002 ve kuyruk sıra 32 cihaz işini en sona koyuyor. Gerçekte 3 iPhone eşleşmiş (§0.1), yalnız bağlı değil; üçü LM21-WP07'nin "3 iPhone sınıfı"nı karşılıyor. Öneri: WP15-06 (sıra 8) tamamlanınca U-1 ile kısa bir cihaz duman koşusu (CRY-06, termal geçiş, egress yakalama). Engel `REAL_DEVICE_BLOCKED` değil "cihaz bağlı değil" olarak yazılmalı.
3. **Tarama yolunun koordinatöre bağlanması geç.** Kuyrukta yalnız sıra 35 (WP15-09..14) "ortak sözleşmeye bağlama" diyor; ama sıra 18 (R17-03 kamera) ve 28 (R17-10) tarama yolunu büyütüyor. Koordinatörsüz büyüyen tarama yolu v1.7 §8'e aykırı ikinci yol olur. Öneri: kart üretimini `OctopusCoordinator` + `DecisionEnvelope` altına almak R17-02 (sıra 10) kapsamına girsin.
4. **Style DNA öncesi koruma.** `SensitiveAttributeGuard` ruh hali/kişilik/kültür/ten tonu köklerini içermiyor (Q22, Q25). WP19-09'un (sıra 20) bağımlılığına eklenmeli.
5. **V21-01 eşzamanlı.** ADR-006..008 çalışma ağacında yazılmış ama commit edilmemiş; V21-00 (sıra 6) "5 bitince, HEAD kararlı" ön şartıyla V21-01 aynı anda yürüyor. İçerik çelişmiyor; yalnız bu rapordaki Q02 ve Q18 cevapları ADR'lar commit edilince `EVIDENCE` satırlarıyla güncellenmeli.

## 8. V19-21 teslim dosyaları

| # | Dosya | Durum |
|---|---|---|
| 1 | `docs/audit/V19_REALITY_AND_GAP_REPORT.md` | Bu dosya |
| 2 | `docs/audit/V19_REQUIREMENT_TRACEABILITY.md` | Yazıldı |
| 3 | `docs/system/V19_OCTOPUS_MODULE_REGISTRY.md` | Yazıldı |
| 4 | `docs/data/V19_PRODUCT_TRUTH_AND_RIGHTS.md` | Yazıldı |
| 5 | `docs/ai/V19_STYLE_DNA_AND_ATELIER.md` | Yazıldı (tamamı SPEC_ONLY) |
| 6 | `docs/quality/V19_FIT_FABRIC_VISUAL_BENCHMARKS.md` | Yazıldı (protokol, sayı yok) |
| 7 | `docs/quality/V19_ON_DEVICE_LATENCY_PLAN.md` | Yazıldı (plan, sayı yok) |
| 8 | `docs/security/V19_CITADEL_EGRESS_AND_VAULT_AUDIT.md` | Yazıldı |
| 9 | `docs/roadmap/V19_DEPENDENCY_DAG.md` | Yazıldı |
| V19-00 | `docs/quality/V19_BENCHMARK_PROTOCOL.md` | Yazıldı |
| V19-00 | `docs/DECISION_REGISTER.md` güncellemesi | **Yapılmadı**: bu iş kapsamında yasak (V21-01 ajanı düzenliyor). Önerilen girdiler: FIT-04 öne çekme (§7.1), R-002 metni (§7.2) |
| 10 | `.claude/agents/…`, `.claude/skills/…` | **Yazılmadı**: V19-15 "gereksiz ajan üretme"; C-21 "ihtiyaç doğduğunda tek eşleme". Bugün eksik rol (AG-06 Fit Science, AG-11 Perf) ilgili iş paketi başladığında yazılmalı |
| 11 | İlk uygulama PR'ı (kod + test + kanıt) | **Kapsam dışı**: V21-00 yalnız dosya; kod V21-01 sonrası iş paketlerinde |
| 12 | NEEDS_USER_ACTION | §5 |
